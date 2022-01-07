/// A rectangle of chunks in the world.
struct ChunkRegion: Sequence {
    let topLeftInclusive: ChunkPos
    let bottomRightExclusive: ChunkPos
    
    init(topLeftInclusive: ChunkPos, bottomRightExclusive: ChunkPos) {
        self.topLeftInclusive = topLeftInclusive
        self.bottomRightExclusive = bottomRightExclusive
    }
    
    init(around center: ChunkPos, radius: Int) {
        let radiusVec = ChunkPos(x: radius, z: radius)
        self.init(
            topLeftInclusive: center - radiusVec,
            bottomRightExclusive: center + radiusVec
        )
    }
    
    func makeIterator() -> GridIterator2<ChunkPos> {
        GridIterator2(
            topLeftInclusive: topLeftInclusive,
            bottomRightExclusive: bottomRightExclusive
        )
    }
}
