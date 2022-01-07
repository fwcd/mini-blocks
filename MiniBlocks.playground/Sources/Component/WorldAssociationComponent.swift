import GameplayKit

/// Associates the entity with a world entity.
class WorldAssociationComponent: GKComponent {
    let worldEntity: GKEntity
    
    var world: World? {
        get { worldEntity.component(ofType: WorldComponent.self)?.world }
        set { worldEntity.component(ofType: WorldComponent.self)?.world = newValue! }
    }
    
    var worldNode: SCNNode? {
        worldEntity.component(ofType: SceneNodeComponent.self)?.node
    }
    
    var worldLoadComponent: WorldLoadComponent? {
        worldEntity.component(ofType: WorldLoadComponent.self)
    }
    
    init(worldEntity: GKEntity) {
        self.worldEntity = worldEntity
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
