import SpriteKit

/// A 2D crosshair.
class CrosshairHUDNode: SKShapeNode {
    init(size: CGFloat = 20, thickness: CGFloat = 2) {
        super.init()
        
        addChild(makePart(size: CGSize(width: size, height: thickness)))
        addChild(makePart(size: CGSize(width: thickness, height: size)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    private func makePart(size: CGSize) -> SKNode {
        let node = SKShapeNode(rect: CGRect(center: CGPoint(x: 0, y: 0), size: size))
        node.fillColor = .white
        node.strokeColor = .clear
        return node
    }
}
