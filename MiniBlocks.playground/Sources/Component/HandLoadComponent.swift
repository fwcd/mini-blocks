import SceneKit
import GameplayKit

/// Renders the first-person hand (with the held item) for a player.
class HandLoadComponent: GKComponent {
    /// The item last rendered.
    private var lastItem: Item?
    
    private var node: SCNNode? {
        entity?.component(ofType: HandNodeComponent.self)?.node
    }
    
    private var world: World? {
        get { entity?.component(ofType: WorldAssociationComponent.self)?.world }
        set { entity?.component(ofType: WorldAssociationComponent.self)?.world = newValue }
    }
    
    private var playerInfo: PlayerInfo? {
        get { entity?.component(ofType: PlayerAssociationComponent.self)?.playerInfo }
        set { entity?.component(ofType: PlayerAssociationComponent.self)?.playerInfo = newValue }
    }
    
    private var item: Item? {
        playerInfo?.selectedHotbarStack?.item
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              lastItem != item else { return }
        
        for child in node.childNodes {
            child.removeFromParentNode()
        }
        
        if let item = item {
            switch item.type {
            case .block(let blockType):
                let block = makeBlockNode(for: Block(type: blockType))
                block.position = SCNVector3(x: 1.5, y: -1, z: -2.5)
                node.addChildNode(block)
            }
        }
        
        lastItem = item
    }
}

