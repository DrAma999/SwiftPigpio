import Clibpigpio
import Foundation

/// Represents errors that can occur when interacting with I2C devices.
///
/// The `I2CError` enum defines various error cases that may arise when using the I2C interface.
/// These errors are based on the error codes returned by the Pigpio library.
public enum I2CError: Error {
    case badI2CBus
    case badI2CAddr
    case badFlags
    case noHandle
    case i2COpenFailed
    case unknownError

    init(cValue: Int32) {
        switch cValue {
        case BAD_I2C_BUS: self = .badI2CBus
        case BAD_I2C_ADDR: self = .badI2CAddr
        case BAD_I2C_FLAGS: self = .badFlags
        case NO_I2C_HANDLE: self = .noHandle
        case I2C_OPEN_FAILED: self = .i2COpenFailed
        default: self = .unknownError
        }
    }
}

/// A handler for managing I2C communication.
///
/// The `I2CHandler` class provides methods for interacting with I2C devices. It supports both direct
/// and daemon modes of the Pigpio library. This class allows you to perform read and write
/// operations on I2C devices.
public final class I2CHandler: Registrable, Sendable {
    private let handle: UInt32
    private let resourceId: @Sendable () -> Int32
    public let id = UUID()
    let token: RegistrableToken

    var isDaemon: Bool {
        resourceId() >= 0
    }

    init(
        bus: UInt32,
        address: UInt32,
        flags: UInt32 = 0,
        factory: PigpioFactory
    ) throws(I2CError) {
        self.resourceId = { [weak factory] in
            factory?.resourceId ?? Int32.min
        }
        self.token = RegistrableToken(factory: factory, id: id)
        let h =
            resourceId() >= 0
            ? shim_i2cOpenDaemon(resourceId(), bus, address, flags) : i2cOpen(bus, address, flags)
        guard h >= 0 else { throw I2CError(cValue: h) }
        self.handle = UInt32(h)
    }
    /// Writes a single byte to the I2C device.
    ///
    /// - Parameter value: The byte value to write.
    /// - Throws: An `I2CError` if the write operation fails.
    public func writeByte(_ value: UInt32) throws(I2CError) {
        let rc =
            isDaemon
            ? shim_i2cWriteByteDaemon(resourceId(), handle, value) : i2cWriteByte(handle, value)
        if rc < 0 { throw I2CError(cValue: rc) }
    }

    /// Writes a single byte to a specific register of the I2C device.
    ///
    /// - Parameters:
    ///   - register: The register to write to.
    ///   - value: The byte value to write.
    /// - Throws: An `I2CError` if the write operation fails.
    public func writeByte(
        register: UInt32,
        value: UInt32
    ) throws(I2CError) {
        let rc =
            isDaemon
            ? shim_i2cWriteByteDataDaemon(resourceId(), handle, register, value)
            : i2cWriteByteData(handle, register, value)
        if rc < 0 { throw I2CError(cValue: rc) }
    }

    /// Reads a single byte from the I2C device.
    ///
    /// - Returns: The byte value read from the device.
    /// - Throws: An `I2CError` if the read operation fails.
    public func readByte() throws(I2CError) -> UInt32 {
        let r = isDaemon ? shim_i2cReadByteDaemon(resourceId(), handle) : i2cReadByte(handle)
        if r < 0 { throw I2CError(cValue: r) }
        return UInt32(r)
    }

    /// Reads a single byte from a specific register of the I2C device.
    ///
    /// - Parameter register: The register to read from.
    /// - Returns: The byte value read from the register.
    /// - Throws: An `I2CError` if the read operation fails.
    public func readByte(register: UInt32) throws(I2CError) -> UInt32 {
        let r =
            isDaemon
            ? shim_i2cReadByteDataDaemon(resourceId(), handle, register)
            : i2cReadByteData(handle, register)
        if r < 0 { throw I2CError(cValue: r) }
        return UInt32(r)
    }

    deinit {
        if isDaemon {
            shim_i2cCloseDaemon(resourceId(), handle)
        } else {
            i2cClose(handle)
        }
    }
}
