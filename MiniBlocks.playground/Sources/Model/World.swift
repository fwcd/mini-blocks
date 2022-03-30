import Foundation

/// A model of the world.
struct World: Codable, Sequence {
    enum CodingKeys: String, CodingKey {
        case generator
        case storedStrips = "strips"
        case playerInfos
    }
    
    /// The procedural generator that generates new strips.
    let generator: WorldGeneratorType
    
    /// The user-changed strips (which are to be saved).
    private(set) var storedStrips: [BlockPos2: Strip] = [:]
    
    /// The cached strips.
    @Box private var cachedStrips: [BlockPos2: Strip] = [:]
    
    /// Information about the players, keyed by username.
    private(set) var playerInfos: [String: PlayerInfo] = [:]
    
    /// Fetches the strip at the given position.
    subscript(_ pos: BlockPos2) -> Strip {
        get {
            if let strip = storedStrips[pos] ?? cachedStrips[pos] {
                return strip
            } else {
                let strip = generator.generate(at: pos)
                cachedStrips[pos] = strip
                return strip
            }
        }
        set {
            uncache(at: pos)
            storedStrips[pos] = newValue
        }
    }
    
    /// Fetches the player info for the given player name.
    subscript(playerInfoFor name: String) -> PlayerInfo {
        get { playerInfos[name] ?? PlayerInfo() }
        set { playerInfos[name] = newValue }
    }
    
    /// Removes the given strip from the cache. Doesn't change anything about the world semantically. O(1).
    func uncache(at pos: BlockPos2) {
        cachedStrips[pos] = nil
    }
    
    /// Creates an iterator over the strips.
    func makeIterator() -> Dictionary<BlockPos2, Strip>.Iterator {
        storedStrips.makeIterator()
    }
    
    /// Fetches the height the given position. O(n) where n is the number of blocks in the strip at the given (x, z) coordinates.
    func height(at pos: BlockPos2) -> Int? {
        self[pos].topmost?.y
    }
    
    /// Fetches the height below the given position. O(n) where n is the number of blocks in the strip at the given (x, z) coordinates.
    func height(below pos: BlockPos3) -> Int? {
        self[pos.asVec2].block(below: pos.y)?.y
    }
    
    /// Fetches the block at the given position. O(1).
    func block(at pos: BlockPos3) -> Block? {
        self[pos.asVec2][pos.y]
    }
    
    /// Checks whether there is a block at the given position. O(1).
    func hasBlock(at pos: BlockPos3) -> Bool {
        block(at: pos) != nil
    }
    
    /// Checks whether the block at the given position is fully occluded by others. O(1).
    func isOccluded(at pos: BlockPos3) -> Bool {
        eachNeighbor(at: pos) {
            block(at: $0).map { $0.type.isOpaque || $0.type.isLiquid } ?? false
        }
    }
    
    /// Checks whether something applies to all neighbors. We use this instead of e.g. reducing over the neighbor array for performance as many such checks (e.g. isOccluded) are on the hot path.
    func eachNeighbor(at pos: BlockPos3, satisfies predicate: (BlockPos3) -> Bool) -> Bool {
           predicate(pos + BlockPos3(x: 1))
        && predicate(pos - BlockPos3(x: 1))
        && predicate(pos + BlockPos3(y: 1))
        && predicate(pos - BlockPos3(y: 1))
        && predicate(pos + BlockPos3(z: 1))
        && predicate(pos - BlockPos3(z: 1))
    }
    
    /// Place the given block at the given position. O(1).
    mutating func place(block: Block?, at pos: BlockPos3) {
        self[pos.asVec2][pos.y] = block
    }
    
    /// Removes the block at the given position. O(1).
    mutating func breakBlock(at pos: BlockPos3) {
        place(block: nil, at: pos)
    }
}
