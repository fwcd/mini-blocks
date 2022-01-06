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
    
    override func update(deltaTime seconds: TimeInterval) {
        let interval = throttler.interval
        throttler.run(deltaTime: seconds) {
            velocity += acceleration
            node?.runAction(.move(by: SCNVector3(x: 0, y: -velocity, z: 0), duration: interval))
        }
    }
}
