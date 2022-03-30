import SpriteKit
import GameplayKit

func makeAchievementHUDEntity(in frame: CGRect, playerEntity: GKEntity) -> GKEntity {
    // Create node
    let node = SKNode()
    node.position = CGPoint(x: frame.midX, y: frame.minY)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SpriteNodeComponent(node: node))
    
    return entity
}
