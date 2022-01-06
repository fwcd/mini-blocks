import GameplayKit

class GridPositionedComponent: GKComponent {
    @Box private var pos: GridPos
    private let node: SCNNode
    
    init(pos: Box<GridPos>, node: SCNNode) {
        _pos = pos
        self.node = node
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        node.position = pos.asSCNVector
    }
}
