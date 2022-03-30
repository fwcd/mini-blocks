/// Represents in-game progress milestones by the player.
struct Achievements: OptionSet, Sequence, Hashable, Codable {
    let rawValue: UInt64
    
    static let peekAround = Self(rawValue: 1 << 0)
    static let moveAround = Self(rawValue: 1 << 1)
    static let jump = Self(rawValue: 1 << 2)
    static let sprint = Self(rawValue: 1 << 3)
    
    /// The achievements a new player is tasked with.
    static let root = peekAround
    
    /// Whether this is a single achivement.
    var isSingle: Bool {
        rawValue > 0 && (rawValue & (rawValue - 1)) == 0
    }
    
    /// The user-facing text for a single achievement.
    var text: String? {
        switch self {
        case .peekAround:
            return "Peek around by moving your mouse."
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
    
    /// The next achivements.
    var next: Achievements {
        if self == [] {
            return .root
        }
        guard isSingle else {
            return flatMap(\.next)
                .filter { !contains($0) }
                .reduce([]) { $0.union($1) }
        }
        
        switch self {
        case .peekAround:
            return .moveAround
        case .moveAround:
            return .jump
        case .jump:
            return .sprint
        default:
            return []
        }
    }
    
    func makeIterator() -> Iterator {
        Iterator(rawValue: rawValue)
    }
    
    struct Iterator: IteratorProtocol {
        let rawValue: RawValue
        var i: RawValue = 0
        
        mutating func next() -> Achievements? {
            while i < RawValue.bitWidth {
                let bitIndex = i
                i += 1
                let bit = (rawValue >> bitIndex) & 1 == 1
                if bit {
                    return Achievements(rawValue: 1 << bitIndex)
                }
            }
            return nil
        }
    }
}
