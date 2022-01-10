import SceneKit

/// Information about a player.
struct PlayerInfo: Codable, Hashable {
    /// The player's main inventory.
    var inventory: Inventory = Inventory()
    /// The player's hotbar.
    var hotbar: Inventory = Inventory()
    
    // TODO: Store player position?
}
