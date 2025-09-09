import XCTest
@testable import SwiftPigpio

final class SwiftPigpioTests: XCTestCase {

    func testGPIOModeEnum() {
        XCTAssertEqual(GPIOMode.input.rawValue, 0)
        XCTAssertEqual(GPIOMode.output.rawValue, 1)
    }

    func testRaspberryPinMapping() {
        XCTAssertEqual(RaspberryPin.gpio17.bcmNumber, 17)
    }

}
