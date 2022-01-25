import SpriteKit
import GameplayKit

func makeDebugHUDEntity(in frame: CGRect, playerEntity: GKEntity) -> GKEntity {
    // Create node
    let node = SKNode()
    node.position = CGPoint(x: frame.midX, y: frame.maxY)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    entity.addComponent(PlayerAssociationComponent(playerEntity: playerEntity))
    
    if let worldEntity = playerEntity.component(ofType: WorldAssociationComponent.self)?.worldEntity {
        entity.addComponent(WorldAssociationComponent(worldEntity: worldEntity))
    }
    
    return entity
}
