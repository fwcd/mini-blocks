/// Represents in-game progress milestones by the player.
struct Achievements: OptionSet {
    let rawValue: UInt64
    
    var descriptions: [String] {
        (0..<UInt64(RawValue.bitWidth))
            .filter { (rawValue >> $0) & 1 == 1 }
            .compactMap {
                switch Achievements(rawValue: $0) {
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
    }
    
    static let moveAround = Self(rawValue: 1 << 0)
    static let jump = Self(rawValue: 1 << 1)
    static let sprint = Self(rawValue: 1 << 2)
}
