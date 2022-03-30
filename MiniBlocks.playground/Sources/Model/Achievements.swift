/// Represents in-game progress milestones by the player.
struct Achievements: OptionSet, Sequence {
    let rawValue: UInt64
    
    static let moveAround = Self(rawValue: 1 << 0)
    static let jump = Self(rawValue: 1 << 1)
    static let sprint = Self(rawValue: 1 << 2)
    
    var description: String? {
        switch self {
        case .moveAround:
            return "Move around using your WASD keys."
        case .jump:
            return "Press SPACE to jump."
        case .sprint:
            return "Hold SHIFT while moving around with WASD to sprint."
        default:
            return nil
        }
    }
    
    func makeIterator() -> Iterator {
        Iterator(rawValue: rawValue)
    }
    
    struct Iterator: IteratorProtocol {
        let rawValue: RawValue
        var i: RawValue = 0
        
        mutating func next() -> Achievements? {
            guard i < RawValue.bitWidth else { return nil }
            let bit = (rawValue >> i) & 1
            i += 1
            return Achievements(rawValue: bit)
        }
    }
}
