import GameplayKit
import SceneKit

/// Accelerates the associated node downwards (i.e. in negative-y direction).
class GravityComponent: GKComponent {
    var velocity: SceneFloat = 0
    var acceleration: SceneFloat = -0.4
    var leavesGround: Bool = false
    private(set) var isOnGround: Bool = false
    private var throttler = Throttler(interval: 0.1)
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    private var world: World? {
        entity?.component(ofType: WorldAssociationComponent.self)?.world
    }
    
    private var heightAboveGround: SceneFloat {
        entity?.component(ofType: HeightAboveGroundComponent.self)?.heightAboveGround ?? 0
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              let world = world else { return }
        
        let interval = throttler.interval
        throttler.run(deltaTime: seconds) {
            let y = node.position.y - heightAboveGround
            let mapPos = BlockPos2(x: Int(node.position.x.rounded()), z: Int(node.position.z.rounded()))
            // TODO: Instead of using height, check for the block below the player instead (since we shouldn't assume that the terrain is always just a single surface)
            let groundY = world.height(at: mapPos)
            
            let willBeOnGround = !leavesGround && groundY.map { y + velocity <= SceneFloat($0) } ?? false
            
            if willBeOnGround {
                velocity = 0
                if !isOnGround {
                    // We are reaching the ground, correct the position
                    node.runAction(.move(by: SCNVector3(x: 0, y: SceneFloat(groundY!) - y, z: 0), duration: interval))
                }
            } else {
                // We are airborne, apply gravity
                velocity += acceleration
                node.runAction(.move(by: SCNVector3(x: 0, y: velocity, z: 0), duration: interval))
            }
            
            isOnGround = willBeOnGround
            leavesGround = false
        }
    }
}
