import GameplayKit
import SceneKit

func makePlayerEntity(world: Box<World>, worldNode: SCNNode? = nil) -> GKEntity {
    // Create node
    let height: CGFloat = 1.5
    let node = SCNNode()
    node.camera = SCNCamera()
    node.position = SCNVector3(x: 0, y: 10, z: 15)
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(WorldComponent(world: world))
    entity.addComponent(SceneNodeComponent(node: node))
    entity.addComponent(PlayerControlComponent())
    entity.addComponent(HeightAboveGroundComponent(heightAboveGround: 1 + height))
    entity.addComponent(GravityComponent())
    
    if let worldNode = worldNode {
        entity.addComponent(LookAtBlockComponent(worldNode: worldNode))
    }
    
    return entity
}
