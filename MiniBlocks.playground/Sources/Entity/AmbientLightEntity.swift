import GameplayKit
import SceneKit

func makeAmbientLightEntity() -> GKEntity {
    // Create node
    let light = SCNLight()
    light.type = .ambient
    light.color = NSColor.darkGray
    let node = SCNNode()
    node.light = light
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SceneNodeComponent(node: node))
    
    return entity
}
