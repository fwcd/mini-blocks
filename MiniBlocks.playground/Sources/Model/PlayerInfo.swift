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
    /// The position of the player.
    var position: Vec3 = .zero
    /// The velocity of the player.
    var velocity: Vec3 = .zero
    /// Whether the player is on the ground.
    var isOnGround: Bool = false
    /// Whether the player is about to leave the ground (e.g. due to a jump).
    var leavesGround: Bool = false
    /// The game mode the player is in.
    var gameMode: GameMode = .creative
    /// Whether the player has the debug overlay enabled.
    var hasDebugHUDEnabled: Bool = false
    
    /// The currently selected stack on the hotbar.
    var selectedHotbarStack: ItemStack? {
        get { hotbar[selectedHotbarSlot] }
        set { hotbar[selectedHotbarSlot] = newValue }
    }
    
    init() {
        // TODO: This is only for debugging purposes
        hotbar[0] = ItemStack(item: Item(type: .block(.grass)))
        hotbar[1] = ItemStack(item: Item(type: .block(.sand)))
        hotbar[2] = ItemStack(item: Item(type: .block(.stone)))
        hotbar[3] = ItemStack(item: Item(type: .block(.wood)))
        hotbar[4] = ItemStack(item: Item(type: .block(.leaves)))
    }
    
    mutating func applyVelocity() {
        position += velocity
    }
}
