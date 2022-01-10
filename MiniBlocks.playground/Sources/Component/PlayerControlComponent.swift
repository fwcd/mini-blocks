import GameplayKit

private let angularValocityEpsilon: SceneFloat = 0.01
private let piHalf = SceneFloat.pi / 2

/// Lets the user control the associated scene node, usually a player.
class PlayerControlComponent: GKComponent {
    /// The current motion input.
    private var motionInput: MotionInput = []
    
    private var baseSpeed: SceneFloat = 0.8
    private var pitchSpeed: SceneFloat = 0.4
    private var yawSpeed: SceneFloat = 0.3
    private var jumpSpeed: SceneFloat = 1.5
    private var sprintFactor: SceneFloat = 1.5
    private var maxCollisionIterations: Int = 5
    private var pitchRange: ClosedRange<SceneFloat> = -piHalf...piHalf
    
    private var throttler = Throttler(interval: 0.1)
    private var deferrableThrottler = Throttler(interval: 0.3)
    
    private var speed: SceneFloat {
        baseSpeed * (motionInput.contains(.sprint) ? sprintFactor : 1)
    }
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    private var feetOffset: SCNVector3 {
        entity?.component(ofType: HeightAboveGroundComponent.self)?.offset ?? SCNVector3(x: 0, y: 0, z: 0)
    }
    
    private var worldAssocationComponent: WorldAssociationComponent? {
        entity?.component(ofType: WorldAssociationComponent.self)
    }
    
    private var worldNode: SCNNode? {
        worldAssocationComponent?.worldNode
    }
    
    private var world: World? {
        get { worldAssocationComponent?.world }
        set { worldAssocationComponent?.world = newValue! }
    }
    
    private var worldLoadComponent: WorldLoadComponent? {
        worldAssocationComponent?.worldLoadComponent
    }
    
    private var gravityComponent: GravityComponent? {
        entity?.component(ofType: GravityComponent.self)
    }
    
    private var lookAtBlockComponent: LookAtBlockComponent? {
        entity?.component(ofType: LookAtBlockComponent.self)
    }
    
    private var velocity: SCNVector3? {
        guard let node = node, let parent = node.parent else { return nil }
        
        var vector = SCNVector3(x: 0, y: 0, z: 0)
        
        if motionInput.contains(.forward) {
            vector.z -= 1
        }
        if motionInput.contains(.back) {
            vector.z += 1
        }
        if motionInput.contains(.left) {
            vector.x -= 1
        }
        if motionInput.contains(.right) {
            vector.x += 1
        }
        
        var rotated = node.convertVector(vector, to: parent)
        rotated.y = 0 // disable vertical movement
        
        if rotated.length > 0 {
            rotated.normalize()
            rotated *= speed
        }
        
        return rotated
    }
    
    /// A bit set that represents motion input, usually by the user.
    struct MotionInput: OptionSet {
        static let forward = MotionInput(rawValue: 1 << 0)
        static let back = MotionInput(rawValue: 1 << 1)
        static let left = MotionInput(rawValue: 1 << 2)
        static let right = MotionInput(rawValue: 1 << 3)
        static let jump = MotionInput(rawValue: 1 << 8)
        static let sprint = MotionInput(rawValue: 1 << 9)
        static let breakBlock = MotionInput(rawValue: 1 << 10)
        static let useBlock = MotionInput(rawValue: 1 << 11)
        
        let rawValue: UInt16
        
        init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              let velocity = velocity else { return }
        
        let interval = throttler.interval
        throttler.run(deltaTime: seconds) {
            // Running into terrain pushes the player back, causing them to 'slide' along the block.
            // For more info, look up 'AABB sliding collision response'.
            let feetPos = node.position + feetOffset + SCNVector3(x: 0, y: 1, z: 0)
            var finalVelocity = velocity
            var iterations = 0
            
            while let hit = worldNode?.hitTestWithSegment(from: feetPos, to: feetPos + finalVelocity).first, iterations < maxCollisionIterations {
                let repulsion = hit.worldNormal * abs(finalVelocity.dot(hit.worldNormal))
                finalVelocity += repulsion
                iterations += 1
            }
            
            // Apply the movement
            node.runAction(.move(by: finalVelocity, duration: interval))
            
            // Jump if possible/needed
            if motionInput.contains(.jump),
               let gravityComponent = gravityComponent,
               gravityComponent.isOnGround {
                gravityComponent.velocity = jumpSpeed
                gravityComponent.leavesGround = true
            }
            
            if let lookedAtBlockPos = lookAtBlockComponent?.blockPos {
                // Break looked-at block if needed
                if motionInput.contains(.breakBlock) {
                    world?.breakBlock(at: lookedAtBlockPos)
                    worldLoadComponent?.markDirty(at: lookedAtBlockPos.asGridPos2)
                }
            }
            
            if let placePos = lookAtBlockComponent?.blockPlacePos {
                // Use or place on looked-at block if needed
                if motionInput.contains(.useBlock) && placePos != GridPos3(rounding: feetPos) {
                    // TODO: Support other blocks etc.
                    world?.place(block: Block(type: .grass), at: placePos)
                    worldLoadComponent?.markDirty(at: placePos.asGridPos2)
                }
            }
        }
    }
    
    /// Adds motion input.
    func add(motionInput delta: MotionInput) {
        motionInput.insert(delta)
    }
    
    /// Removes motion input.
    func remove(motionInput delta: MotionInput) {
        motionInput.remove(delta)
    }///
    
    /// Rotates the node vertically by the given angle (in radians).
    func rotatePitch(by delta: SceneFloat) {
        guard let node = node, canRotatePitch(by: delta) else { return }
        node.eulerAngles.x += delta * pitchSpeed
    }
    
    /// Rotates the node horizontally by the given angle (in radians).
    func rotateYaw(by delta: SceneFloat) {
        node?.eulerAngles.y += delta * yawSpeed
    }
    
    private func canRotatePitch(by delta: SceneFloat) -> Bool {
        guard let node = node else { return true }
        return pitchRange.contains(node.eulerAngles.x + delta * pitchSpeed)
    }
}
