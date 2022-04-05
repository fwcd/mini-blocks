/// Represents in-game progress milestones by the player.
struct Achievements: OptionSet, Sequence, Hashable, Codable {
    let rawValue: UInt64
    
    static let peekAround = Self(rawValue: 1 << 0)
    static let moveAround = Self(rawValue: 1 << 1)
    static let jump = Self(rawValue: 1 << 2)
    static let sprint = Self(rawValue: 1 << 3)
    static let hotbar = Self(rawValue: 1 << 4)
    static let useBlock = Self(rawValue: 1 << 5)
    static let breakBlock = Self(rawValue: 1 << 6)
    
    /// The achievements a new player is tasked with.
    static let root = peekAround
    
    /// Whether this is a single achivement.
    var isSingle: Bool {
        rawValue > 0 && (rawValue & (rawValue - 1)) == 0
    }
    
    /// The user-facing text for a single achievement.
    var text: String? {
        switch self {
        #if canImport(UIKit)
        case .peekAround: return "Peek around by panning the screen's right half."
        case .moveAround: return "Move around by panning the screen's left half."
        case .jump: return "Tap to jump."
        case .sprint: return nil // TODO: Implement sprint on iOS
        case .hotbar: return nil // TODO: Implement hotbar on iOS
        case .useBlock: return nil // TODO: Implement block placement on iOS
        case .breakBlock: return "Break a block by holding your finger."
        #else
        case .peekAround: return "Peek around by moving your mouse."
        case .moveAround: return "Move around using your WASD keys."
        case .jump: return "Press SPACE to jump."
        case .sprint: return "Hold SHIFT while moving around with WASD to sprint."
        case .hotbar: return "Scroll or press number keys to switch the held item."
        case .useBlock: return "Place a block by clicking/holding your right mouse button."
        case .breakBlock: return "Break a block by clicking/holding your left mouse button."
        #endif
        default: return nil
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
        case .peekAround: return .moveAround
        case .moveAround: return .jump
        // TODO: Remove this cond-compile once sprint and hotbar are implemented on iOS
        #if canImport(UIKit)
        case .jump: return .breakBlock
        #else
        case .jump: return .sprint
        #endif
        case .sprint: return .hotbar
        case .hotbar: return .useBlock
        case .useBlock: return .breakBlock
        default: return []
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
