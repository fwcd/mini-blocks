import Foundation

/// A model of the world.
struct World {
    var map: [GridPos2: Strip] = [:]
    
    /// Generates a world.
    static func generate(radius: Int = 48, generator y: (GridPos2) -> Int) -> World {
        World(map: Dictionary(uniqueKeysWithValues:
            (-radius...radius).flatMap { (x: Int) in
                (-radius...radius).map { (z: Int) in
                    let pos = GridPos2(x: x, z: z)
                    return (pos, Strip(blocks: Dictionary(uniqueKeysWithValues: [
                        (y(pos), Block(type: .grass))
                    ])))
                }
            }
       ))
    }
    
    /// Creates a simple demo world using a little bit of trigonometry.
    static func wavyGrassHills(radius: Int = 48) -> World {
        generate(radius: radius) { pos in
            Int((-5 * sin(CGFloat(pos.x) / 10) * cos(CGFloat(pos.z) / 10)).rounded())
        }
    }
    
    static func flat(radius: Int = 50) -> World {
        generate(radius: radius) { _ in
            0
        }
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
