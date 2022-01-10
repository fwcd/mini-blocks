import SpriteKit
import GameplayKit

func makeCrosshairHUDEntity(size: CGFloat = 20, thickness: CGFloat = 2, in frame: CGRect) -> GKEntity {
    // Create node
    let node = makeCrosshairHUDNode(size: size, thickness: thickness)
    node.position = CGPoint(x: frame.midX, y: frame.midY)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    
    return entity
}
