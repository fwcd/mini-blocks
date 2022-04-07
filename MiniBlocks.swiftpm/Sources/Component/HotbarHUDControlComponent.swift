import SpriteKit
import GameplayKit

/// Handles touches on the hotbar.
class HotbarHUDControlComponent: GKComponent, TouchInteractable {
    private var node: SKNode? {
        entity?.component(ofType: SpriteNodeComponent.self)?.node
    }
    
    private var playerAssociationComponent: PlayerAssociationComponent? {
        entity?.component(ofType: PlayerAssociationComponent.self)
    }
    
    private var playerInfo: PlayerInfo? {
        get { playerAssociationComponent?.playerInfo }
        set { playerAssociationComponent?.playerInfo = newValue! }
    }
    
    func onTap(at point: CGPoint) -> Bool {
        guard let slotIndex = node?.scene?.nodes(at: point).compactMap({ $0.userData?["hotbarSlotIndex"] as? Int }).first else { return false }
        playerInfo?.selectedHotbarSlot = slotIndex
        return true
    }
}
