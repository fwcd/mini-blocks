import SpriteKit
import GameplayKit

func makeHotbarHUDEntity(in frame: CGRect) -> GKEntity {
    // Create node
    let node = HotbarHUDNode()
    node.position = CGPoint(x: frame.midX, y: frame.minY)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    
    return entity
}
