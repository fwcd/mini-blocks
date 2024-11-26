import SpriteKit
import GameplayKit

func makeHotbarHUDEntity(in frame: CGRect, playerEntity: GKEntity) -> GKEntity {
    // Create node
    let node = SKNode()
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    entity.addComponent(PlayerAssociationComponent(playerEntity: playerEntity))
    entity.addComponent(HotbarHUDLoadComponent())
    entity.addComponent(HotbarHUDControlComponent())
    
    if let worldEntity = playerEntity.component(ofType: WorldAssociationComponent.self)?.worldEntity {
        entity.addComponent(WorldAssociationComponent(worldEntity: worldEntity))
    }
    
    return entity
}
