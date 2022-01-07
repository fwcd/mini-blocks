import GameplayKit

/// Makes the associated node interactable. This is mainly intended for the world entity.
class PlayerLookAtBlockComponent: GKComponent {
    let worldNode: SCNNode
    
    private let reachDistance: CGFloat = 10
    private var lastHit: SCNNode? = nil
    
    var playerNode: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    init(worldNode: SCNNode) {
        self.worldNode = worldNode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let playerNode = playerNode,
              let playerParent = playerNode.parent else { return }
        
        // Find the node the player looks at and (for demo purposes) lower its opacity
        
        lastHit?.geometry?.materials.first?.diffuse.intensity = 1
        
        let playerPos = playerParent.convertPosition(playerNode.position, to: worldNode)
        let playerFacing = playerParent.convertVector(playerNode.worldFront, to: worldNode)
        let hits = worldNode.hitTestWithSegment(from: playerPos, to: playerPos + playerFacing * reachDistance)
        
        if let hit = hits.first?.node {
            hit.geometry?.materials.first?.diffuse.intensity = 0.5
            lastHit = hit
        }
    }
}
