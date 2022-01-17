import SceneKit

/// A position in the 3D block grid.
struct BlockPos3: Hashable, Codable, Vec3Protocol {
    var x: Int
    var y: Int
    var z: Int
    
    var asBlockPos2: BlockPos2 {
        BlockPos2(x: x, z: z)
    }
    
    init(x: Int = 0, y: Int = 0, z: Int = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
}
