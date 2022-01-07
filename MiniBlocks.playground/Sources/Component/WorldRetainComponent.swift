import GameplayKit

/// Lets the associated node keep the world at the corresponding 
class WorldRetainComponent: GKComponent {
    private var previousChunkPos: ChunkPos?
    private var throttler = Throttler(interval: 0.2)
    
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
            if let previousChunkPos = previousChunkPos {
                worldLoadComponent.releaseChunk(at: previousChunkPos)
            }
            
            let chunkPos = ChunkPos(containing: GridPos3(rounding: node.position).asGridPos2)
            worldLoadComponent.retainChunk(at: chunkPos)
            previousChunkPos = chunkPos
        }
    }
}
