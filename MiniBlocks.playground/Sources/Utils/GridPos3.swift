import SceneKit

/// A position in the 3D grid.
struct GridPos3: Hashable, Codable {
    let x: Int
    let y: Int
    let z: Int
    
    var asSCNVector: SCNVector3 {
        SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
    }
    
    var asGridPos2: GridPos2 {
        GridPos2(x: x, z: z)
    }
    
    static func +(lhs: Self, rhs: Self) -> Self {
        GridPos3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        GridPos3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
}
