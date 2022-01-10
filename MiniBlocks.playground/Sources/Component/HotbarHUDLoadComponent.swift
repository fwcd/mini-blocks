import SpriteKit
import GameplayKit

/// Renders the hotbar for a player from the world model to a SpriteKit node.
class HotbarHUDLoadComponent: GKComponent {
    /// The inventory last rendered to a SpriteKit node.
    private var lastInventory: Inventory?
    
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
    
    private var inventory: Inventory? {
        get { playerName.flatMap { world?.playerInfos[$0]?.hotbar } }
        set {
            guard world != nil, let playerName = playerName else { return }
            world!.playerInfos[playerName]?.hotbar = newValue!
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard inventory != lastInventory, let node = node else { return }
        
        // TODO: Delta updates?
        node.removeAllChildren()
        
        if let inventory = inventory {
            let slotSize: CGFloat = 80
            let width = CGFloat(inventory.slotCount) * slotSize
            
            for i in 0..<inventory.slotCount {
                let slotNode = makeHotbarHUDSlotNode(size: slotSize)
                slotNode.position = CGPoint(x: (CGFloat(i) * slotSize) - (width / 2), y: 0)
                node.addChild(slotNode)
            }
        }
    }
}
