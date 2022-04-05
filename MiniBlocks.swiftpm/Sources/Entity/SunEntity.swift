import GameplayKit
import SceneKit

func makeSunEntity() -> GKEntity {
    // Create node
    let light = SCNLight()
    light.type = .directional
    light.color = Color.white
    let node = SCNNode()
    node.light = light
    node.eulerAngles = SCNVector3(x: -.pi / 3, y: -.pi / 3, z: 0)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SceneNodeComponent(node: node))
    
    return entity
}
