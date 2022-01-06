import GameplayKit

/// Lets the user control the associated scene node, usually a player.
class PlayerControlComponent: GKComponent {
    var motionInput: MotionInput = []
    
    private var speed: CGFloat = 2
    private var secondsSinceLastUpdate: TimeInterval = 0
    private var updateInterval: TimeInterval = 0.2
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
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
        
        return node.convertVector(vector, to: parent)
    }
    
    /// A bit set that represents motion input, usually by the user.
    struct MotionInput: OptionSet {
        static let forward = MotionInput(rawValue: 1 << 0)
        static let back = MotionInput(rawValue: 1 << 1)
        static let left = MotionInput(rawValue: 1 << 2)
        static let right = MotionInput(rawValue: 1 << 3)
        
        let rawValue: Int
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        secondsSinceLastUpdate += seconds
        
        if secondsSinceLastUpdate > updateInterval {
            if let velocity = velocity {
                node?.runAction(.move(by: velocity, duration: updateInterval))
            }
            secondsSinceLastUpdate = 0
        }
    }
    
    func jump() {
        // TODO
    }
}
