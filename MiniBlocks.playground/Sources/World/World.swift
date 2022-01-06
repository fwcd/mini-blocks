import Foundation

/// A model of the world.
struct World {
    var map: [GridPos2: Strip] = [:]
    
    /// Creates a simple demo world using a little bit of trigonometry.
    static func wavyGrassHills(radius: Int = 50) -> World {
        World(map: Dictionary(uniqueKeysWithValues:
            (-radius...radius).flatMap { (x: Int) in
                (-radius...radius).map { (z: Int) in
                    (GridPos2(x: x, z: z), Strip(blocks: [
                        StripBlock(
                            y: Int((-5 * sin(CGFloat(x) / 10) * cos(CGFloat(z) / 10)).rounded()),
                            block: Block(type: .grass)
                        )
                    ]))
                }
            }
       ))
    }
    
    func height(at pos: GridPos2) -> Int? {
        map[pos]?.topmostBlock?.y
    }
}
