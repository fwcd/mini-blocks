import GameplayKit

/// Makes the associated node interactable. This is mainly intended for the world entity.
class WorldInteractionComponent: GKComponent {
    let playerNode: SCNNode
    
    private let reachDistance: CGFloat = 10
    private var lastHit: SCNNode? = nil
    
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
        
        // Find the node the player looks at and (for demo purposes) lower its opacity
        
        lastHit?.geometry?.materials.first?.diffuse.intensity = 1
        
        let playerPos = playerParent.convertPosition(playerNode.position, to: node)
        let playerFacing = playerParent.convertVector(playerNode.worldFront, to: node)
        let hits = node.hitTestWithSegment(from: playerPos, to: playerPos + playerFacing * reachDistance)
        
        if let hit = hits.first?.node {
            hit.geometry?.materials.first?.diffuse.intensity = 0.5
            lastHit = hit
        }
    }
}
