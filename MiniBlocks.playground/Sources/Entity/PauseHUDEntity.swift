import SpriteKit
import GameplayKit

func makePauseHUDEntity(in frame: CGRect, fontSize: CGFloat = 28) -> GKEntity {
    // Create node
    let node = makePauseHUDNode(size: frame.size, fontSize: fontSize)
    node.position = CGPoint(x: frame.midX, y: frame.midY)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    entity.addComponent(MouseCaptureVisibilityComponent(visibleWhenCaptured: false))
    
    return entity
}
