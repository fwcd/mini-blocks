import SpriteKit
import GameplayKit

func makeCrosshairHUDEntity(size: CGFloat = 20, thickness: CGFloat = 2, in frame: CGRect) -> GKEntity {
    // Create node
    let node = makeCrosshairHUDNode(size: size, thickness: thickness)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    entity.addComponent(MouseCaptureVisibilityComponent(visibleWhenCaptured: true))
    entity.addComponent(CrosshairHUDPositioningComponent())
    
    return entity
}
