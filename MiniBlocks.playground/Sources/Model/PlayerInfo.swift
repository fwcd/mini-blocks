import SceneKit

/// Information about a player.
struct PlayerInfo: Codable, Hashable {
    /// The player's main inventory.
    var inventory: Inventory = Inventory(slotCount: 24)
    /// The player's hotbar.
    var hotbar: Inventory = Inventory(slotCount: 8)
    /// The hotbar slot index which is currently active.
    private(set) var selectedHotbarSlot: Int = 0
    
    // TODO: Store player position?
    
    mutating func moveHotbarSelection(by delta: Int) {
        // TODO: Proper modulo
        selectedHotbarSlot = (selectedHotbarSlot + delta) % hotbar.slotCount
    }
}
