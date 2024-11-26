import Foundation
import SpriteKit
import GameplayKit

/// Adds a SpriteKit node to the corresponding entity.
class SpriteNodeComponent: GKComponent {
    let node: SKNode
    
    init(node: SKNode) {
        self.node = node
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
