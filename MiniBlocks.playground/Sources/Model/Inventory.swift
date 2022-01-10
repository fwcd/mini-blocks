/// An ordered container for items.
struct Inventory: Codable, Sequence {
    var items: [Item] = []
    
    func makeIterator() -> Array<Item>.Iterator {
        items.makeIterator()
    }
}
