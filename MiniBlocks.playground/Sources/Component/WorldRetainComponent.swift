import GameplayKit

/// Lets the associated node keep the world's chunks retained at its position.
class WorldRetainComponent: GKComponent {
    private var previous: Set<ChunkPos> = []
    private var throttler = Throttler(interval: 0.2)
    
    /// Number of chunks to retain in each direction. Note that although we call it a 'radius', a square grid of chunks is loaded.
    var retainRadius: Int = 2
    
    private var worldLoadComponent: WorldLoadComponent? {
        entity?.component(ofType: WorldAssociationComponent.self)?.worldEntity.component(ofType: WorldLoadComponent.self)
    }
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              let worldLoadComponent = worldLoadComponent else { return }
        
        throttler.run(deltaTime: seconds) {
            // TODO: Do delta updates here?
            
            // Release previous chunks
            for pos in previous {
                worldLoadComponent.releaseChunk(at: pos)
            }
            
            previous = []
            
            // Retain new chunks
            let centerPos = ChunkPos(containing: GridPos3(rounding: node.position).asGridPos2)
            for pos in ChunkRegion(around: centerPos, radius: retainRadius) {
                worldLoadComponent.retainChunk(at: pos)
                previous.insert(pos)
            }
        }
    }
}
