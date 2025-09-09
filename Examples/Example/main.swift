import SwiftPigpioWrapper
import Foundation

let resource = PigpioLibrary(mode: .daemon(address: "localhost", port: "8888"))
let pigpioFactory = PigpioFactory(with: resource)


// 1) GPIO: Toggle LED on physical pin 7 (BCM 4)
let gpioHandler: GPIOHandler = pigpioFactory.buildGPIOHandler()

do {
    try gpioHandler.setMode(pin: RaspberryPin.physical7.bcm, modality: .direction(mode: .output, pull: Pull.off))
    try gpioHandler.write(pin: RaspberryPin.physical7.bcm, value: true)
    sleep(1)
    try gpioHandler.write(pin: RaspberryPin.physical7.bcm, value: false)
    print("GPIO toggle done.")
} catch {
    print("GPIO error: \(error)")
}

// 2) PWM (Hardware): Servo-like pulse on BCM 18 (physical 12)
do {
    // 50 Hz with 1.5ms pulse => duty = 1_000_000 on a 0..1_000_000 scale at 50Hz
    try gpioHandler.setMode(pin: RaspberryPin.physical12.bcm, modality: .pwmHardware(freq: 50, duty: 1_000_000))
    print("Hardware PWM running on BCM 18 @ 50Hz, 1.5ms pulse")
    sleep(2)
    // stop PWM
    try gpioHandler.setMode(pin: RaspberryPin.physical12.bcm, modality: .pwmHardware(freq: 0, duty: 0))
} catch {
    print("PWM error: \(error)")
}

// 3) I2C: Byte write/read demo (adjust address/register to your device)
do {
    let i2c = try pigpioFactory.buildI2C(bus: 1, address: 0x20)
    try i2c.writeByte(register: 0x00, value: 0xFF)
    let val = try i2c.readByte(register: 0x00)
    print("I2C read: \(val)")
} catch {
    print("I2C error: \(error)")
}

// 4) SPI: JEDEC ID read (0x9F) demo on channel 0
do {
    let spi = try pigpioFactory.buildSPI(channel: 0, baudRate: 1_000_000, flags: 0) // mode 0
    let rx = try spi.transfer([0x9F, 0x00, 0x00, 0x00])
    print("SPI RX: \(rx)")
} catch {
    print("SPI error: \(error)")
}
