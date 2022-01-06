import SceneKit

/// A flat position on the grid.
struct GridPos2: Hashable, Codable {
    var x: Int
    var z: Int
    
    init(x: Int = 0, z: Int = 0) {
        self.x = x
        self.z = z
    }
    
    static func +(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, z: lhs.z - rhs.z)
    }
    
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.x += rhs.x
        lhs.z += rhs.z
    }
    
    static func -=(lhs: inout Self, rhs: Self) {
        lhs.x -= rhs.x
        lhs.z -= rhs.z
    }
    
    static prefix func -(rhs: Self) -> Self {
        Self(x: -rhs.x, z: -rhs.z)
    }
    
    static func *(lhs: Self, rhs: Int) -> Self {
        Self(x: lhs.x * rhs, z: lhs.z * rhs)
    }
    
    static func *(lhs: Int, rhs: Self) -> Self {
        rhs * lhs
    }
    
    static func /(lhs: Self, rhs: Int) -> Self {
        Self(x: lhs.x / rhs, z: lhs.z / rhs)
    }
    
    static func *=(lhs: inout Self, rhs: Int) {
        lhs.x *= rhs
        lhs.z *= rhs
    }
    
    static func /=(lhs: inout Self, rhs: Int) {
        lhs.x /= rhs
        lhs.z /= rhs
    }
    
    func with(y: Int) -> GridPos3 {
        GridPos3(x: x, y: y, z: z)
    }
}
