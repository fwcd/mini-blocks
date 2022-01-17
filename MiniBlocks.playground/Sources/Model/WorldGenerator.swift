/// A procedural world generator, i.e. a function that generates strips of the world.
protocol WorldGenerator {
    /// Generates a strip/slice of the world.
    func generate(at pos: BlockPos2) -> Strip
}
