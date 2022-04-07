import SpriteKit

private func makeBackgroundNode(size: CGSize) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: size))
    node.strokeColor = .clear
    node.lineWidth = 0
    node.fillColor = .black.withAlphaComponent(0.92)
    return node
}

private func makeLabelNode(text: String, offset: CGFloat = 0, fontSize: CGFloat) -> SKNode {
    let node = SKLabelNode(text: text)
    node.fontSize = fontSize
    node.fontColor = NodeConstants.foregroundColor
    node.fontName = NodeConstants.fontName
    node.verticalAlignmentMode = .center
    node.position = CGPoint(x: 0, y: offset)
    return node
}

func makePauseHUDNode(size: CGSize, fontSize: CGFloat) -> SKNode {
    let node = SKNode()
    node.addChild(makeBackgroundNode(size: size))
    node.addChild(makeLabelNode(text: "Click to capture mouse!", fontSize: fontSize))
    node.addChild(makeLabelNode(text: "(Press Esc to exit)", offset: -1.4 * fontSize, fontSize: fontSize * 0.8))
    return node
}

