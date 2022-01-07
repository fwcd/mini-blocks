import SceneKit

/// A flat position on the block grid.
struct GridPos2: Hashable, Codable, Pos2 {
    var x: Int
    var z: Int
    
    init(x: Int = 0, z: Int = 0) {
        self.x = x
        self.z = z
    }
    
    func with(y: Int) -> GridPos3 {
        GridPos3(x: x, y: y, z: z)
    }
}
