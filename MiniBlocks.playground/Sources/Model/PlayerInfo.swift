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
    
    // TODO: Store player position?
}
