import Foundation

/// Generates a world from a periodic wave pattern.
struct WavyHillsWorldGenerator: WorldGenerator {
    func generate(at pos: GridPos2) -> Strip {
        let y = Int((-5 * sin(CGFloat(pos.x) / 10) * cos(CGFloat(pos.z) / 10)).rounded())
        return Strip(blocks: [y: Block(type: .grass)])
    }
}
