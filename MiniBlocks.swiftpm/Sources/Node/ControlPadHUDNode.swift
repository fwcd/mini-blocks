import SpriteKit

func makeControlPadHUDNode(size: CGFloat) -> SKNode {
    let node = SKShapeNode(circleOfRadius: size * 2)
    node.lineWidth = 0
    node.fillColor = NodeConstants.overlayBackground
    return node
}
