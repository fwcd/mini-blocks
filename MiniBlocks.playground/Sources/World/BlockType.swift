/// A 'kind' of block.
enum BlockType: Int, Hashable, Codable {
    case grass = 0
    case sand
    case stone
    case water
}
