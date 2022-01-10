import SpriteKit
import GameplayKit

/// Renders the hotbar for a player from the world model to a SpriteKit node.
class HotbarHUDLoadComponent: GKComponent {
    private var node: SKNode? {
        entity?.component(ofType: SpriteNodeComponent.self)?.node
    }
    
    private var world: World? {
        get { entity?.component(ofType: WorldAssociationComponent.self)?.world }
        set { entity?.component(ofType: WorldAssociationComponent.self)?.world = newValue }
    }
    
    private var playerName: String? {
        entity?.component(ofType: PlayerAssociationComponent.self)?.playerName
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // TODO
    }
}
