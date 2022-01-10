/// An ordered container for items.
struct Inventory: Codable, Hashable, Sequence {
    private(set) var slots: [Int: ItemStack] = [:]
    let slotCount: Int
    
    // TODO: Enforce slot count?
    
    init(slotCount: Int) {
        self.slotCount = slotCount
    }
    
    subscript(i: Int) -> ItemStack? {
        get { slots[i] }
        set { slots[i] = newValue }
    }
    
    func makeIterator() -> Dictionary<Int, ItemStack>.Iterator {
        slots.makeIterator()
    }
}
