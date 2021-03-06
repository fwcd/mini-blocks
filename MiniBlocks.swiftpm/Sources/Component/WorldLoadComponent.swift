import GameplayKit
import SceneKit
import OSLog

private let log = Logger(subsystem: "MiniBlocks", category: "WorldLoadComponent")

/// Loads chunks from the world model into the SceneKit node.
class WorldLoadComponent: GKComponent {
    /// The 'reference-counts' of each chunk retainer (e.g. players).
    private var retainCounts: [ChunkPos: Int] = [:]
    
    /// The currently loaded chunks with their associated SceneKit nodes.
    private var loadedChunks: [ChunkPos: SCNNode] = [:]
    
    /// The chunks for which an unload has been requested.
    private var unloadRequestedChunks: Set<ChunkPos> = []
    
    /// Strips marked as dirty (e.g. because the user placed/removed blocks there).
    private var dirtyStrips: Set<BlockPos2> = []
    
    /// Performs occlusion checking before rendering. Makes chunk loading slower and rendering faster.
    private var checkOcclusions: Bool = true
    
    /// Throttles chunk loading to a fixed interval.
    private var throttler = Throttler(interval: 0.5)
    
    /// Debounces chunk unloading to a fixed interval.
    private var debouncer = Debouncer(interval: 2)
    
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
        
        throttler.submit(deltaTime: seconds) {
            // Perform a delta update of the chunks
            let requestedChunks = Set(retainCounts.keys)
            let currentChunks = Set(loadedChunks.keys)
            let chunksToLoad = requestedChunks.subtracting(currentChunks)
            let chunksToUnload = currentChunks.subtracting(requestedChunks)
            let stripsToReload = dirtyStrips.filter { !chunksToLoad.contains(ChunkPos(containing: $0)) }
            
            // Unload chunks by marking their chunks as requested for unloading
            // (we don't unload them directly by removing them from the loadedChunks and the scene since especially the latter seems to be an expensive operation).
            unloadRequestedChunks.subtract(chunksToLoad)
            unloadRequestedChunks.formUnion(chunksToUnload)
            
            if !chunksToLoad.isEmpty {
                log.info("Loading \(chunksToLoad.count) chunk(s)...")
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
        
        let playersIdling = world.playerInfos.values.allSatisfy { $0.velocity == .zero }
        let unloadCount = unloadRequestedChunks.count
        let unloadingOverdue = unloadCount > 350
        
        debouncer.submit(deltaTime: seconds, defer: !playersIdling, force: unloadingOverdue) {
            if unloadCount > 0 {
                log.info("Unloading \(unloadCount) chunk(s)...")
            }
            
            // Unload chunks
            for chunkPos in unloadRequestedChunks {
                if let chunkNode = loadedChunks[chunkPos] {
                    chunkNode.removeFromParentNode()
                    loadedChunks[chunkPos] = nil
                }
                for pos in chunkPos {
                    world.uncache(at: pos)
                }
            }
            
            unloadRequestedChunks = []
        }
        
        dirtyStrips = []
    }
    
    private func reload(strips: Set<BlockPos2>) {
        for pos in strips {
            let chunkPos = ChunkPos(containing: pos)
            if let chunkNode = loadedChunks[chunkPos] {
                // TODO: Investigate efficiency here?
                for blockNode in chunkNode.childNodes where BlockPos3(rounding: blockNode.position).asVec2 == pos {
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
                blockNode.position = SCNVector3(blockPos)
                chunkNode.addChildNode(blockNode)
            }
        }
    }
}
