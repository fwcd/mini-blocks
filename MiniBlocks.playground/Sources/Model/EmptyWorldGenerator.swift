/// Generates a void world with no blocks.
struct EmptyWorldGenerator: WorldGenerator {
    func generate(at pos: GridPos2) -> Strip {
        Strip()
    }
}
