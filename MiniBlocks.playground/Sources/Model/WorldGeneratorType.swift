import Foundation

private var cache = [WorldGeneratorType: WorldGenerator]()

/// The type of world generator used.
public enum WorldGeneratorType: Hashable, Codable, WorldGenerator {
    case empty
    case flat
    case wavyHills
    case ocean
    case nature(seed: String)
    
    var generator: WorldGenerator {
        if let generator = cache[self] {
            return generator
        } else {
            let generator: WorldGenerator
            switch self {
            case .empty: generator = EmptyWorldGenerator()
            case .flat: generator = FlatWorldGenerator()
            case .wavyHills: generator = WavyHillsWorldGenerator()
            case .ocean: generator = OceanWorldGenerator()
            case .nature(let seed): generator = NatureWorldGenerator(seed: seed)
            }
            cache[self] = generator
            return generator
        }
    }
    
    func generate(at pos: BlockPos2) -> Strip {
        generator.generate(at: pos)
    }
}
