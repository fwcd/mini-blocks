import GameplayKit

/// Lets the node 'float' the given distance above the ground. Applies e.g. to gravity calculations.
class HeightAboveGroundComponent: GKComponent {
    let heightAboveGround: CGFloat
    
    init(heightAboveGround: CGFloat) {
        self.heightAboveGround = heightAboveGround
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
