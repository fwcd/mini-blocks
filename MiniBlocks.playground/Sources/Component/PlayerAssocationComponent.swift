import GameplayKit

/// Associates the associated entity with a player.
class PlayerAssociationComponent: GKComponent {
    let playerEntity: GKEntity
    
    var playerName: String? {
        playerEntity.component(ofType: NameComponent.self)?.name
    }
    
    init(playerEntity: GKEntity) {
        self.playerEntity = playerEntity
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
