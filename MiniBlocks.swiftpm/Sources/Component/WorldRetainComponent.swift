import Foundation
import GameplayKit
import OSLog

private let log = Logger(subsystem: "MiniBlocks", category: "WorldRetainComponent")

/// Lets the associated node keep the world's chunks retained at its position.
class WorldRetainComponent: GKComponent {
    private var previous: Set<ChunkPos> = []
    private var throttler = Throttler(interval: 0.2)
    
    /// Number of chunks to retain in each direction. Note that although we call it a 'radius', a square grid of chunks is loaded.
    var retainRadius: Int
    
    /// Number of chunks which the player may 'stray' from the lastUpdatePos until an update to the retained chunks is triggered.
    private var skipUpdateRadius: Int { min(2, retainRadius - 1) }
    
    private var lastUpdatePos: ChunkPos? = nil
    
    private var worldLoadComponent: WorldLoadComponent? {
        entity?.component(ofType: WorldAssociationComponent.self)?.worldLoadComponent
    }
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    private var currentPos: ChunkPos? {
        node.map { ChunkPos(containing: BlockPos3(rounding: $0.position).asVec2) }
    }
    
    private var shouldUpdate: Bool {
        guard let lastUpdatePos = lastUpdatePos,
              let currentPos = currentPos else { return true }
        return (currentPos - lastUpdatePos).squaredLength > skipUpdateRadius * skipUpdateRadius
    }
    
    init(retainRadius: Int = 6) {
        self.retainRadius = retainRadius
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let worldLoadComponent = worldLoadComponent,
              let centerPos = currentPos else { return }
        
        throttler.submit(deltaTime: seconds) {
            guard shouldUpdate else { return }
            log.info("Updating retained chunks...")
            
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
