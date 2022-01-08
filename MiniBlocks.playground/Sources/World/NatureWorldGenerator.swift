import GameplayKit

/// Generates a world with realistic terrain and natural features.
struct NatureWorldGenerator: WorldGenerator {
    private let noise: GKNoise
    var amplitude: Float = 8
    var scale: Float = 80
    
    init(seed: String) {
        noise = GKNoise(GKPerlinNoiseSource(
            frequency: 1,
            octaveCount: 10,
            persistence: 0.8,
            lacunarity: 1.2,
            seed: seed.utf8.reduce(0) { ($0 << 1) ^ Int32($1) }
        ))
    }
    
    func generate(at pos: GridPos2) -> Strip {
        let y = Int(amplitude * noise.value(atPosition: vector_float2(x: Float(pos.x) / scale, y: Float(pos.z) / scale)))
        return Strip(blocks: [y: Block(type: .grass)])
    }
}
