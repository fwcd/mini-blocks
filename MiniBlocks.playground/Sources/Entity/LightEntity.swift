import GameplayKit
import SceneKit

func makeLightEntity(position: SCNVector3) -> GKEntity {
    // Set up node
    let light = SCNLight()
    light.type = .omni
    let node = SCNNode()
    node.light = light
    node.position = position
    
    // Set up entity
    let entity = GKEntity()
    entity.addComponent(SceneNodeComponent(node: node))
    
    return entity
}
