import SpriteKit
import GameplayKit

func makeCrosshairHUDEntity(size: CGFloat = 20, thickness: CGFloat = 2, in frame: CGRect) -> GKEntity {
    // Create node
    let node = CrosshairHUDNode()
    node.position = CGPoint(x: frame.midX, y: frame.midY)
    node.addChild(node)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    
    return entity
}
