/// Generates a flat grass world.
struct FlatWorldGenerator: WorldGenerator {
    func generate(at pos: BlockPos2) -> Strip {
        Strip(blocks: [0: Block(type: .grass)])
    }
}
