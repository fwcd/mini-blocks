import GameplayKit
import SceneKit

/// Accelerates the associated node downwards (i.e. in negative-y direction).
class PlayerGravityComponent: GKComponent {
    var acceleration: SceneFloat = -0.4
    private var throttler = Throttler(interval: 0.1)
    
    private var world: World? {
        entity?.component(ofType: WorldAssociationComponent.self)?.world
    }
    
    private var playerAssociationComponent: PlayerAssociationComponent? {
        entity?.component(ofType: PlayerAssociationComponent.self)
    }
    
    private var playerInfo: PlayerInfo? {
        get { playerAssociationComponent?.playerInfo }
        set { playerAssociationComponent?.playerInfo = newValue! }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // Note that we don't use the if-var-and-assign idiom for playerInfo due to responsiveness issues (and inout bindings aren't in Swift yet)
        guard let world = world,
              playerInfo != nil else { return }
        
        throttler.submit(deltaTime: seconds) {
            // Fetch position and velocity
            var position = playerInfo!.position
            var velocity = playerInfo!.velocity
            
            let y = position.y
            let mapPos = BlockPos3(rounding: position).asVec2
            // TODO: Instead of using height, check for the block below the player instead (since we shouldn't assume that the terrain is always just a single surface)
            let groundY = world.height(at: mapPos)
            
            let willBeOnGround = !playerInfo!.leavesGround && groundY.map { y + velocity.y <= Double($0) } ?? false
            
            if willBeOnGround {
                velocity.y = 0
                if !playerInfo!.isOnGround {
                    // We are reaching the ground, correct the position
                    position.y = Double(groundY!)
                }
            } else {
                // We are airborne, apply gravity
                velocity.y += acceleration
            }
            
            playerInfo!.isOnGround = willBeOnGround
            playerInfo!.leavesGround = false
            
            playerInfo!.position = position
            playerInfo!.velocity = velocity
        }
    }
}
