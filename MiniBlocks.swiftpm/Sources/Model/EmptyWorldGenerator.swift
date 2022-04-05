/// Generates a void world with no blocks.
struct EmptyWorldGenerator: WorldGenerator {
    func generate(at pos: BlockPos2) -> Strip {
        Strip()
    }
}
