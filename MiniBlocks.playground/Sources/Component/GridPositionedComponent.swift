import GameplayKit

/// Positions the associated node on the grid, this is useful for blocks.
class GridPositionedComponent: GKComponent {
    @Box private var pos: GridPos3
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    init(pos: Box<GridPos3>) {
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
