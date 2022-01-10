import SpriteKit

func makeHotbarHUDSlotNode(size: CGFloat) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: CGSize(width: size, height: size)))
    node.strokeColor = .clear
    node.fillColor = .black.withAlphaComponent(0.5)
    return node
}
