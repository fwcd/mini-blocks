import SpriteKit

private func makeBackgroundNode(size: CGSize) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: size))
    node.strokeColor = .clear
    node.lineWidth = 0
    node.fillColor = .black.withAlphaComponent(0.9)
    return node
}

func makePauseHUDNode(size: CGSize, fontSize: CGFloat) -> SKNode {
    let node = SKNode()
    node.addChild(makeBackgroundNode(size: size))
    // TODO: Text
    return node
}

