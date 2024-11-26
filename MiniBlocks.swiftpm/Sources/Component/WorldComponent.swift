import Foundation
import SceneKit
import GameplayKit

/// Lets the associated entity store the corresponding world.
class WorldComponent: GKComponent {
    var world: World
    
    init(world: World) {
        self.world = world
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
