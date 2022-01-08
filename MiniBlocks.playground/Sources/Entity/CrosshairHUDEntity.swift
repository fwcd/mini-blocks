import SpriteKit
import GameplayKit

private func makeCrosshairPart(size: CGSize) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: size))
    node.fillColor = .white
    node.strokeColor = .clear
    return node
}

func makeCrosshairHUDEntity(size: CGFloat = 20, thickness: CGFloat = 2, at position: CGPoint) -> GKEntity {
    // Create node
    let node = SKNode()
    node.position = position
    node.addChild(makeCrosshairPart(size: CGSize(width: size, height: thickness)))
    node.addChild(makeCrosshairPart(size: CGSize(width: thickness, height: size)))
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    
    return entity
}
