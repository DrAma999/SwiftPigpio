import Clibpigpio
//
//  GPIO.swift
//  SwiftPigpio
//
//  Created by Andrea Finollo on 16/08/25.
//
import Foundation

/// Represents the different modalities for configuring a GPIO pin.
public enum GPIOModality {
    /// Configures the GPIO pin as an input or output with an optional pull-up or pull-down resistor.
    case direction(mode: GPIOMode, pull: Pull = .off)
    /// Configures the GPIO pin for hardware PWM with a specified frequency and duty cycle.
    /// - Parameters:
    ///   - freq: The frequency of the PWM signal.
    ///   - duty: The duty cycle of the PWM signal (0 to 1,000,000).
    case pwmHardware(freq: UInt32, duty: UInt32)
    /// Configures the GPIO pin for software PWM with a specified frequency and duty cycle.
    /// - Parameters:
    ///   - freq: The frequency of the PWM signal.
    ///   - duty: The duty cycle of the PWM signal (0 to 255).
    case pwmSoftware(freq: UInt32, duty: UInt32)
}

/// Represents errors that can occur when interacting with GPIO pins.
/// For detailed error information, refer to the Pigpio documentation.
public enum GPIOError: Error {
    case badGPIOPin
    case notHPWMGPIO
    case badHPWMDuty
    case badHPWMFreq
    case hpwmIllegal
    case unknownError

    init(cValue: Int32) {
        switch cValue {
        case BAD_GPIO: self = .badGPIOPin
        case NOT_HPWM_GPIO: self = .notHPWMGPIO
        case BAD_HPWM_DUTY: self = .badHPWMDuty
        case BAD_HPWM_FREQ: self = .badHPWMFreq
        case HPWM_ILLEGAL: self = .hpwmIllegal
        default: self = .unknownError
        }
    }
}

/// A handler for managing GPIO pins.
///
/// The `GPIOHandler` class provides methods for configuring and interacting with GPIO pins.
/// It supports both direct and daemon modes of the Pigpio library.
public final class GPIOHandler: Registrable, Sendable {
    private let resourceId: @Sendable () -> Int32
    public let id = UUID()
    let token: RegistrableToken

    var isDaemon: Bool {
        resourceId() >= 0
    }

    init(factory: PigpioFactory) {
        self.token = RegistrableToken(factory: factory, id: id)
        self.resourceId = { [weak factory] in
            factory?.resourceId ?? Int32.min
        }
    }

    /// Configures the mode of a GPIO pin.
    ///
    /// This method allows you to set the mode of a GPIO pin, including input, output, or alternate functions.
    /// It also supports configuring hardware or software PWM.
    ///
    /// - Parameters:
    ///   - pin: The GPIO pin to configure.
    ///   - modality: The desired modality for the pin.
    /// - Throws: A `GPIOError` if the configuration fails.
    public func setMode(pin: UInt32, modality: GPIOModality) throws(GPIOError) {
        switch modality {
        case .direction(let mode, let pull):
            switch mode {
            case .input:
                if isDaemon {
                    shim_gpioSetModeDaemon(resourceId(), pin, mode.cValue)
                    shim_gpioSetPullUpDownDaemon(resourceId(), pin, pull.cValue)
                } else {
                    shim_gpioSetMode(pin, mode.cValue)
                    shim_gpioSetPullUpDown(pin, pull.cValue)
                }
            case .output:
                if isDaemon {
                    shim_gpioSetModeDaemon(resourceId(), pin, mode.cValue)
                    shim_gpioSetPullUpDownDaemon(resourceId(), pin, pull.cValue)
                } else {
                    shim_gpioSetMode(pin, mode.cValue)
                    shim_gpioSetPullUpDown(pin, pull.cValue)
                }
            case .alt0, .alt1, .alt2, .alt3, .alt4, .alt5:  // check if required
                if isDaemon {
                    shim_gpioSetModeDaemon(resourceId(), pin, mode.cValue)
                    shim_gpioSetPullUpDownDaemon(resourceId(), pin, pull.cValue)
                } else {
                    shim_gpioSetMode(pin, mode.cValue)
                    shim_gpioSetPullUpDown(pin, pull.cValue)
                }
            }
        case .pwmHardware(let freq, let duty):
            // Caller should pick a HW-PWM-capable pin (12,13,18,19)
            if isDaemon {
                let rc = shim_gpioHardwarePWMDaemon(resourceId(), pin, freq, duty)
                if rc != 0 { throw GPIOError(cValue: Int32(rc)) }
            } else {
                let rc = shim_gpioHardwarePWM(pin, freq, duty)
                if rc != 0 { throw GPIOError(cValue: Int32(rc)) }
            }
        case .pwmSoftware(let freq, let duty):
            if isDaemon {
                var rc = shim_setPWMFrequencyDaemon(resourceId(), pin, freq)
                if rc != 0 { throw GPIOError(cValue: Int32(rc)) }
                rc = shim_gpioPWMDaemon(resourceId(), pin, duty)
                if rc != 0 { throw GPIOError(cValue: Int32(rc)) }
            } else {
                shim_gpioSetMode(pin, GPIOMode.output.cValue)
                shim_gpioSetPWMfrequency(pin, freq)
                shim_gpioPWM(pin, duty)
            }
        }
    }

    /// Writes a value to a GPIO pin.
    ///
    /// This method sets the output level of a GPIO pin to either high or low.
    ///
    /// - Parameters:
    ///   - pin: The GPIO pin to write to.
    ///   - value: The value to write (`true` for high, `false` for low).
    /// - Throws: A `GPIOError` if the write operation fails.
    public func write(pin: UInt32, value: Bool) throws(GPIOError) {
        let response =
            if isDaemon {
                shim_gpioWriteDaemon(resourceId(), pin, value ? 1 : 0)
            } else {
                shim_gpioWrite(pin, value ? 1 : 0)
            }
        guard response == 0 else { throw GPIOError(cValue: Int32(response)) }
    }

    /// Reads the value of a GPIO pin.
    ///
    /// This method reads the current input level of a GPIO pin.
    ///
    /// - Parameter pin: The GPIO pin to read from.
    /// - Returns: `true` if the pin is high, `false` if the pin is low.
    /// - Throws: A `GPIOError` if the read operation fails.
    public func read(pin: UInt32) throws(GPIOError) -> Bool {
        let rc =
            if isDaemon {
                shim_gpioReadDaemon(resourceId(), pin)
            } else {
                shim_gpioRead(pin)
            }
        guard rc >= 0 else { throw GPIOError(cValue: Int32(rc)) }
        return rc != 0
    }

}

extension GPIOHandler {
    /// Toggles the state of a GPIO pin.
    /// - Parameter pin: The GPIO pin to toggle.
    /// - Throws: A `GPIOError` if the toggle operation fails.
    public func toggle(pin: UInt32) throws(GPIOError) {
        let current = try read(pin: pin)
        try write(pin: pin, value: !current)
    }

    /// Pulses the state of a GPIO pin.
    /// - Parameters:
    ///   - pin: The GPIO pin to pulse.
    ///   - durationMicroseconds: The duration to keep the pin high, in microseconds.
    /// - Throws: A `GPIOError` if the pulse operation fails.
    public func pulse(
        pin: UInt32,
        durationMicroseconds: UInt32
    ) throws(GPIOError) {
        try write(pin: pin, value: true)
        usleep(durationMicroseconds)
        try write(pin: pin, value: false)
    }

    /// Blinks the state of a GPIO pin.
    /// - Parameters:
    ///   - pin: The GPIO pin to blink.
    ///   - onDuration: The duration to keep the pin high, in microseconds.
    ///   - offDuration: The duration to keep the pin low, in microseconds.
    ///   - count: The number of times to blink the pin.
    /// - Throws: A `GPIOError` if the blink operation fails.
    public func blink(
        pin: UInt32,
        onDuration: UInt32,
        offDuration: UInt32,
        count: UInt32
    ) throws(GPIOError) {
        for _ in 0..<count {
            try write(pin: pin, value: true)
            usleep(onDuration)
            try write(pin: pin, value: false)
            usleep(offDuration)
        }
    }

    /// Start (500-2500) or stop (0) servo pulses on the GPIO.
    /// - Parameters:
    ///   - pin: The GPIO pin to write to.
    ///   - width: 0 (off), 500 (anti-clockwise) - 2500 (clockwise).
    /// - Throws: A `GPIOError` if the operation fails.
    public func setServoPulsewidth(pin: UInt32, width: UInt32) throws(GPIOError) {
        let rc =
            if isDaemon {
                shim_setServoPulsewidthDaemon(resourceId(), pin, width)
            } else {
                shim_gpioServo(pin, width)
            }
        guard rc >= 0 else { throw GPIOError(cValue: Int32(rc)) }
    }
}
