import GameplayKit

/// Lets the node 'float' the given distance above the ground. Applies e.g. to gravity calculations.
class HeightAboveGroundComponent: GKComponent {
    let heightAboveGround: CGFloat
    
    var offset: SCNVector3 {
        SCNVector3(x: 0, y: -heightAboveGround, z: 0)
    }
    
    init(heightAboveGround: CGFloat) {
        self.heightAboveGround = heightAboveGround
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
