import SpriteKit
import GameplayKit

/// Renders the next achievement for a player from the world model to a SpriteKit node.
class AchievementHUDLoadComponent: GKComponent {
    /// The achievement last rendered to a SpriteKit node.
    private var lastAchievement: Achievements?
    
    private let fontSize: CGFloat
    private let lineThickness: CGFloat = 4
    
    private var node: SKNode? {
        entity?.component(ofType: SpriteNodeComponent.self)?.node
    }
    
    @WorldActor private var world: World? {
        get { entity?.component(ofType: WorldAssociationComponent.self)?.world }
        set { entity?.component(ofType: WorldAssociationComponent.self)?.world = newValue }
    }
    
    @WorldActor private var playerInfo: PlayerInfo? {
        get { entity?.component(ofType: PlayerAssociationComponent.self)?.playerInfo }
        set { entity?.component(ofType: PlayerAssociationComponent.self)?.playerInfo = newValue }
    }
    
    @WorldActor private var achievements: Achievements? {
        playerInfo?.achievements
    }
    
    @WorldActor private var nextAchievement: Achievements? {
        achievements?.next
    }
    
    init(fontSize: CGFloat) {
        self.fontSize = fontSize
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        Task.detached { @WorldActor in
            await self._update(deltaTime: seconds)
        }
    }
    
    @WorldActor private func _update(deltaTime seconds: TimeInterval) async {
        guard let node = node else { return }
        
        if lastAchievement != nextAchievement {
            // Update when achievements change
            await node.removeAllChildren()
            
            if let nextAchievement = nextAchievement,
               let achievementNode = makeAchievementHUDNode(for: nextAchievement, fontSize: 13) {
                await node.addChild(achievementNode)
            }
            
            lastAchievement = nextAchievement
        }
    }
}
