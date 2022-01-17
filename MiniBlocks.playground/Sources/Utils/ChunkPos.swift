import SceneKit

/// A flat position on the chunk grid.
struct ChunkPos: Hashable, Codable, Sequence, Vec2 {
    var x: Int
    var z: Int
    
    var topLeftInclusive: BlockPos2 {
        BlockPos2(x: x * ChunkConstants.size, z: z * ChunkConstants.size)
    }
    
    var bottomRightExclusive: BlockPos2 {
        BlockPos2(x: (x + 1) * ChunkConstants.size, z: (z + 1) * ChunkConstants.size)
    }
    
    init(containing pos: BlockPos2) {
        x = pos.x.floorDiv(ChunkConstants.size)
        z = pos.z.floorDiv(ChunkConstants.size)
    }
    
    init(x: Int, z: Int) {
        self.x = x
        self.z = z
    }
    
    func makeIterator() -> GridIterator2<BlockPos2> {
        GridIterator2(topLeftInclusive: topLeftInclusive, bottomRightExclusive: bottomRightExclusive)
    }
}
