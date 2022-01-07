import SpriteKit
import GameplayKit

func makeCrosshairHUDEntity(size: CGFloat = 20, at position: CGPoint) -> GKEntity {
    // Create node
    let node = SKShapeNode(circleOfRadius: size)
    node.fillColor = .black
    node.strokeColor = .clear
    node.position = position
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    
    return entity
}
