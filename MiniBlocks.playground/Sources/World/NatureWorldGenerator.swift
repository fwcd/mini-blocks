import GameplayKit

/// Generates a world with realistic terrain and natural features.
struct NatureWorldGenerator: WorldGenerator {
    private let heightNoise: GKNoise
    
    var amplitude: Float = 8
    var scale: Float = 80
    var sandLevel: Int = 0
    var waterLevel: Int = -1
    var treeBaseHeight: Int = 5
    var leavesBaseHeight: Int = 2
    
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
            let height = treeHeight(at: pos)
            for i in 1...height {
                blocks[y + i] = Block(type: .wood)
            }
            blocks[y + height + 1] = Block(type: .leaves)
        } else if let treePos = pos.neighbors.first(where: isTree(at:)) {
            for i in 0..<leavesHeight(at: treePos) {
                blocks[terrainHeight(at: treePos) + treeHeight(at: treePos) - i] = Block(type: .leaves)
            }
        }
                              
        return Strip(blocks: blocks)
    }
    
    private func terrainHeight(at pos: GridPos2) -> Int {
        Int(amplitude * heightNoise.value(atPosition: vectorOf(pos: pos)))
    }
    
    private func treeHeight(at pos: GridPos2) -> Int {
        treeBaseHeight + min(3, ((((pos.x) << 1) % 10) ^ ((pos.z << 4) % 9)) % 4)
    }
    
    private func leavesHeight(at pos: GridPos2) -> Int {
        max(0, leavesBaseHeight + (pos.x ^ pos.z) % 2)
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
