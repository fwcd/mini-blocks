import SpriteKit
import GameplayKit

func makeDebugHUDEntity(in frame: CGRect, playerEntity: GKEntity, fontSize: CGFloat = 15) -> GKEntity {
    // Create node
    let padding: CGFloat = 5
    let node = SKLabelNode()
    node.fontColor = .white
    node.fontName = NodeConstants.fontName
    node.fontSize = fontSize
    node.position = CGPoint(x: frame.minX + padding, y: frame.maxY - padding)
    node.numberOfLines = 0
    node.verticalAlignmentMode = .top
    node.horizontalAlignmentMode = .left
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    entity.addComponent(PlayerAssociationComponent(playerEntity: playerEntity))
    entity.addComponent(DebugHUDLoadComponent())
    
    if let worldEntity = playerEntity.component(ofType: WorldAssociationComponent.self)?.worldEntity {
        entity.addComponent(WorldAssociationComponent(worldEntity: worldEntity))
    }
    
    return entity
}
