import SceneKit
import GameplayKit

/// Lets the associated entity interact with the given world.
class WorldComponent: GKComponent {
    @Box var world: World
    
    init(world: Box<World>) {
        _world = world
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
