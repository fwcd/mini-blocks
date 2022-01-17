import GameplayKit
import SceneKit

/// Accelerates the associated node downwards (i.e. in negative-y direction).
class PlayerGravityComponent: GKComponent {
    var acceleration: SceneFloat = -0.4
    var leavesGround: Bool = false
    private(set) var isOnGround: Bool = false
    private var throttler = Throttler(interval: 0.1)
    
    private var world: World? {
        entity?.component(ofType: WorldAssociationComponent.self)?.world
    }
    
    private var heightAboveGround: Double {
        entity?.component(ofType: HeightAboveGroundComponent.self)?.heightAboveGround ?? 0
    }
    
    private var playerAssociationComponent: PlayerAssociationComponent? {
        entity?.component(ofType: PlayerAssociationComponent.self)
    }
    
    private var playerInfo: PlayerInfo? {
        get { playerAssociationComponent?.playerInfo }
        set { playerAssociationComponent?.playerInfo = newValue! }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let world = world,
              var playerInfo = playerInfo else { return }
        
        throttler.run(deltaTime: seconds) {
            // Fetch position and velocity
            var position = playerInfo.position
            var velocity = playerInfo.velocity
            
            let y = position.y - heightAboveGround
            let mapPos = BlockPos3(rounding: position).asVec2
            // TODO: Instead of using height, check for the block below the player instead (since we shouldn't assume that the terrain is always just a single surface)
            let groundY = world.height(at: mapPos)
            
            let willBeOnGround = !leavesGround && groundY.map { y + velocity.y <= Double($0) } ?? false
            
            if willBeOnGround {
                velocity = .zero
                if !isOnGround {
                    // We are reaching the ground, correct the position
                    position.y = Double(groundY!)
                }
            } else {
                // We are airborne, apply gravity
                velocity.y += acceleration
            }
            
            isOnGround = willBeOnGround
            leavesGround = false
            
            playerInfo.position = position
            playerInfo.velocity = velocity
            
            self.playerInfo = playerInfo
        }
    }
}
