import GameplayKit

/// Generates a world with realistic terrain and natural features.
struct NatureWorldGenerator: WorldGenerator {
    private let heightNoise: GKNoise
    
    var amplitude: Float = 8
    var scale: Float = 80
    var sandLevel: Int = 0
    var waterLevel: Int = -1
    
    init(seed: String) {
        let noiseSeed: Int32 = seed.utf8.reduce(0) { ($0 << 1) ^ Int32($1) }
        
        heightNoise = GKNoise(GKPerlinNoiseSource(
            frequency: 1,
            octaveCount: 10,
            persistence: 0.8,
            lacunarity: 1.2,
            seed: noiseSeed
        ))
    }
    
    func generate(at pos: GridPos2) -> Strip {
        let y = Int(amplitude * heightNoise.value(atPosition: vector_float2(x: Float(pos.x) / scale, y: Float(pos.z) / scale)))
        let blocks: [Int: Block]
        
        if y > sandLevel {
            blocks = [y: Block(type: .grass)]
        } else if y >= waterLevel {
            blocks = [y: Block(type: .sand), y - 1: Block(type: .stone)]
        } else {
            blocks = Dictionary(uniqueKeysWithValues: (y...waterLevel).map { ($0, Block(type: .water)) } + [(y - 1, Block(type: .stone))])
        }
                              
        return Strip(blocks: blocks)
    }
}
