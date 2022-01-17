import GameplayKit
import SceneKit

func makePlayerEntity(
    name: String,
    position: SCNVector3,
    worldEntity: GKEntity,
    retainRadius: Int,
    ambientOcclusionEnabled: Bool
) -> GKEntity {
    // Create node
    let height: SceneFloat = 1.5
    let camera = SCNCamera()
    camera.zNear = 0.1
    if ambientOcclusionEnabled {
        camera.screenSpaceAmbientOcclusionIntensity = 0.5
        camera.screenSpaceAmbientOcclusionRadius = 0.5
    }
    let node = SCNNode()
    node.camera = camera
    node.position = position
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(NameComponent(name: name))
    entity.addComponent(WorldAssociationComponent(worldEntity: worldEntity))
    entity.addComponent(WorldRetainComponent(retainRadius: retainRadius)) // players retain chunks around themselves
    entity.addComponent(SceneNodeComponent(node: node))
    entity.addComponent(PlayerControlComponent())
    entity.addComponent(PlayerPositioningComponent())
    entity.addComponent(HeightAboveGroundComponent(heightAboveGround: 1 + height))
    entity.addComponent(GravityComponent())
    entity.addComponent(LookAtBlockComponent())
    entity.addComponent(PlayerAssociationComponent(playerEntity: entity)) // a player is associated with itself too
    
    return entity
}
