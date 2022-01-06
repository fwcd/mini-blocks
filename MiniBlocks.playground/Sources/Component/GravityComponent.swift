import GameplayKit
import SceneKit

/// Accelerates the associated node downwards (i.e. in negative-y direction).
class GravityComponent: GKComponent {
    var velocity: CGFloat = 0
    var acceleration: CGFloat = 0.1
    var throttler = Throttler(interval: 0.1)
    
    var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    var world: World? {
        entity?.component(ofType: WorldComponent.self)?.world
    }
    
    var heightAboveGround: CGFloat {
        entity?.component(ofType: HeightAboveGroundComponent.self)?.heightAboveGround ?? 0
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              let world = world else { return }
        
        let interval = throttler.interval
        throttler.run(deltaTime: seconds) {
            // Only apply gravity if above ground
            if let groundY = world.height(at: GridPos2(x: Int(node.position.x.rounded()), z: Int(node.position.z.rounded()))),
               node.position.y > CGFloat(groundY) + velocity + heightAboveGround {
                velocity += acceleration
                node.runAction(.move(by: SCNVector3(x: 0, y: -velocity, z: 0), duration: interval))
            }
        }
    }
}
