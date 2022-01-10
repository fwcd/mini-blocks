import SpriteKit

class HotbarHUDNode: SKNode {
    override init() {
        super.init()
        
        // DEBUG
        let shape = SKShapeNode(circleOfRadius: 50)
        shape.fillColor = .black
        shape.strokeColor = .clear
        addChild(shape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
