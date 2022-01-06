import Foundation

/// A model of the world.
struct World {
    var map: [GridPos2: Strip] = [:]
    
    /// Creates a simple demo world using a little bit of trigonometry.
    static func wavyGrassHills(radius: Int = 50) -> World {
        World(map: Dictionary(uniqueKeysWithValues:
            (-radius...radius).flatMap { (x: Int) in
                (-radius...radius).map { (z: Int) in
                    (GridPos2(x: x, z: z), Strip(blocks: Dictionary(uniqueKeysWithValues: [
                        (
                            Int((-5 * sin(CGFloat(x) / 10) * cos(CGFloat(z) / 10)).rounded()),
                            Block(type: .grass)
                        )
                    ])))
                }
            }
       ))
    }
    
    /// Fetches the height the given position. O(n) where n is the number of blocks in the strip at the given (x, z) coordinates.
    func height(at pos: GridPos2) -> Int? {
        map[pos]?.topmost?.y
    }
    
    /// Fetches the block at the given position. O(1).
    func block(at pos: GridPos3) -> Block? {
        map[pos.asGridPos2]?.blocks[pos.y]
    }
}
