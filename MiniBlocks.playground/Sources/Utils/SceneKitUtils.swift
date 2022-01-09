import SceneKit

/// The missing operator overloads for SceneKit vectors.
extension SCNVector3 {
    var length: CGFloat {
        (x * x + y * y + z * z).squareRoot()
    }
    
    var manhattanLength: CGFloat {
        abs(x) + abs(y)
    }
    
    var normalized: Self {
        self / length
    }
    
    func manhattanDistance(to rhs: Self) -> CGFloat {
        (self - rhs).manhattanLength
    }
    
    func dot(_ rhs: Self) -> CGFloat {
        x * rhs.x + y * rhs.y + z * rhs.z
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
    
    static func *(lhs: Self, rhs: CGFloat) -> Self {
        Self(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    static func *(lhs: CGFloat, rhs: Self) -> Self {
        rhs * lhs
    }
    
    static func /(lhs: Self, rhs: CGFloat) -> Self {
        Self(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    static func *=(lhs: inout Self, rhs: CGFloat) {
        lhs.x *= rhs
        lhs.y *= rhs
        lhs.z *= rhs
    }
    
    static func /=(lhs: inout Self, rhs: CGFloat) {
        lhs.x /= rhs
        lhs.y /= rhs
        lhs.z /= rhs
    }
    
    mutating func normalize() {
        self /= length
    }
}
