/// The type of world generator used.
public enum WorldGeneratorType: Hashable, Codable, WorldGenerator {
    case empty
    case flat
    case wavyHills
    
    var generator: WorldGenerator {
        switch self {
        case .empty: return EmptyWorldGenerator()
        case .flat: return FlatWorldGenerator()
        case .wavyHills: return WavyHillsWorldGenerator()
        }
    }
    
    func generate(at pos: GridPos2) -> Strip {
        generator.generate(at: pos)
    }
}
