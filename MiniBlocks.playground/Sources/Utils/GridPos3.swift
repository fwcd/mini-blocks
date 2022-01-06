import SceneKit

/// A position in the 3D grid.
struct GridPos3: Hashable, Codable {
    var x: Int
    var y: Int
    var z: Int
    
    var asSCNVector: SCNVector3 {
        SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
    }
    
    var asGridPos2: GridPos2 {
        GridPos2(x: x, z: z)
    }
    
    init(x: Int = 0, y: Int = 0, z: Int = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(rounding scnVector: SCNVector3) {
        x = Int(scnVector.x.rounded())
        y = Int(scnVector.y.rounded())
        z = Int(scnVector.z.rounded())
    }
    
    static func +(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.x += rhs.x
        lhs.y += rhs.y
        lhs.z += rhs.z
    }
    
    static func -=(lhs: inout Self, rhs: Self) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
        lhs.z -= rhs.z
    }
    
    static prefix func -(rhs: Self) -> Self {
        Self(x: -rhs.x, y: -rhs.y, z: -rhs.z)
    }
}
