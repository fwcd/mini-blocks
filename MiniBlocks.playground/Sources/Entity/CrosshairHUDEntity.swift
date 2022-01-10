import SpriteKit
import GameplayKit

func makePartNode(size: CGSize) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: size))
    node.fillColor = .white
    node.strokeColor = .clear
    return node
}

func makeCrosshairNode(size: CGFloat, thickness: CGFloat) -> SKNode {
    let node = SKNode()
    node.addChild(makePartNode(size: CGSize(width: size, height: thickness)))
    node.addChild(makePartNode(size: CGSize(width: thickness, height: size)))
    return node
}

func makeCrosshairHUDEntity(size: CGFloat = 20, thickness: CGFloat = 2, in frame: CGRect) -> GKEntity {
    // Create node
    let node = makeCrosshairNode(size: size, thickness: thickness)
    node.position = CGPoint(x: frame.midX, y: frame.midY)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    
    return entity
}
