import SceneKit

/// Information about a player.
struct PlayerInfo: Codable, Hashable {
    /// The player's main inventory.
    var inventory: Inventory = Inventory(slotCount: 18)
    /// The player's hotbar.
    var hotbar: Inventory = Inventory(slotCount: 6)
    
    // TODO: Store player position?
}
