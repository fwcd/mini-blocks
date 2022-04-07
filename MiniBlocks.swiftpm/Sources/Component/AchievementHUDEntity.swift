import SpriteKit
import GameplayKit

func makeAchievementHUDEntity(
    in frame: CGRect,
    playerEntity: GKEntity,
    fontSize: CGFloat = 14,
    usesMouseKeyboardControls: Box<Bool>
) -> GKEntity {
    // Create node
    let node = SKNode()
    node.position = CGPoint(x: frame.midX, y: frame.maxY - 20)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    entity.addComponent(PlayerAssociationComponent(playerEntity: playerEntity))
    entity.addComponent(MouseCaptureVisibilityComponent(visibleWhenCaptured: true))
    entity.addComponent(AchievementHUDLoadComponent(fontSize: fontSize, usesMouseKeyboardControls: usesMouseKeyboardControls))
    
    if let worldEntity = playerEntity.component(ofType: WorldAssociationComponent.self)?.worldEntity {
        entity.addComponent(WorldAssociationComponent(worldEntity: worldEntity))
    }
    
    return entity
}
