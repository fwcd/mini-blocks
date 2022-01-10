import SpriteKit
import GameplayKit

func makeHUDEntity(size: CGFloat = 20, thickness: CGFloat = 2, in frame: CGRect) -> GKEntity {
    // Create node
    let node = SKNode()
    
    let crosshair = CrosshairHUDNode()
    crosshair.position = CGPoint(x: frame.midX, y: frame.midY)
    node.addChild(crosshair)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    
    return entity
}
