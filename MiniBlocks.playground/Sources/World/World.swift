import Foundation

/// A model of the world.
struct World: Hashable, Codable, Sequence {
    /// The user-changed strips (which are to be saved).
    var storedStrips: [GridPos2: Strip] = [:]
    
    /// The procedural generator that generates new strips.
    let generator: WorldGeneratorType
    
    /// Fetches the strip at the given position.
    subscript(pos: GridPos2) -> Strip {
        get { storedStrips[pos] ?? generator.generate(at: pos) }
        set { storedStrips[pos] = newValue }
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
    
    /// Checks whether the block at the given position is fully occluded by others. O(1).
    func isOccluded(at pos: GridPos3) -> Bool {
           block(at: pos + GridPos3(x: 1)) != nil
        && block(at: pos - GridPos3(x: 1)) != nil
        && block(at: pos + GridPos3(y: 1)) != nil
        && block(at: pos - GridPos3(y: 1)) != nil
        && block(at: pos + GridPos3(z: 1)) != nil
        && block(at: pos - GridPos3(z: 1)) != nil
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
