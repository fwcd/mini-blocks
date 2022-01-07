/// Generates a flat grass world.
struct FlatWorldGenerator: WorldGenerator {
    func generate(at pos: GridPos2) -> Strip {
        Strip(blocks: [0: Block(type: .grass)])
    }
}
