import SceneKit

/// Information about a player.
struct PlayerInfo: Codable, Hashable {
    /// The player's main inventory.
    var inventory: Inventory = Inventory(slotCount: 24)
    /// The player's hotbar.
    var hotbar: Inventory = Inventory(slotCount: 8)
    /// The hotbar slot index which is currently active.
    var selectedHotbarSlot: Int = 0
    
    // TODO: Store player position?
}
