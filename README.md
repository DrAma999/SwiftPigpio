# SwiftPigpio

Swift-friendly wrappers for the Raspberry Pi GPIO via the [`pigpio`](http://abyz.me.uk/rpi/pigpio/) C library.
Compatible with Raspberry PI 4, 3, zero.

## Features

- GPIO helpers with Swift enums (`GPIOMode`, `RaspberryPin`)
- Hardware & software PWM
- I2C & SPI wrapper classes

## Roadmap
- [x] Test GPIO handler
- [] Test I2C handler
- [] Test SPI handler


## Install `pigpio`

```bash
sudo apt update
sudo apt install pigpio
sudo systemctl enable --now pigpiod
# or start manually:
# sudo pigpiod
```

## Build & Run
SwiftPigpioWrapper can work in 2 modes:
- as a client of the `pigpiod` daemon 
- directly via the C library (this requires root privileges)

The examples use the daemon mode.
```bash
swift build
swift run Example
```

### Snippet
SwiftPigpioWrapper requires to build a factory that must have a strong reference, this because it keeps track of the handler built.
In this example we are creating a `GPIOHandler` based on the daemon mode.
```swift
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
```

## Notes

- Use **BCM numbering**: `RaspberryPin.physical12.bcm` → 18.
- Hardware PWM works on BCM 12, 13, 18, 19.
- SPI examples assume channel 0 (CE0) at 1MHz, mode 0.
- I2C example uses bus 1 at address `0x20` — adjust for your device.
