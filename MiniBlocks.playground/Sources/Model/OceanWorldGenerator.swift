/// Generates a world that predominantly consists of water.
struct OceanWorldGenerator: WorldGenerator {
    var depth: Int = 8
    
    func generate(at pos: BlockPos2) -> Strip {
        let blocks = Array(repeating: Block(type: .water), count: depth) + [Block(type: .stone)]
        return Strip(blocks: Dictionary(uniqueKeysWithValues: blocks.enumerated().map { (i, b) in (-i, b) }))
    }
}
