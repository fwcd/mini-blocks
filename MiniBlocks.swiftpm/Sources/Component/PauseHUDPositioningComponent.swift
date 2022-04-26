import SpriteKit
import GameplayKit

/// Positions the pause overlay.
class PauseHUDPositioningComponent: GKComponent, FrameSizeDependent {
    private var node: SKNode? {
        entity?.component(ofType: SpriteNodeComponent.self)?.node
    }
    
    private var backgroundNode: SKShapeNode? {
        node?.childNode(withName: "pauseHUDBackground") as? SKShapeNode
    }
    
    func onUpdateFrame(to frame: CGRect) {
        DispatchQueue.main.async { [self] in
            node?.position = CGPoint(x: frame.midX, y: frame.midY)
            // TODO: Update size
        }
    }
}
