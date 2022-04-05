import GameplayKit
import SceneKit

/// Accelerates the associated node downwards (i.e. in negative-y direction).
class PlayerGravityComponent: GKComponent {
    private let baseAcceleration: Double = -0.4
    private let submergedFactor: Double = 0.5
    
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
              playerInfo != nil,
              playerInfo!.gameMode.enablesGravityAndCollisions else { return }
        
        throttler.submit(deltaTime: seconds) {
            // Fetch position and velocity
            var position = playerInfo!.position
            var velocity = playerInfo!.velocity
            
            let y = position.y
            let blockPos = BlockPos3(rounding: position)
            let yBound = world.height(below: blockPos, includeLiquids: false).map { $0 + 1 }
            
            let isSubmerged = world.block(at: blockPos)?.type.isLiquid ?? false
            let willBeOnGround = !playerInfo!.leavesGround && yBound.map { y + velocity.y <= Double($0) } ?? false
            
            var acceleration = baseAcceleration
            
            if isSubmerged {
                acceleration *= submergedFactor
            }
            
            if willBeOnGround {
                velocity.y = 0
                if !playerInfo!.isOnGround {
                    // We are reaching the ground, correct the position
                    position.y = Double(yBound!)
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
