import SpriteKit
import GameplayKit

func makeHotbarHUDEntity(in frame: CGRect, playerEntity: GKEntity) -> GKEntity {
    // Create node
    let node = SKShapeNode(circleOfRadius: 20)
    node.position = CGPoint(x: frame.midX, y: frame.minY)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    entity.addComponent(PlayerAssociationComponent(playerEntity: playerEntity))
    
    return entity
}
