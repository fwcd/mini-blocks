import GameplayKit
import SceneKit

/// Positions the node according to the position and velocity from the associated player info.
class PlayerPositioningComponent: GKComponent {
    private var throttler = Throttler(interval: 0.05)
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    private var heightOffset: Vec3 {
        entity?.component(ofType: HeightAboveGroundComponent.self)?.offset ?? .zero
    }
    
    private var playerAssociationComponent: PlayerAssociationComponent? {
        entity?.component(ofType: PlayerAssociationComponent.self)
    }
    
    private var playerInfo: PlayerInfo? {
        get { playerAssociationComponent?.playerInfo }
        set { playerAssociationComponent?.playerInfo = newValue! }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              var playerInfo = playerInfo else { return }
        
        let interval = throttler.interval
        throttler.run(deltaTime: seconds) {
            node.runAction(.move(to: SCNVector3(playerInfo.position - heightOffset), duration: interval))
            playerInfo.applyVelocity()
            self.playerInfo = playerInfo
        }
    }
}
