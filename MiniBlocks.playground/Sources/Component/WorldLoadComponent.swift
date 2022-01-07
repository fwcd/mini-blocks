import GameplayKit
import SceneKit

/// The texture mappings for every block type.
private let textures: [BlockType: NSImage] = [
    .grass: NSImage(named: "TextureGrass.png")!
]

/// Loads chunks from the world model into the SceneKit node.
class WorldLoadComponent: GKComponent {
    /// Number of chunks to render in each direction. Note that although we call it a 'radius', a square grid of chunks is loaded.
    var loadRadius: Int = 2
    
    /// The 'reference-counts' of each chunk retainer (e.g. players).
    private var retainCounts: [ChunkPos: Int] = [:]
    
    /// The currently loaded chunks with their associated SceneKit nodes.
    private var loadedChunks: [ChunkPos: SCNNode] = [:]
    
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
    }///
    
    override func update(deltaTime seconds: TimeInterval) {
        // TODO
    }
    
    private func loadChunk(at chunkPos: ChunkPos) -> SCNNode? {
        guard let world = world else { return nil }
        let chunkNode = SCNNode()
        
        for pos in chunkPos {
            for (y, block) in world[pos] {
                let blockBox = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                blockBox.materials = [loadMaterial(for: block)]
                let blockNode = SCNNode(geometry: blockBox)
                blockNode.position = pos.with(y: y).asSCNVector
                chunkNode.addChildNode(blockNode)
            }
        }
        
        return chunkNode
    }
    
    private func loadMaterial(for block: Block) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = textures[block.type]
        material.diffuse.minificationFilter = .none
        material.diffuse.magnificationFilter = .none
        return material
    }
}
