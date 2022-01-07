import GameplayKit

/// Makes the associated node as being capable of looking at blocks (which will be highlighted accordingly).
class LookAtBlockComponent: GKComponent {
    private let reachDistance: CGFloat = 10
    private var lastHit: SCNNode? = nil
    
    var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    var worldNode: SCNNode? {
        entity?.component(ofType: WorldAssociationComponent.self)?.worldNode
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              let parent = node.parent,
              let worldNode = worldNode else { return }
        
        // Find the node the player looks at and (for demo purposes) lower its opacity
        
        lastHit?.geometry?.materials.first?.diffuse.intensity = 1
        
        let pos = parent.convertPosition(node.position, to: worldNode)
        let facing = parent.convertVector(node.worldFront, to: worldNode)
        let hits = worldNode.hitTestWithSegment(from: pos, to: pos + facing * reachDistance)
        
        if let hit = hits.first?.node {
            hit.geometry?.materials.first?.diffuse.intensity = 0.5
            lastHit = hit
        }
    }
}