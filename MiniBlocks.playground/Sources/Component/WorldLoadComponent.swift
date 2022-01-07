import GameplayKit

/// Loads chunks from the world model into the SceneKit node.
class WorldLoadComponent: GKComponent {
    private var world: World? {
        get { entity?.component(ofType: WorldComponent.self)?.world }
        set { entity?.component(ofType: WorldComponent.self)?.world = newValue! }
    }
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // TODO
    }
}
