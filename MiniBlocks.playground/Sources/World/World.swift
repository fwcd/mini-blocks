import Foundation

/// A model of the world.
struct World: Codable, Sequence {
    enum CodingKeys: String, CodingKey {
        case storedStrips = "strips"
        case generator
    }
    
    /// The user-changed strips (which are to be saved).
    var storedStrips: [GridPos2: Strip] = [:]
    
    /// The procedural generator that generates new strips.
    let generator: WorldGeneratorType
    
    /// The cached strips.
    @Box private var cachedStrips: [GridPos2: Strip] = [:]
    
    /// Fetches the strip at the given position.
    subscript(pos: GridPos2) -> Strip {
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
            storedStrips[pos] = newValue
        }
    }
    
    /// Removes the given strip from the cache. Doesn't change anything about the world semantically. O(1).
    func uncache(at pos: GridPos2) {
        cachedStrips[pos] = nil
    }
    
    /// Creates an iterator over the strips.
    func makeIterator() -> Dictionary<GridPos2, Strip>.Iterator {
        storedStrips.makeIterator()
    }
    
    /// Fetches the height the given position. O(n) where n is the number of blocks in the strip at the given (x, z) coordinates.
    func height(at pos: GridPos2) -> Int? {
        self[pos].topmost?.y
    }
    
    /// Fetches the block at the given position. O(1).
    func block(at pos: GridPos3) -> Block? {
        self[pos.asGridPos2][pos.y]
    }
    
    /// Checks whether there is a block at the given position. O(1).
    func hasBlock(at pos: GridPos3) -> Bool {
        block(at: pos) != nil
    }
    
    /// Checks whether there is an opaque block at the given position. O(1).
    func hasOpaqueBlock(at pos: GridPos3) -> Bool {
        block(at: pos)?.type.isOpaque ?? false
    }
    
    /// Checks whether the block at the given position is fully occluded by others. O(1).
    func isOccluded(at pos: GridPos3) -> Bool {
        // Since this method is often on the hot path, we explicitly enumerate all neighbors here instead of using higher level constructs such as neighbor arrays, which the Swift compiler currently isn't smart enough to optimize away.
           hasOpaqueBlock(at: pos + GridPos3(x: 1))
        && hasOpaqueBlock(at: pos - GridPos3(x: 1))
        && hasOpaqueBlock(at: pos + GridPos3(y: 1))
        && hasOpaqueBlock(at: pos - GridPos3(y: 1))
        && hasOpaqueBlock(at: pos + GridPos3(z: 1))
        && hasOpaqueBlock(at: pos - GridPos3(z: 1))
    }
    
    /// Place the given block at the given position. O(1).
    mutating func place(block: Block?, at pos: GridPos3) {
        self[pos.asGridPos2][pos.y] = block
    }
    
    /// Removes the block at the given position. O(1).
    mutating func breakBlock(at pos: GridPos3) {
        place(block: nil, at: pos)
    }
}
