import SpriteKit
import GameplayKit

func makeControlPadHUDEntity(in frame: CGRect, playerEntity: GKEntity, size: CGFloat = 100) -> GKEntity {
    // Create node
    let node = makeControlPadHUDNode(size: size)
    node.position = CGPoint(x: frame.minX + 0.3 * frame.width, y: frame.minY + 0.3 * frame.height)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    entity.addComponent(PlayerAssociationComponent(playerEntity: playerEntity))
    
    // TODO: Control component
    
    if let worldEntity = playerEntity.component(ofType: WorldAssociationComponent.self)?.worldEntity {
        entity.addComponent(WorldAssociationComponent(worldEntity: worldEntity))
    }
    
    return entity
}
