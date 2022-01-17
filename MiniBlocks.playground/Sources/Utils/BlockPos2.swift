import SceneKit

/// A flat position on the block grid.
struct BlockPos2: Hashable, Codable, Vec2Protocol, Vec3Convertible {
    typealias AssociatedVec3 = BlockPos3
    
    var x: Int
    var z: Int
    
    init(x: Int = 0, z: Int = 0) {
        self.x = x
        self.z = z
    }
}
