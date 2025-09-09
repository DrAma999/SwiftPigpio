import Clibpigpio

// MARK: - GPIO Modes
public enum GPIOMode {
    case input
    case output
    case alt0, alt1, alt2, alt3, alt4, alt5

    var cValue: UInt32 {
        switch self {
        case .input:  return MODE_INPUT
        case .output: return MODE_OUTPUT
        case .alt0:   return MODE_ALT0
        case .alt1:   return MODE_ALT1
        case .alt2:   return MODE_ALT2
        case .alt3:   return MODE_ALT3
        case .alt4:   return MODE_ALT4
        case .alt5:   return MODE_ALT5
        }
    }

    init?(cValue: UInt32) {
        switch cValue {
        case MODE_INPUT:  self = .input
        case MODE_OUTPUT: self = .output
        case MODE_ALT0:   self = .alt0
        case MODE_ALT1:   self = .alt1
        case MODE_ALT2:   self = .alt2
        case MODE_ALT3:   self = .alt3
        case MODE_ALT4:   self = .alt4
        case MODE_ALT5:   self = .alt5
        default: return nil
        }
    }
}

// MARK: - Pull Up / Down
public enum Pull {
    case off, down, up

    var cValue: UInt32 {
        switch self {
        case .off:  return PUD_OFF
        case .down: return PUD_DOWN
        case .up:   return PUD_UP
        }
    }

    init?(cValue: UInt32) {
        switch cValue {
        case PUD_OFF:  self = .off
        case PUD_DOWN: self = .down
        case PUD_UP:   self = .up
        default: return nil
        }
    }
}

// MARK: - GPIO Level
public enum Level {
    case low, high

    var cValue: UInt32 {
        switch self {
        case .low:  return LEVEL_LOW
        case .high: return LEVEL_HIGH
        }
    }

    init?(cValue: UInt32) {
        switch cValue {
        case LEVEL_LOW:  self = .low
        case LEVEL_HIGH: self = .high
        default: return nil
        }
    }
}

// MARK: - SPI Modes
public enum SPIMode {
    case mode0, mode1, mode2, mode3

    // var cValue: UInt32 {
    //     switch self {
    //     case .mode0: return SPI_MODE_0
    //     case .mode1: return SPI_MODE_1
    //     case .mode2: return SPI_MODE_2
    //     case .mode3: return SPI_MODE_3
    //     }
    // }

    // init?(cValue: UInt32) {
    //     switch cValue {
    //     case SPI_MODE_0: self = .mode0
    //     case SPI_MODE_1: self = .mode1
    //     case SPI_MODE_2: self = .mode2
    //     case SPI_MODE_3: self = .mode3
    //     default: return nil
    //     }
    // }
}
