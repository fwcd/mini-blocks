import SpriteKit
import GameplayKit

func makeControlPadHUDEntity(in frame: CGRect, playerEntity: GKEntity, size: CGFloat = 40) -> GKEntity {
    // Create node
    let node = makeControlPadHUDNode(size: size)
    let offset = 2.8 * size
    node.position = CGPoint(x: frame.minX + offset, y: frame.minY + offset)
    
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
