import GameplayKit

class GridPositionedComponent: GKComponent {
    @Box private var pos: GridPos
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    init(pos: Box<GridPos>) {
        _pos = pos
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        node?.position = pos.asSCNVector
    }
}
