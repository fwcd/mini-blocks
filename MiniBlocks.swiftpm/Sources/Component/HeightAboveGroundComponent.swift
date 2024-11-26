import Foundation
import GameplayKit

/// Lets the node 'float' the given distance above the ground. Applies e.g. to gravity calculations.
class HeightAboveGroundComponent: GKComponent {
    let heightAboveGround: Double
    
    var offset: Vec3 {
        Vec3(x: 0, y: -heightAboveGround, z: 0)
    }
    
    init(heightAboveGround: Double) {
        self.heightAboveGround = heightAboveGround
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
