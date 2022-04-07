import SpriteKit

private func makeBackgroundNode(size: CGSize) -> SKNode {
    let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: size))
    node.strokeColor = .clear
    node.lineWidth = 0
    node.fillColor = NodeConstants.overlayBackground
    return node
}

private func makeLabelNode(text: String, offset: CGFloat = 0, fontSize: CGFloat) -> SKNode {
    let node = SKLabelNode(text: text)
    node.fontSize = fontSize
    node.fontColor = .white
    node.fontName = NodeConstants.fontName
    node.verticalAlignmentMode = .center
    node.position = CGPoint(x: 0, y: offset)
    return node
}

func makeAchievementHUDNode(for achievement: Achievements, forMouseKeyboardControls: Bool, fontSize: CGFloat, padding: CGFloat = 10) -> SKNode? {
    guard let text = achievement.text(forMouseKeyboardControls: forMouseKeyboardControls) else { return nil }
    let node = SKNode()
    let label = makeLabelNode(text: text, fontSize: fontSize)
    let labelSize = label.frame.size
    node.addChild(makeBackgroundNode(size: CGSize(width: labelSize.width + padding, height: labelSize.height + padding)))
    node.addChild(label)
    return node
}
