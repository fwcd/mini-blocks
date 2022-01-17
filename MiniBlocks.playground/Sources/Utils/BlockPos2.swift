import SceneKit

/// A flat position on the block grid.
struct BlockPos2: Hashable, Codable, Vec2 {
    var x: Int
    var z: Int
    
    init(x: Int = 0, z: Int = 0) {
        self.x = x
        self.z = z
    }
    
    func with(y: Int) -> BlockPos3 {
        BlockPos3(x: x, y: y, z: z)
    }
}
