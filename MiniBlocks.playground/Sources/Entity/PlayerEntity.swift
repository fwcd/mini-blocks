import GameplayKit
import SceneKit

func makePlayerEntity(physicsEnabled: Bool = true) -> GKEntity {
    // Create node
    let height: CGFloat = 1.5
    let shape = SCNPhysicsShape(
        shapes: [SCNPhysicsShape(geometry: SCNBox(width: 1, height: height, length: 1, chamferRadius: 0))],
        transforms: [NSValue(scnMatrix4: SCNMatrix4MakeTranslation(0, -height, 0))]
    )
    let node = SCNNode()
    node.camera = SCNCamera()
    node.position = SCNVector3(x: 0, y: 10, z: 15)
    
    if physicsEnabled {
        // TODO: Make it .kinematic and implement our own gravity (e.g. as a component)
        let physics = SCNPhysicsBody(type: .dynamic, shape: shape)
        physics.isAffectedByGravity = true
        physics.angularVelocityFactor = SCNVector3(x: 0, y: 1, z: 0)
        physics.friction = 0
        node.physicsBody = physics
    }
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SceneNodeComponent(node: node))
    
    return entity
}
