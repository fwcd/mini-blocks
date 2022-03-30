import SpriteKit

private func makeBackgroundNode(size: CGSize) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: size))
    node.strokeColor = .clear
    node.lineWidth = 0
    node.fillColor = .black.withAlphaComponent(0.95)
    return node
}

private func makeLabelNode(text: String, offset: CGFloat = 0, fontSize: CGFloat) -> SKNode {
    let node = SKLabelNode(text: text)
    node.fontSize = fontSize
    node.fontColor = .white
    node.fontName = NodeConstants.fontName
    node.position = CGPoint(x: 0, y: offset)
    return node
}

func makeAchievementHUDNode(for achievement: Achievements, size: CGSize, fontSize: CGFloat) -> SKNode? {
    guard let text = achievement.text else { return nil }
    let node = SKNode()
    let label = makeLabelNode(text: text, fontSize: fontSize)
    node.addChild(makeBackgroundNode(size: size))
    node.addChild(label)
    return node
}
