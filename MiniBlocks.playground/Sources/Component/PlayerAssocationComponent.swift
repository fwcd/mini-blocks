import GameplayKit

/// Associates the associated entity with a player.
class PlayerAssociationComponent: GKComponent {
    let playerEntity: GKEntity
    
    var playerName: String? {
        playerEntity.component(ofType: NameComponent.self)?.name
    }
    
    var lookAtBlockComponent: LookAtBlockComponent? {
        playerEntity.component(ofType: LookAtBlockComponent.self)
    }
    
    private var worldAssocationComponent: WorldAssociationComponent? {
        entity?.component(ofType: WorldAssociationComponent.self)
    }
    
    private var world: World? {
        get { worldAssocationComponent?.world }
        set { worldAssocationComponent?.world = newValue! }
    }
    
    var playerInfo: PlayerInfo? {
        get { playerName.flatMap { world?[playerInfoFor: $0] } }
        set {
            guard let playerName = playerName else { return }
            world?[playerInfoFor: playerName] = newValue!
        }
    }
    
    init(playerEntity: GKEntity) {
        self.playerEntity = playerEntity
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
