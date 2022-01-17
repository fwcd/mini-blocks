import SceneKit

/// A position in the 3D block grid.
struct BlockPos3: Hashable, Codable, Vec3Protocol, Vec2Convertible {
    typealias AssociatedVec2 = BlockPos2
    
    var x: Int
    var y: Int
    var z: Int
    
    init(x: Int = 0, y: Int = 0, z: Int = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
}
