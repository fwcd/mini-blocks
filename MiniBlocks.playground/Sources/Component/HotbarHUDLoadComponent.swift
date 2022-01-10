import SpriteKit
import GameplayKit

/// Renders the hotbar for a player from the world model to a SpriteKit node.
class HotbarHUDLoadComponent: GKComponent {
    /// The inventory last rendered to a SpriteKit node.
    private var lastInventory: Inventory?
    /// The slot selection last rendered to a SpriteKit node.
    private var lastSelectedHotbarSlot: Int?
    
    private var selectedSlotLineThickness: CGFloat = 4
    private var normalSlotLineThickness: CGFloat = 2
    
    private var node: SKNode? {
        entity?.component(ofType: SpriteNodeComponent.self)?.node
    }
    
    private var world: World? {
        get { entity?.component(ofType: WorldAssociationComponent.self)?.world }
        set { entity?.component(ofType: WorldAssociationComponent.self)?.world = newValue }
    }
    
    private var playerName: String? {
        entity?.component(ofType: PlayerAssociationComponent.self)?.playerName
    }
    
    private var playerInfo: PlayerInfo? {
        get { playerName.flatMap { world?[playerInfoFor: $0] } }
        set {
            guard let playerName = playerName else { return }
            world?[playerInfoFor: playerName] = newValue!
        }
    }
    
    private var inventory: Inventory? {
        get { playerInfo?.hotbar }
        set { playerInfo?.hotbar = newValue! }
    }
    
    private var hasChanged: Bool {
        inventory != lastInventory || playerInfo?.selectedHotbarSlot != lastSelectedHotbarSlot
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard hasChanged, let node = node else { return }
        
        // TODO: Delta updates?
        node.removeAllChildren()
        
        if let inventory = inventory {
            let slotSize: CGFloat = 40
            let itemSize: CGFloat = slotSize * 0.8
            let width = CGFloat(inventory.slotCount) * slotSize
            
            for i in 0..<inventory.slotCount {
                let lineThickness = slotLineThickness(for: i)
                let slotNode = makeHotbarHUDSlotNode(size: slotSize, lineThickness: lineThickness)
                slotNode.position = CGPoint(x: (CGFloat(i) * slotSize) - (width / 2) + (slotSize / 2), y: slotSize / 2)
                if let stack = inventory[i] {
                    // TODO: Render stack count
                    slotNode.addChild(makeItemNode(for: stack.item, size: itemSize))
                }
                node.addChild(slotNode)
            }
        }
        
        lastInventory = inventory
    }
    
    private func slotLineThickness(for i: Int) -> CGFloat {
        playerInfo?.selectedHotbarSlot == i ? selectedSlotLineThickness : normalSlotLineThickness
    }
}
