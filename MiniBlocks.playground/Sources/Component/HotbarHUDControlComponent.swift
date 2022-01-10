import GameplayKit

/// Lets the user control the associated hotbar.
class HotbarHUDControlComponent: GKComponent {
    private var world: World? {
        get { entity?.component(ofType: WorldAssociationComponent.self)?.world }
        set { entity?.component(ofType: WorldAssociationComponent.self)?.world = newValue }
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
    
    func moveSelection(by delta: Int) {
        playerInfo?.selectedHotbarSlot += delta
    }
    
    func select(_ i: Int) {
        playerInfo?.selectedHotbarSlot = i
    }
}
