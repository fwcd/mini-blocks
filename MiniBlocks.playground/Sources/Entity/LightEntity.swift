import GameplayKit
import SceneKit

func makeLightEntity(position: SCNVector3) -> GKEntity {
    // Create node
    let light = SCNLight()
    light.type = .omni
    let node = SCNNode()
    node.light = light
    node.position = position
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SceneNodeComponent(node: node))
    
    return entity
}
