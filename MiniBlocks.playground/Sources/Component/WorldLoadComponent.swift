import GameplayKit
import SceneKit

/// Loads chunks from the world model into the SceneKit node.
class WorldLoadComponent: GKComponent {
    /// The 'reference-counts' of each chunk retainer (e.g. players).
    private var retainCounts: [ChunkPos: Int] = [:]
    
    /// The currently loaded chunks with their associated SceneKit nodes.
    private var loadedChunks: [ChunkPos: SCNNode] = [:]
    
    /// Strips marked as dirty (e.g. because the user placed/removed blocks there).
    private var dirtyStrips: Set<BlockPos2> = []
    
    /// Performs occlusion checking before rendering. Makes chunk loading slower and rendering faster.
    private var checkOcclusions: Bool = true
    
    /// Throttles chunk loading to a fixed interval.
    private var throttler = Throttler(interval: 0.5)
    
    private var world: World? {
        get { entity?.component(ofType: WorldComponent.self)?.world }
        set { entity?.component(ofType: WorldComponent.self)?.world = newValue! }
    }
    
    private var node: SCNNode? {
        entity?.component(ofType: SceneNodeComponent.self)?.node
    }
    
    /// Increments the retain count for the given chunk.
    func retainChunk(at pos: ChunkPos) {
        retainCounts[pos] = (retainCounts[pos] ?? 0) + 1
    }
    
    /// Decrements the retain count for the given chunk.
    func releaseChunk(at pos: ChunkPos) {
        let newCount = (retainCounts[pos] ?? 1) - 1
        retainCounts[pos] = newCount == 0 ? nil : newCount
    }
    
    /// Marks a strip as dirty. Also marks the adjacent strips as dirty since occlusions might have changed.
    func markDirty(at pos: BlockPos2) {
        dirtyStrips.insert(pos)
        for neighbor in pos.neighbors {
            dirtyStrips.insert(neighbor)
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node,
              let world = world else { return }
        
        throttler.run(deltaTime: seconds) {
            // Perform a delta update of the chunks
            let requestedChunks = Set(retainCounts.keys)
            let currentChunks = Set(loadedChunks.keys)
            let chunksToLoad = requestedChunks.subtracting(currentChunks)
            let chunksToUnload = currentChunks.subtracting(requestedChunks)
            let stripsToReload = dirtyStrips.filter { !chunksToLoad.contains(ChunkPos(containing: $0)) }
            
            // Unload chunks by removing the corresponding scene nodes from their parents
            for chunkPos in chunksToUnload {
                if let chunkNode = loadedChunks[chunkPos] {
                    chunkNode.removeFromParentNode()
                    loadedChunks[chunkPos] = nil
                }
                for pos in chunkPos {
                    world.uncache(at: pos)
                }
            }
            
            // Load chunks by creating the corresponding scene nodes and attaching them to the world node
            for chunkPos in chunksToLoad {
                let chunkNode = loadChunk(at: chunkPos)
                node.addChildNode(chunkNode)
                loadedChunks[chunkPos] = chunkNode
            }
            
            // Reload dirty strips that aren't in the newly loaded chunks
            reload(strips: stripsToReload)
        } orElse: {
            // Reload all dirty strips immediately if there are any
            reload(strips: dirtyStrips)
        }
        
        dirtyStrips = []
    }
    
    private func reload(strips: Set<BlockPos2>) {
        for pos in strips {
            let chunkPos = ChunkPos(containing: pos)
            if let chunkNode = loadedChunks[chunkPos] {
                // TODO: Investigate efficiency here?
                for blockNode in chunkNode.childNodes where BlockPos3(rounding: blockNode.position).asBlockPos2 == pos {
                    blockNode.removeFromParentNode()
                }
                loadStrip(at: pos, into: chunkNode)
            }
        }
    }
    
    private func loadChunk(at chunkPos: ChunkPos) -> SCNNode {
        let chunkNode = SCNNode()
        
        for pos in chunkPos {
            loadStrip(at: pos, into: chunkNode)
        }
        
        return chunkNode
    }
    
    private func loadStrip(at pos: BlockPos2, into chunkNode: SCNNode) {
        guard let world = world else { return }
        
        for (y, block) in world[pos] {
            let blockPos = pos.with(y: y)
            // Only add blocks that aren't fully occluded
            if !checkOcclusions || !world.isOccluded(at: blockPos) {
                let blockNode = makeBlockNode(for: block)
                blockNode.position = blockPos.asSCNVector
                chunkNode.addChildNode(blockNode)
            }
        }
    }
}
