import SpriteKit
import GameplayKit

/// Positions the crosshair (in the center).
class CrosshairHUDPositioningComponent: GKComponent, FrameSizeDependent {
    private var node: SKNode? {
        entity?.component(ofType: SpriteNodeComponent.self)?.node
    }
    
    func onUpdateFrame(to frame: CGRect) {
        DispatchQueue.main.async { [self] in
            node?.position = CGPoint(x: frame.midX, y: frame.midY)
        }
    }
}
