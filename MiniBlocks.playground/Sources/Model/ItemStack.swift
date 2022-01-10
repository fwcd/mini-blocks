struct ItemStack: Codable, Hashable {
    var item: Item
    var count: Int = 1
}
