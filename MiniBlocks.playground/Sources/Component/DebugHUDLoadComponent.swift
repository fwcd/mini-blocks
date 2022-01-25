import SpriteKit
import GameplayKit

class DebugHUDLoadComponent: GKComponent {
    private var node: SKLabelNode? {
        entity?.component(ofType: SpriteNodeComponent.self)?.node as? SKLabelNode
    }
    
    private var world: World? {
        get { entity?.component(ofType: WorldAssociationComponent.self)?.world }
        set { entity?.component(ofType: WorldAssociationComponent.self)?.world = newValue }
    }
    
    private var playerInfo: PlayerInfo? {
        get { entity?.component(ofType: PlayerAssociationComponent.self)?.playerInfo }
        set { entity?.component(ofType: PlayerAssociationComponent.self)?.playerInfo = newValue }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let playerInfo = playerInfo,
              let node = node else { return }
        
        if playerInfo.hasDebugHUDEnabled {
            let stats = [
                ("Position", "\(playerInfo.position)"),
                ("Game Mode", "\(playerInfo.gameMode)"),
            ]
            node.text = stats.map { "\($0.0): \($0.1)" }.joined(separator: ", ")
        } else {
            node.text = nil
        }
    }
}
