import GameplayKit

/// Generates a world with realistic terrain and natural features.
struct NatureWorldGenerator: WorldGenerator {
    private let heightNoise: GKNoise
    
    var amplitude: Float = 8
    var scale: Float = 80
    var sandLevel: Int = 0
    var waterLevel: Int = -1
    var treeHeight: Int = 5
    
    init(seed: String) {
        let noiseSeed: Int32 = seed.utf8.reduce(0) { ($0 << 1) ^ Int32($1) }
        
        heightNoise = GKNoise(GKPerlinNoiseSource(
            frequency: 1.2,
            octaveCount: 12,
            persistence: 0.8,
            lacunarity: 1.2,
            seed: noiseSeed
        ))
    }
    
    func generate(at pos: GridPos2) -> Strip {
        var blocks: [Int: Block]
        
        // Generate terrain
        let y = terrainHeight(at: pos)
        if y > sandLevel {
            blocks = [y: Block(type: .grass)]
        } else if y >= waterLevel {
            blocks = [y: Block(type: .sand), y - 1: Block(type: .stone)]
        } else {
            blocks = Dictionary(uniqueKeysWithValues: (y...waterLevel).map { ($0, Block(type: .water)) } + [(y - 1, Block(type: .stone))])
        }
        
        // Generate trees
        if isTree(at: pos) {
            for i in 1...treeHeight {
                blocks[y + i] = Block(type: .wood)
            }
        } else if isTree(at: pos + GridPos2(x: 1))
               || isTree(at: pos - GridPos2(x: 1))
               || isTree(at: pos + GridPos2(z: 1))
               || isTree(at: pos - GridPos2(z: 1)) {
            blocks[y + treeHeight] = Block(type: .leaves)
        }
                              
        return Strip(blocks: blocks)
    }
    
    private func terrainHeight(at pos: GridPos2) -> Int {
        Int(amplitude * heightNoise.value(atPosition: vectorOf(pos: pos)))
    }
    
    private func isTree(at pos: GridPos2) -> Bool {
        guard terrainHeight(at: pos) > sandLevel else { return false }
        let x = ((pos.x % 30) << 1) ^ pos.z % 100
        return x == 23
    }
    
    private func vectorOf(pos: GridPos2) -> vector_float2 {
        vector_float2(x: Float(pos.x) / scale, y: Float(pos.z) / scale)
    }
}
