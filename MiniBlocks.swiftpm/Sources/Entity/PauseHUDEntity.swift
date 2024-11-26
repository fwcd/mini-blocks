import SpriteKit
import GameplayKit

func makePauseHUDEntity(in frame: CGRect, fontSize: CGFloat = 28) -> GKEntity {
    // Create node
    let node = makePauseHUDNode(size: frame.size, fontSize: fontSize)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    entity.addComponent(MouseCaptureVisibilityComponent(visibleWhenCaptured: false))
    entity.addComponent(PauseHUDPositioningComponent())
    
    return entity
}
