import Clibpigpio
import Foundation

/// Reads a single byte from a specific register of the I2C device.
///
/// - Parameter register: The register to read from.
/// - Returns: The byte value read from the register.
/// - Throws: An `I2CError` if the read operation fails.
public enum SPIError: Error {
    case badSPIChannel
    case badSPISpeed
    case badFlags
    case noAuxSPI
    case spiOpenFailed
    case badSPIHandle
    case badSPICount
    case spiXferFailed
    case unknownError

    init(cValue: Int32) {
        switch cValue {
        case BAD_SPI_CHANNEL: self = .badSPIChannel
        case BAD_SPI_SPEED: self = .badSPISpeed
        case BAD_SPI_FLAGS: self = .badFlags
        case NO_AUX_SPI: self = .noAuxSPI
        case SPI_OPEN_FAILED: self = .spiOpenFailed
        case BAD_SPI_HANDLE: self = .badSPIHandle
        case BAD_SPI_COUNT: self = .badSPICount
        case SPI_XFER_FAILED: self = .spiXferFailed
        default: self = .unknownError
        }
    }
}

/// A handler for managing SPI communication.
///
/// The `SPIHandler` class provides methods for interacting with SPI devices. It supports both direct
/// and daemon modes of the Pigpio library. This class allows you to perform SPI transfer
/// operations with connected devices.
public final class SPIHandler: Registrable, Sendable {
    private let handle: UInt32
    private let resourceId: @Sendable () -> Int32
    public let id = UUID()
    let token: RegistrableToken

    var isDaemon: Bool {
        resourceId() >= 0
    }

    init(
        channel: UInt32,
        baudRate: UInt32 = 1_000_000,
        flags: UInt32 = 0,
        factory: PigpioFactory
    ) throws(SPIError) {
        self.resourceId = { [weak factory] in
            factory?.resourceId ?? Int32.min
        }
        self.token = RegistrableToken(factory: factory, id: id)
        let h =
            if resourceId() >= 0 {
                // Daemon mode
                shim_spiOpenDaemon(resourceId(), channel, baudRate, flags)
            } else {
                shim_spiOpen(channel, baudRate, flags)
            }
        guard h >= 0 else { throw SPIError(cValue: h) }
        self.handle = UInt32(h)
    }

    /// Transfers data to and from the SPI device.
    ///
    /// This method performs a full-duplex SPI transfer, sending the specified data to the device
    /// and receiving data back from the device.
    ///
    /// - Parameter data: The data to send to the SPI device.
    /// - Returns: The data received from the SPI device.
    /// - Throws: An `SPIError` if the transfer operation fails.
    public func transfer(_ data: [UInt8]) throws(SPIError) -> [UInt8] {
        var tx = data
        var rx = [UInt8](repeating: 0, count: data.count)
        let result: Int32 = tx.withUnsafeMutableBufferPointer { txPtr in
            rx.withUnsafeMutableBufferPointer { rxPtr in
                isDaemon
                    ? shim_spiXferDaemon(
                        resourceId(), handle, txPtr.baseAddress, rxPtr.baseAddress,
                        UInt32(data.count))
                    : spiXfer(handle, txPtr.baseAddress, rxPtr.baseAddress, UInt32(data.count))
            }
        }
        if result < 0 { throw SPIError(cValue: result) }
        return rx
    }

    deinit {
        if isDaemon {
            shim_spiCloseDaemon(resourceId(), handle)
        } else {
            spiClose(handle)
        }
    }
}
