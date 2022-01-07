import GameplayKit

private let angularValocityEpsilon: CGFloat = 0.01
private let piHalf = CGFloat.pi / 2

/// Lets the user control the associated scene node, usually a player.
class PlayerControlComponent: GKComponent {
    /// The current motion input.
    private var motionInput: MotionInput = []
    /// The motion input after the next update cycle. The reason for making this a separate array is to handle very quick mouse inputs (i.e. those that are added and removed before an update cycle could happen).
    private var nextMotionInput: MotionInput = []
    
    private var baseSpeed: CGFloat = 0.8
    private var pitchSpeed: CGFloat = 0.4
    private var yawSpeed: CGFloat = 0.3
    private var jumpSpeed: CGFloat = 1.5
    private var sprintFactor: CGFloat = 1.5
    private var pitchRange: ClosedRange<CGFloat> = -piHalf...piHalf
    private var throttler = Throttler(interval: 0.1)
    
    private var speed: CGFloat {
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
        
        /// See doc comment on motionInput and nextMotionInput above for explanation.
        static let deferredHandleable: MotionInput = [.breakBlock, .useBlock]
        
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
            // Running into terrain pushes the player back
            let feetPos = node.position + feetOffset + SCNVector3(x: 0, y: 1, z: 0)
            let repulsion: SCNVector3 = world.flatMap { world in
                let currentPos = GridPos3(rounding: feetPos)
                let nextPos = GridPos3(rounding: feetPos + velocity)
                return world.block(at: nextPos).map { _ in (currentPos - nextPos).asSCNVector * speed }
            } ?? SCNVector3(x: 0, y: 0, z: 0)
            
            // Apply the movement
            node.runAction(.move(by: repulsion + velocity, duration: interval))
            
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
                // Use looked-at block if needed
                if motionInput.contains(.useBlock) {
                    // TODO: Support other blocks etc.
                    world?.place(block: Block(type: .grass), at: placePos)
                    worldLoadComponent?.markDirty(at: placePos.asGridPos2)
                }
            }
            
            motionInput = nextMotionInput
        }
    }
    
    /// Adds motion input.
    func add(motionInput delta: MotionInput) {
        motionInput.insert(delta)
        nextMotionInput.insert(delta)
    }
    
    /// Removes motion input.
    func remove(motionInput delta: MotionInput) {
        motionInput.remove(delta.subtracting(.deferredHandleable))
        nextMotionInput.remove(delta)
    }///
    
    /// Rotates the node vertically by the given angle (in radians).
    func rotatePitch(by delta: CGFloat) {
        guard let node = node, canRotatePitch(by: delta) else { return }
        node.eulerAngles.x += delta * pitchSpeed
    }
    
    /// Rotates the node horizontally by the given angle (in radians).
    func rotateYaw(by delta: CGFloat) {
        node?.eulerAngles.y += delta * yawSpeed
    }
    
    private func canRotatePitch(by delta: CGFloat) -> Bool {
        guard let node = node else { return true }
        return pitchRange.contains(node.eulerAngles.x + delta * pitchSpeed)
    }
}
