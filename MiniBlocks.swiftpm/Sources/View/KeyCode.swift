/// Cocoa key codes for convenience, based on https://stackoverflow.com/questions/36900825/where-are-all-the-cocoa-keycodes.
struct KeyCode: RawRepresentable, Hashable {
    static let a = Self(rawValue: 0)
    static let s = Self(rawValue: 1)
    static let d = Self(rawValue: 2)
    static let w = Self(rawValue: 13)
    static let one = Self(rawValue: 18)
    static let two = Self(rawValue: 19)
    static let three = Self(rawValue: 20)
    static let four = Self(rawValue: 21)
    static let five = Self(rawValue: 23)
    static let six = Self(rawValue: 22)
    static let seven = Self(rawValue: 26)
    static let eight = Self(rawValue: 28)
    static let nine = Self(rawValue: 25)
    static let zero = Self(rawValue: 29)
    static let space = Self(rawValue: 49)
    static let escape = Self(rawValue: 53)
    static let arrowLeft = Self(rawValue: 123)
    static let arrowRight = Self(rawValue: 124)
    static let arrowDown = Self(rawValue: 125)
    static let arrowUp = Self(rawValue: 126)
    static let f1 = Self(rawValue: 122)
    static let f2 = Self(rawValue: 120)
    static let f3 = Self(rawValue: 99)
    static let f4 = Self(rawValue: 118)
    static let f5 = Self(rawValue: 96)
    static let f6 = Self(rawValue: 97)
    static let f7 = Self(rawValue: 98)
    static let f8 = Self(rawValue: 100)
    static let f9 = Self(rawValue: 101)
    
    let rawValue: UInt16
    
    var numericValue: Int? {
        switch self {
        case .zero: return 0
        case .one: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        default: return nil
        }
    }
}
