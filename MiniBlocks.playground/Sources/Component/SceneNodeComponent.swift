import SceneKit
import GameplayKit

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
