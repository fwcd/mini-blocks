import GameplayKit
import SceneKit

/// Positions the node according to the position and velocity from the associated player info.
class PlayerPositioningComponent: GKComponent {
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    private var worldAssocationComponent: WorldAssociationComponent? {
        entity?.component(ofType: WorldAssociationComponent.self)
    }
    
    private var world: World? {
        get { worldAssocationComponent?.world }
        set { worldAssocationComponent?.world = newValue! }
    }
    
    private var playerName: String? {
        entity?.component(ofType: PlayerAssociationComponent.self)?.playerName
    }
    
    private var playerInfo: PlayerInfo? {
        get { playerName.flatMap { world?[playerInfoFor: $0] } }
        set {
            guard let playerName = playerName else { return }
            world?[playerInfoFor: playerName] = newValue!
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              let playerInfo = playerInfo else { return }
        
        node.position = SCNVector3(playerInfo.position)
    }
}
