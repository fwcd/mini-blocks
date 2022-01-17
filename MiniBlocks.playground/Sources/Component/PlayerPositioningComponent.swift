import GameplayKit
import SceneKit

/// Positions the node according to the position and velocity from the associated player info.
class PlayerPositioningComponent: GKComponent {
    private var throttler = Throttler(interval: 1 / 60)
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
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
        
        throttler.run(deltaTime: seconds) {
            node.position = SCNVector3(playerInfo.position)
            playerInfo.applyVelocity()
            self.playerInfo = playerInfo
        }
    }
}
