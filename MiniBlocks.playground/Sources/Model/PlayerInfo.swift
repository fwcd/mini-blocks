import SceneKit

/// Information about a player.
struct PlayerInfo: Codable, Hashable {
    /// The player's main inventory.
    var inventory: Inventory = Inventory(slotCount: InventoryConstants.inventorySlotCount)
    /// The player's hotbar.
    var hotbar: Inventory = Inventory(slotCount: InventoryConstants.hotbarSlotCount)
    /// The hotbar slot index which is currently active.
    @Wraparound(modulus: InventoryConstants.hotbarSlotCount)
    var selectedHotbarSlot: Int = 0
    
    init() {
        // TODO: This is only for debugging purposes
        hotbar[0] = ItemStack(item: Item(type: .block(.grass)))
        hotbar[1] = ItemStack(item: Item(type: .block(.sand)))
        hotbar[2] = ItemStack(item: Item(type: .block(.stone)))
        hotbar[3] = ItemStack(item: Item(type: .block(.wood)))
        hotbar[4] = ItemStack(item: Item(type: .block(.leaves)))
    }
    
    // TODO: Store player position?
}
