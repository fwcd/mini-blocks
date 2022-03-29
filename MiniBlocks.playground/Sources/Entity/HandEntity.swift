import SpriteKit
import GameplayKit

func makeHandEntity() -> GKEntity {
    // Create node
    let node = SCNNode()
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SceneNodeComponent(node: node))
    
    return entity
}
