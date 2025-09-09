//
//  PIN.swift
//  SwiftPigpio
//
//  Created by Andrea Finollo on 16/08/25.
//

public enum RaspberryPin: UInt32 {
    // 40-pin header (GPIO-capable pins)
    case physical3  = 2    // SDA1
    case physical5  = 3    // SCL1
    case physical7  = 4
    case physical8  = 14   // TXD
    case physical10 = 15   // RXD
    case physical11 = 17
    case physical12 = 18   // PWM0 (HW)
    case physical13 = 27
    case physical15 = 22
    case physical16 = 23
    case physical18 = 24
    case physical19 = 10   // MOSI
    case physical21 = 9    // MISO
    case physical22 = 25
    case physical23 = 11   // SCLK
    case physical24 = 8    // CE0
    case physical26 = 7    // CE1
    case physical29 = 5
    case physical31 = 6
    case physical32 = 12   // PWM0 (HW alt)
    case physical33 = 13   // PWM1 (HW)
    case physical35 = 19   // MISO / PWM1
    case physical36 = 16
    case physical37 = 26
    case physical38 = 20   // MOSI / PWM1
    case physical40 = 21   // SCLK

    public var bcm: UInt32 { self.rawValue }
}
