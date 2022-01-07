import GameplayKit
import SceneKit

func makePlayerEntity(
    position: SCNVector3,
    worldEntity: GKEntity
) -> GKEntity {
    // Create node
    let height: CGFloat = 1.5
    let node = SCNNode()
    node.camera = SCNCamera()
    node.position = position
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(WorldAssociationComponent(worldEntity: worldEntity))
    entity.addComponent(SceneNodeComponent(node: node))
    entity.addComponent(PlayerControlComponent())
    entity.addComponent(HeightAboveGroundComponent(heightAboveGround: 1 + height))
    entity.addComponent(GravityComponent())
    entity.addComponent(LookAtBlockComponent())
    entity.addComponent(WorldRetainComponent()) // players retain chunks around themselves
    
    return entity
}
