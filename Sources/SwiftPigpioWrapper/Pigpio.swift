import Clibpigpio
import Foundation

// MARK: - Pigpio Resource and Factory

/// A protocol that represents a resource for interacting with the Pigpio library.
///
/// The `PigpioResource` protocol defines the basic operations and properties required to manage
/// the initialization, shutdown, and configuration of the Pigpio library. It also provides
/// information about the mode in which the library is operating and the resource identifier
/// associated with the library.
///
/// Conforming types are expected to implement the initialization and shutdown logic for the
/// Pigpio library, as well as provide access to the library's mode and resource identifier.
public protocol PigpioResource {
    /// Initializes the Pigpio library.
    ///
    /// This method is responsible for setting up the Pigpio library and preparing it for use.
    /// The specific initialization logic depends on the mode in which the library is operating
    /// (e.g., direct mode or daemon mode).
    ///
    /// - Returns: `true` if the initialization was successful, `false` otherwise.
    @discardableResult
    func initialize() -> Bool

    /// Shuts down the Pigpio library.
    ///
    /// This method is responsible for properly shutting down the Pigpio library and releasing
    /// any resources that were allocated during initialization. It should be called when the
    /// library is no longer needed.
    func shutdown()

    /// The mode in which the Pigpio library is operating.
    ///
    /// This property indicates whether the library is operating in direct mode (requiring
    /// `gpioInitialise` and sudo privileges) or daemon mode (using `pigpiod` with an optional
    /// address and port).
    var mode: PigpioMode { get }

    /// The resource identifier for the Pigpio library.
    ///
    /// This property provides the identifier associated with the Pigpio library. The value
    /// of this identifier depends on the mode in which the library is operating. For example,
    /// in daemon mode, it may represent the connection handle to the `pigpiod` daemon.
    var pi: Int32 { get }
}

public enum PigpioMode: Sendable {
    /// Direct mode
    ///  - important: Requires `sudo` privileges
    case direct

    /// Daemon mode
    /// Requires the address usually `localhost` and port usually `8888`
    ///  - important: Make sure the pigpiod daemon is running
    case daemon(address: String? = nil, port: String? = nil)
}

/// A concrete implementation of the `PigpioResource` protocol that manages the Pigpio library.
public final class PigpioLibrary: PigpioResource {
    /// The mode in which the Pigpio library is operating.
    public let mode: PigpioMode

    /// The resource identifier for the Pigpio library.
    public var pi: Int32 = Int32.min

    /// Indicates whether the Pigpio library is initialized.
    var isInitialized: Bool {
        switch mode {
        case .direct:
            return gpioInitialise() >= 0
        case .daemon:
            return pi != 0
        }
    }

    /// Initializes a new instance of the Pigpio library.
    /// - Parameter mode: The mode in which the library will operate.
    public init(mode: PigpioMode) {
        self.mode = mode
    }

    /// Initializes the Pigpio library.
    /// In case of direct mode, it calls `gpioInitialise` to initialize the library.
    /// In case of daemon mode, it calls `pigpioStart` with the specified address and port.
    /// - Returns: `true` if the initialization was successful, `false` otherwise.
    @discardableResult
    public func initialize() -> Bool {
        switch self.mode {
        case .direct:
            let result = gpioInitialise()
            if result < 0 { return false }
            return true

        case .daemon(let address, let port):
            let addrC = address?.cString(using: .utf8)
            let portC = port?.cString(using: .utf8)
            let result = shim_pigpioStart(addrC, portC)
            if result < 0 { return false }
            self.pi = result
            return true
        }
    }

    /// Shuts down the Pigpio library.
    public func shutdown() {
        switch mode {
        case .direct:
            if isInitialized {
                gpioTerminate()
            }
        case .daemon:
            if isInitialized {
                shim_pigpioStop(pi)
            }
        }
    }
}

private final class WeakRegistrableBox: @unchecked Sendable {
    /// A weak reference to a `Registrable` instance.
    weak var value: (any Registrable)?

    /// Initializes a new weak box for a `Registrable` instance.
    /// - Parameter value: The `Registrable` instance to store.
    init(_ value: any Registrable) {
        self.value = value
    }
}

/// A factory class for creating and managing resources associated with the Pigpio library.
///
/// The `PigpioFactory` class provides methods to create and manage instances of `GPIOHandler`,
/// `SPI`, and `I2C` resources. It also handles the initialization and shutdown of the Pigpio
/// library, ensuring that resources are properly registered and unregistered.
///
/// This class supports both direct and daemon modes of the Pigpio library.
public final class PigpioFactory: @unchecked Sendable {
    /// The Pigpio resource associated with this factory.
    let resource: any PigpioResource

    private let lock = NSLock()
    private var cache = [UUID: WeakRegistrableBox]()

    /// Indicates whether the factory is operating in daemon mode.
    ///
    /// This property returns `true` if the factory is using the Pigpio library in daemon mode,
    /// and `false` if it is using direct mode.
    var isDaemon: Bool {
        switch resource.mode {
        case .direct:
            return false
        case .daemon:
            return true
        }
    }

    /// The resource identifier for the Pigpio library.
    var resourceId: Int32 {
        return resource.pi
    }

    /// Initializes a new Pigpio factory.
    /// - Parameter resource: The Pigpio resource to associate with this factory. Defaults to `.direct` mode.
    public init(with resource: PigpioResource = PigpioLibrary(mode: .direct)) {
        self.resource = resource
    }

    /// Registers a `Registrable` instance with the factory.
    /// - Parameter handler: The `Registrable` instance to register.
    fileprivate func register(_ handler: any Registrable) {
        lock.lock()
        defer { lock.unlock() }
        cache[handler.id] = WeakRegistrableBox(handler)
        if cache.count == 1 {
            // If this is the first handler, start the library
            resource.initialize()
        }
    }

    /// Unregisters a `Registrable` instance from the factory.
    /// - Parameter id: The unique identifier of the `Registrable` instance to unregister.
    fileprivate func unregister(_ id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        cache.removeValue(forKey: id)
        if cache.isEmpty {
            // If no more handlers, shutdown the library
            resource.shutdown()
        }
    }

    /// Builds and returns a new `GPIOHandler` instance.
    ///
    /// This method creates a new `GPIOHandler` instance and registers it with the factory.
    /// If a `GPIOHandler` instance already exists, it returns the existing instance.
    ///
    /// - Returns: A `GPIOHandler` instance.
    public func buildGPIOHandler() -> GPIOHandler {
        if let handler = cache.filter({ (key: UUID, value: WeakRegistrableBox) in
            value.value is GPIOHandler
        }).first?.value {
            return handler.value as! GPIOHandler
        } else {
            let handler = GPIOHandler(factory: self)
            register(handler)
            return handler
        }
    }

    /// Builds and returns a new `SPIHandler` instance.
    /// - Parameters:
    ///   - channel: The SPI channel to use.
    ///   - baudRate: The baud rate for SPI communication. Defaults to 1,000,000.
    ///   - flags: The SPI flags. Defaults to 0.
    /// - Throws: An `SPIError` if the SPI instance cannot be created.
    /// - Returns: An `SPIHandler` instance.
    public func buildSPI(
        channel: UInt32,
        baudRate: UInt32 = 1_000_000,
        flags: UInt32 = 0
    ) throws(SPIError) -> SPIHandler {
        let spi = try SPIHandler(
            channel: channel,
            baudRate: baudRate,
            flags: flags,
            factory: self
        )
        register(spi)
        return spi
    }

    /// Builds and returns a new `I2CHandler` instance.
    /// - Parameters:
    ///   - bus: The I2C bus to use.
    ///   - address: The I2C address to communicate with.
    /// - Throws: An `I2CError` if the I2C instance cannot be created.
    /// - Returns: An `I2CHandler` instance.
    public func buildI2C(
        bus: UInt32,
        address: UInt32
    ) throws(I2CError) -> I2CHandler {
        let i2c = try I2CHandler(
            bus: bus,
            address: address,
            factory: self
        )
        register(i2c)
        return i2c
    }
}

protocol Registrable: Identifiable, AnyObject {
    var id: UUID { get }
    var token: RegistrableToken { get }
}

final class RegistrableToken: @unchecked Sendable {
    private weak var factory: PigpioFactory?
    private let id: UUID

    /// Initializes a new `RegistrableToken`.
    /// - Parameters:
    ///   - factory: The `PigpioFactory` associated with this token.
    ///   - id: The unique identifier for the `Registrable` instance.
    init(factory: PigpioFactory, id: UUID) {
        self.factory = factory
        self.id = id
    }

    deinit {
        factory?.unregister(id)
    }
}
