/// The type of world generator used.
public enum WorldGeneratorType: Hashable, Codable, WorldGenerator {
    case empty
    case flat
    case wavyHills
    case ocean
    case nature
    
    var generator: WorldGenerator {
        switch self {
        case .empty: return EmptyWorldGenerator()
        case .flat: return FlatWorldGenerator()
        case .wavyHills: return WavyHillsWorldGenerator()
        case .ocean: return OceanWorldGenerator()
        case .nature: return NatureWorldGenerator()
        }
    }
    
    func generate(at pos: GridPos2) -> Strip {
        generator.generate(at: pos)
    }
}
