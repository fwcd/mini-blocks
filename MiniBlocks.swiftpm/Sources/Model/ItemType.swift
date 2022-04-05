/// A 'kind' of item.
enum ItemType: Codable, Hashable {
    case block(BlockType)
}
