import GameplayKit

/// Makes the components visibility dependent on whether the mouse is captured.
class MouseCaptureVisibilityComponent: GKComponent {
    /// If true, the associated node will be visible if and only if the mouse is captured.
    /// If false, the associated node will be visible if and only if it is not captured.
    private let visibleWhenCaptured: Bool
    
    private var node: SKNode? {
        entity?.component(ofType: SpriteNodeComponent.self)?.node
    }
    
    init(visibleWhenCaptured: Bool) {
        self.visibleWhenCaptured = visibleWhenCaptured
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    func update(mouseCaptured: Bool) {
        node?.isHidden = visibleWhenCaptured != mouseCaptured
    }
}
