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
    
    private var lookAtBlockComponent: LookAtBlockComponent? {
        entity?.component(ofType: PlayerAssociationComponent.self)?.lookAtBlockComponent
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let playerInfo = playerInfo,
              let node = node else { return }
        
        if playerInfo.hasDebugHUDEnabled {
            var stats = [
                ("Position", format(pos: playerInfo.position)),
                ("Block Position", format(pos: BlockPos3(rounding: playerInfo.position))),
                ("Game Mode", "\(playerInfo.gameMode)"),
            ]
            
            if let component = lookAtBlockComponent {
                stats += [
                    ("Looking At", component.blockPos.map(format(pos:)) ?? "nil"),
                    ("Placing At", component.blockPlacePos.map(format(pos:)) ?? "nil"),
                ]
            }
            
            node.text = stats.map { "\($0.0): \($0.1)" }.joined(separator: "\n")
        } else {
            node.text = nil
        }
    }
    
    private func format(pos: BlockPos3) -> String {
        "x \(pos.x), y \(pos.y), z \(pos.z)"
    }
    
    private func format(pos: Vec3) -> String {
        String(format: "x %.4f, y %.4f, z %.4f", pos.x, pos.y, pos.z)
    }
}
