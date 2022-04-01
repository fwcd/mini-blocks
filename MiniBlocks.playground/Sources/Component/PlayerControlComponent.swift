import GameplayKit

private let angularValocityEpsilon: SceneFloat = 0.01
private let piHalf = SceneFloat.pi / 2
private let velocityId = "PlayerControlComponent"

/// Lets the user control the associated player.
class PlayerControlComponent: GKComponent {
    /// The current motion input.
    private var motionInput: MotionInput = []
    
    private var baseSpeed: Double = 0.5
    private var flightFactor: Double = 2
    private var sprintFactor: Double = 1.8
    private var pitchSpeed: SceneFloat = 0.4
    private var yawSpeed: SceneFloat = 0.3
    private var jumpSpeed: Double = 1
    private var ascendSpeed: Double = 1
    private var maxCollisionIterations: Int = 5
    private var pitchRange: ClosedRange<SceneFloat> = -piHalf...piHalf
    
    private var blockThrottler = Throttler(interval: 0.15)
    
    private var speed: Double {
        baseSpeed
            * (motionInput.contains(.sprint) ? sprintFactor : 1)
            * ((playerInfo?.gameMode.permitsFlight ?? false) ? flightFactor : 1)
    }
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
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
    
    private var handLoadComponent: HandLoadComponent? {
        entity?.component(ofType: HandLoadComponent.self)
    }
    
    private var playerAssociationComponent: PlayerAssociationComponent? {
        entity?.component(ofType: PlayerAssociationComponent.self)
    }
    
    private var playerInfo: PlayerInfo? {
        get { playerAssociationComponent?.playerInfo }
        set { playerAssociationComponent?.playerInfo = newValue! }
    }
    
    private var lookAtBlockComponent: LookAtBlockComponent? {
        entity?.component(ofType: LookAtBlockComponent.self)
    }
    
    var requestedBaseVelocity: Vec3 = Vec3() {
        didSet {
            playerInfo?.achieve(.moveAround)
        }
    }
    
    private var requestedVelocity: Vec3? {
        guard let node = node, let parent = node.parent else { return nil }
        
        var vector = SCNVector3(requestedBaseVelocity)
        
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
            rotated *= SceneFloat(speed)
        }
        
        return Vec3(rotated)
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
        static let sneak = MotionInput(rawValue: 1 << 12)
        
        let rawValue: UInt16
        
        init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // Note that we don't use the if-var-and-assign idiom for playerInfo due to responsiveness issues (and inout bindings aren't in Swift yet)
        guard let requestedVelocity = requestedVelocity,
              playerInfo != nil else { return }
        
        // Fetch position and velocity
        let position = playerInfo!.position
        var velocity = playerInfo!.velocity
        let gameMode = playerInfo!.gameMode
        
        // Running into terrain pushes the player back, causing them to 'slide' along the block.
        // For more info, look up 'AABB sliding collision response'.
        let feetPos = position
        var finalVelocity = requestedVelocity
        var iterations = 0
        
        if gameMode.enablesGravityAndCollisions {
            while let hit = worldNode?.hitTestWithSegment(from: SCNVector3(feetPos), to: SCNVector3(feetPos + finalVelocity)).first, iterations < maxCollisionIterations {
                let normal = Vec3(hit.worldNormal)
                let repulsion = normal * abs(finalVelocity.dot(normal))
                finalVelocity += repulsion
                iterations += 1
            }
        }
        
        // Apply the movement
        velocity.x = finalVelocity.x
        velocity.z = finalVelocity.z
        
        if gameMode.permitsFlight {
            // Ascend/descend as needed
            velocity.y = 0
            if motionInput.contains(.jump) {
                velocity.y += ascendSpeed
            }
            if motionInput.contains(.sneak) {
                velocity.y -= ascendSpeed
            }
        } else {
            // Jump if needed/possible
            if motionInput.contains(.jump) && playerInfo!.isOnGround {
                velocity.y = jumpSpeed
                playerInfo!.leavesGround = true
            }
        }
        
        blockThrottler.submit(deltaTime: seconds) {
            // Break looked-at block if needed
            if let lookedAtBlockPos = lookAtBlockComponent?.blockPos,
               motionInput.contains(.breakBlock) {
                world?.breakBlock(at: lookedAtBlockPos)
                worldLoadComponent?.markDirty(at: lookedAtBlockPos.asVec2)
                handLoadComponent?.swing()
            }
            
            // Place on looked-at block if needed
            if let placePos = lookAtBlockComponent?.blockPlacePos,
               case let .block(blockType)? = playerInfo!.selectedHotbarStack?.item.type,
               motionInput.contains(.useBlock),
               placePos != BlockPos3(rounding: feetPos) {
                // TODO: Decrement item stack
                world?.place(block: Block(type: blockType), at: placePos)
                worldLoadComponent?.markDirty(at: placePos.asVec2)
                handLoadComponent?.swing()
            }
        }
        
        playerInfo!.position = position
        playerInfo!.velocity = velocity
    }
    
    /// Adds motion input.
    func add(motionInput delta: MotionInput) {
        motionInput.insert(delta)
        
        if !delta.isDisjoint(with: [.forward, .back, .left, .right]) {
            playerInfo?.achieve(.moveAround)
        }
        if delta.contains(.sprint) {
            playerInfo?.achieve(.sprint)
        }
        if delta.contains(.jump) {
            playerInfo?.achieve(.jump)
        }
        if delta.contains(.breakBlock) {
            playerInfo?.achieve(.breakBlock)
        }
        if delta.contains(.useBlock) {
            playerInfo?.achieve(.useBlock)
        }
        
        if delta.contains(.useBlock) || delta.contains(.breakBlock) {
            blockThrottler.reset()
        }
    }
    
    /// Removes motion input.
    func remove(motionInput delta: MotionInput) {
        motionInput.remove(delta)
    }
    
    /// Rotates the node vertically by the given angle (in radians).
    func rotatePitch(by delta: SceneFloat) {
        guard let node = node, canRotatePitch(by: delta) else { return }
        playerInfo?.achieve(.peekAround)
        node.eulerAngles.x += delta * pitchSpeed
    }
    
    /// Rotates the node horizontally by the given angle (in radians).
    func rotateYaw(by delta: SceneFloat) {
        playerInfo?.achieve(.peekAround)
        node?.eulerAngles.y += delta * yawSpeed
    }
    
    private func canRotatePitch(by delta: SceneFloat) -> Bool {
        guard let node = node else { return true }
        return pitchRange.contains(node.eulerAngles.x + delta * pitchSpeed)
    }
    
    func moveHotbarSelection(by delta: Int) {
        playerInfo?.achieve(.hotbar)
        playerInfo?.selectedHotbarSlot += delta
    }
    
    func select(hotbarSlot: Int) {
        playerInfo?.achieve(.hotbar)
        playerInfo?.selectedHotbarSlot = hotbarSlot
    }
    
    /// Toggles the debug overlay for the player.
    func toggleDebugHUD() {
        playerInfo?.hasDebugHUDEnabled = !(playerInfo?.hasDebugHUDEnabled ?? true)
    }
    
    func jump() {
        guard playerInfo?.isOnGround ?? false else { return }
        playerInfo?.achieve(.jump)
        playerInfo?.velocity.y = jumpSpeed
        playerInfo?.leavesGround = true
    }
}
