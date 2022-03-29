import SpriteKit

private func makePartNode(size: CGSize) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: size))
    node.fillColor = .white
    node.strokeColor = .clear
    return node
}

func makeCrosshairHUDNode(size: CGFloat, thickness: CGFloat) -> SKNode {
    let node = SKNode()
    node.addChild(makePartNode(size: CGSize(width: size, height: thickness)))
    node.addChild(makePartNode(size: CGSize(width: thickness, height: size)))
    return node
}
