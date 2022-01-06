import SceneKit

/// A block position in the 3D grid.
struct BlockPos: Hashable, Codable {
    let x: Int
    let y: Int
    let z: Int
    
    var asSCNVector: SCNVector3 {
        SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
    }
    
    static func +(lhs: Self, rhs: Self) -> Self {
        BlockPos(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        BlockPos(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
}
