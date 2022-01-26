import GameplayKit
import SceneKit

func makePlayerEntity(
    name: String,
    position: Vec3,
    gameMode: GameMode,
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
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(NameComponent(name: name))
    entity.addComponent(WorldAssociationComponent(worldEntity: worldEntity))
    entity.addComponent(WorldRetainComponent(retainRadius: retainRadius)) // players retain chunks around themselves
    entity.addComponent(SceneNodeComponent(node: node))
    entity.addComponent(PlayerControlComponent())
    entity.addComponent(PlayerPositioningComponent())
    entity.addComponent(HeightAboveGroundComponent(heightAboveGround: height))
    entity.addComponent(PlayerGravityComponent())
    entity.addComponent(LookAtBlockComponent())
    entity.addComponent(PlayerAssociationComponent(playerEntity: entity)) // a player is associated with itself too
    
    // Set initial player info
    if let component = worldEntity.component(ofType: WorldComponent.self) {
        var playerInfo = component.world[playerInfoFor: name]
        
        playerInfo.position = position
        playerInfo.gameMode = gameMode
        
        component.world[playerInfoFor: name] = playerInfo
    }
    
    return entity
}
