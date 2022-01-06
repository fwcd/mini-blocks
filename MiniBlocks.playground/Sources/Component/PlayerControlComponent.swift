import GameplayKit

private let angularValocityEpsilon: CGFloat = 0.01

/// Lets the user control the associated scene node, usually a player.
class PlayerControlComponent: GKComponent {
    var motionInput: MotionInput = []
    
    private var speed: CGFloat = 1
    private var pitchSpeed: CGFloat = 0.4
    private var yawSpeed: CGFloat = 0.3
    private var jumpSpeed: CGFloat = 1.5
    private var throttler = Throttler(interval: 0.1)
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    private var feetOffset: SCNVector3 {
        entity?.component(ofType: HeightAboveGroundComponent.self)?.offset ?? SCNVector3(x: 0, y: 0, z: 0)
    }
    
    private var world: World? {
        entity?.component(ofType: WorldComponent.self)?.world
    }
    
    private var gravityComponent: GravityComponent? {
        entity?.component(ofType: GravityComponent.self)
    }
    
    private var pitchAxis: SCNVector3? {
        guard let node = node, let parent = node.parent else { return nil }
        return node.convertVector(SCNVector3(x: 1, y: 0, z: 0), to: parent)
    }
    
    private var yawAxis: SCNVector3 {
        SCNVector3(x: 0, y: 1, z: 0)
    }
    
    private var velocity: SCNVector3? {
        guard let node = node, let parent = node.parent else { return nil }
        
        var vector = SCNVector3(x: 0, y: 0, z: 0)
        
        if motionInput.contains(.forward) {
            vector.z -= speed
        }
        if motionInput.contains(.back) {
            vector.z += speed
        }
        if motionInput.contains(.left) {
            vector.x -= speed
        }
        if motionInput.contains(.right) {
            vector.x += speed
        }
        
        var rotated = node.convertVector(vector, to: parent)
        rotated.y = 0 // disable vertical movement
        
        return rotated
    }
    
    private var pitchAngularVelocity: CGFloat {
        var angle: CGFloat = 0
        
        if motionInput.contains(.rotateUp) {
            angle += pitchSpeed
        }
        if motionInput.contains(.rotateDown) {
            angle -= pitchSpeed
        }
        
        return angle
    }
    
    private var yawAngularVelocity: CGFloat {
        var angle: CGFloat = 0
        
        if motionInput.contains(.rotateLeft) {
            angle += yawSpeed
        }
        if motionInput.contains(.rotateRight) {
            angle -= yawSpeed
        }
        
        return angle
    }
    
    /// A bit set that represents motion input, usually by the user.
    struct MotionInput: OptionSet {
        static let forward = MotionInput(rawValue: 1 << 0)
        static let back = MotionInput(rawValue: 1 << 1)
        static let left = MotionInput(rawValue: 1 << 2)
        static let right = MotionInput(rawValue: 1 << 3)
        static let rotateLeft = MotionInput(rawValue: 1 << 4)
        static let rotateRight = MotionInput(rawValue: 1 << 5)
        static let rotateUp = MotionInput(rawValue: 1 << 6)
        static let rotateDown = MotionInput(rawValue: 1 << 7)
        static let jump = MotionInput(rawValue: 1 << 8)
        
        let rawValue: Int
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              let velocity = velocity,
              let pitchAxis = pitchAxis else { return }
        
        let interval = throttler.interval
        throttler.run(deltaTime: seconds) {
            // Running into terrain pushes the player back
            let feetPos = node.position + feetOffset + SCNVector3(x: 0, y: 1, z: 0)
            let repulsion: SCNVector3 = world.flatMap { world in
                let currentPos = GridPos3(rounding: feetPos)
                let nextPos = GridPos3(rounding: feetPos + velocity)
                return world.block(at: nextPos).map { _ in (currentPos - nextPos).asSCNVector }
            } ?? SCNVector3(x: 0, y: 0, z: 0)
            
            // Apply the movement
            node.runAction(.move(by: repulsion + velocity, duration: interval))
            
            // Rotate either pitch or yaw
            if abs(pitchAngularVelocity) > angularValocityEpsilon {
                node.runAction(.rotate(by: pitchAngularVelocity, around: pitchAxis, duration: interval))
            } else if abs(yawAngularVelocity) > angularValocityEpsilon {
                node.runAction(.rotate(by: yawAngularVelocity, around: yawAxis, duration: interval))
            }
            
            // Jump if possible/needed
            if motionInput.contains(.jump),
               let gravityComponent = gravityComponent,
               gravityComponent.isOnGround {
                gravityComponent.velocity = jumpSpeed
                gravityComponent.leavesGround = true
            }
        }
    }
}
