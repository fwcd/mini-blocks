import GameplayKit

/// Lets the associated node keep the world's chunks retained at its position.
class WorldRetainComponent: GKComponent {
    private var previous: Set<ChunkPos> = []
    private var throttler = Throttler(interval: 0.2)
    
    /// Number of chunks to retain in each direction. Note that although we call it a 'radius', a square grid of chunks is loaded.
    var retainRadius: Int = 4
    
    /// Number of chunks which the player may 'stray' from the lastUpdatePos until an update to the retained chunks is triggered.
    private var skipUpdateRadius: Int {
        retainRadius - 1
    }
    
    private var lastUpdatePos: ChunkPos? = nil
    
    private var worldLoadComponent: WorldLoadComponent? {
        entity?.component(ofType: WorldAssociationComponent.self)?.worldEntity.component(ofType: WorldLoadComponent.self)
    }
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    private var currentPos: ChunkPos? {
        node.map { ChunkPos(containing: GridPos3(rounding: $0.position).asGridPos2) }
    }
    
    private var shouldUpdate: Bool {
        guard let lastUpdatePos = lastUpdatePos,
              let currentPos = currentPos else { return true }
        return (currentPos - lastUpdatePos).squaredLength > skipUpdateRadius * skipUpdateRadius
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let worldLoadComponent = worldLoadComponent,
              let centerPos = currentPos else { return }
        
        throttler.run(deltaTime: seconds) {
            guard shouldUpdate else { return }
            print("Updating retained chunks...")
            
            // TODO: Do delta updates here?
            
            // Release previous chunks
            for pos in previous {
                worldLoadComponent.releaseChunk(at: pos)
            }
            
            previous = []
            
            // Retain new chunks
            for pos in ChunkRegion(around: centerPos, radius: retainRadius) {
                worldLoadComponent.retainChunk(at: pos)
                previous.insert(pos)
            }
            
            lastUpdatePos = centerPos
        }
    }
}
