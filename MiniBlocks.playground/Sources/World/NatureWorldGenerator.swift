import GameplayKit

private let noise = GKNoise(GKPerlinNoiseSource())

/// Generates a world with realistic terrain and natural features.
struct NatureWorldGenerator: WorldGenerator {
    var amplitude: Float = 8
    var scale: Float = 80
    
    func generate(at pos: GridPos2) -> Strip {
        let y = Int(amplitude * noise.value(atPosition: vector_float2(x: Float(pos.x) / scale, y: Float(pos.z) / scale)))
        return Strip(blocks: [y: Block(type: .grass)])
    }
}
