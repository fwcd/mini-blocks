import Foundation

/// Generates a world from a periodic wave pattern.
struct WavyHillsWorldGenerator: WorldGenerator {
    func generate(at pos: BlockPos2) -> Strip {
        let y = Int((-5 * sin(Float(pos.x) / 10) * cos(Float(pos.z) / 10)).rounded())
        return Strip(blocks: [y: Block(type: .grass)])
    }
}
