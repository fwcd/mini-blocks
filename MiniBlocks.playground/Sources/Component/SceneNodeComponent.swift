import SceneKit
import GameplayKit

/// Adds a SceneKit node to the corresponding entity.
class SceneNodeComponent: GKComponent {
    let node: SCNNode
    
    init(node: SCNNode) {
        self.node = node
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
