import SpriteKit

func makeHotbarHUDSlotNode(size: CGFloat) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: CGSize(width: size, height: size)))
    node.strokeColor = .black
    node.lineWidth = 2
    node.fillColor = .black.withAlphaComponent(0.7)
    return node
}
