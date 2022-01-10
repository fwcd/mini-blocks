import SpriteKit

func makeHotbarHUDSlotNode(size: CGFloat, lineThickness: CGFloat) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: CGSize(width: size, height: size)))
    node.strokeColor = .black
    node.lineWidth = lineThickness
    node.lineJoin = .bevel
    node.fillColor = .black.withAlphaComponent(0.7)
    return node
}

func updateHotbarHUDSlotNode(_ node: SKNode, lineThickness: CGFloat?) {
    guard let node = node as? SKShapeNode else { return }
    
    if let lineThickness = lineThickness {
        node.lineWidth = lineThickness
    }
}
