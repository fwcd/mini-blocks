import SceneKit
import GameplayKit

/// Renders the first-person hand (with the held item) for a player.
class HandLoadComponent: GKComponent {
    /// The item last rendered.
    private var lastItem: Item?
    
    private var node: SCNNode? {
        entity?.component(ofType: HandNodeComponent.self)?.node
    }
    
    @WorldActor private var world: World? {
        get { entity?.component(ofType: WorldAssociationComponent.self)?.world }
        set { entity?.component(ofType: WorldAssociationComponent.self)?.world = newValue }
    }
    
    @WorldActor private var playerInfo: PlayerInfo? {
        get { entity?.component(ofType: PlayerAssociationComponent.self)?.playerInfo }
        set { entity?.component(ofType: PlayerAssociationComponent.self)?.playerInfo = newValue }
    }
    
    @WorldActor private var item: Item? {
        playerInfo?.selectedHotbarStack?.item
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        Task.detached { @WorldActor in
            self._update(deltaTime: seconds)
        }
    }
    
    @WorldActor private func _update(deltaTime seconds: TimeInterval) {
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
    
    /// Schedules a 'swing' animation indicating that e.g. a block was placed/broken.
    func swing() {
        let halfDuration = 0.15
        node?.runAction(.sequence([
            .group([
                .move(by: SCNVector3(x: 0, y: 0, z: -2), duration: halfDuration),
                .rotateBy(x: 0, y: 1, z: 1, duration: halfDuration),
            ]),
            .group([
                .move(to: SCNVector3(x: 0, y: 0, z: 0), duration: halfDuration),
                .rotateTo(x: 0, y: 0, z: 0, duration: halfDuration),
            ]),
        ]))
    }
}

