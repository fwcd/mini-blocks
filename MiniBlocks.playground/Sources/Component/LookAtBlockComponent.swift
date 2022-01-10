import GameplayKit

/// Makes the associated node as being capable of looking at blocks (which will be highlighted accordingly).
class LookAtBlockComponent: GKComponent {
    private let reachDistance: CGFloat = 10
    private var lastHit: SCNNode? = nil
    
    /// The looked at block pos.
    private(set) var blockPos: GridPos3? = nil
    /// The block pos for a new block.
    private(set) var blockPlacePos: GridPos3? = nil
    
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
        
        lastHit?.filters = nil
        
        let pos = parent.convertPosition(node.position, to: worldNode)
        let facing = parent.convertVector(node.worldFront, to: worldNode)
        let hits = worldNode.hitTestWithSegment(from: pos, to: pos + facing * reachDistance)
        let hit = hits.first
        
        if let filter = CIFilter(name: "CIColorControls") {
            filter.setValue(-0.05, forKey: kCIInputBrightnessKey)
            hit?.node.filters = [filter]
        }
        
        blockPos = hit.map { GridPos3(rounding: $0.node.position) }
        blockPlacePos = hit.map { GridPos3(rounding: $0.node.position + $0.worldNormal) }
        lastHit = hit?.node
    }
}
