import SpriteKit
import GameplayKit

func makeCrosshairHUDEntity(size: CGFloat = 20, thickness: CGFloat = 2, at position: CGPoint) -> GKEntity {
    // Create node
    let node = CrosshairHUDNode()
    node.position = position
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    
    return entity
}
