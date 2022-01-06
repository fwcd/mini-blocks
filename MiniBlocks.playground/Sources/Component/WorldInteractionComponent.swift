import GameplayKit

/// Makes the associated node interactable. This is mainly intended for the world entity.
class WorldInteractionComponent: GKComponent {
    let playerNode: SCNNode
    
    var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    init(playerNode: SCNNode) {
        self.playerNode = playerNode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let playerParent = playerNode.parent,
              let node = node else { return }
//        let playerPos = playerParent.convertPosition(playerNode.position, to: node)
//        let playerFacing = playerParent.convertVector(playerNode.worldFront, to: <#T##SCNNode?#>)
//        node.hitTestWithSegment(from: playerPos, to: playerNode.fac)
    }
}
