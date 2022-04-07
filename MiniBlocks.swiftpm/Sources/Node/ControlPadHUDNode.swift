import SpriteKit

private func makeControlPadHUDStickNode(size: CGFloat) -> SKNode {
    let node = SKShapeNode(circleOfRadius: size * 2)
    node.lineWidth = 0
    node.fillColor = NodeConstants.foregroundColor.withAlphaComponent(0.8)
    node.userData = ["isControlPadStick": true]
    return node
}

func makeControlPadHUDNode(size: CGFloat) -> SKNode {
    let node = SKShapeNode(circleOfRadius: size * 2)
    node.lineWidth = 0
    node.fillColor = NodeConstants.overlayBackground
    node.addChild(makeControlPadHUDStickNode(size: size / 3))
    return node
}
