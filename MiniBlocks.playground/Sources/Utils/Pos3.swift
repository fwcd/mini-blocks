/// A 3D grid-like position.
protocol Pos3 {
    associatedtype Coordinate: SignedInteger
    
    var x: Coordinate { get set }
    var y: Coordinate { get set }
    var z: Coordinate { get set }
    
    init(x: Coordinate, y: Coordinate, z: Coordinate)
}

extension Pos3 {
    init() {
        self.init(x: 0, y: 0, z: 0)
    }
    
    init(x: Coordinate) {
        self.init(x: x, y: 0, z: 0)
    }
    
    init(y: Coordinate) {
        self.init(x: 0, y: y, z: 0)
    }
    
    init(z: Coordinate) {
        self.init(x: 0, y: 0, z: z)
    }
    
    var neighbors: [Self] {
        [
            self + Self(x: 1),
            self - Self(x: 1),
            self + Self(y: 1),
            self - Self(y: 1),
            self + Self(z: 1),
            self - Self(z: 1)
        ]
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
    
    static func *(lhs: Self, rhs: Coordinate) -> Self {
        Self(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    static func *(lhs: Coordinate, rhs: Self) -> Self {
        rhs * lhs
    }
    
    static func /(lhs: Self, rhs: Coordinate) -> Self {
        Self(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    static func *=(lhs: inout Self, rhs: Coordinate) {
        lhs.x *= rhs
        lhs.y *= rhs
        lhs.z *= rhs
    }
    
    static func /=(lhs: inout Self, rhs: Coordinate) {
        lhs.x /= rhs
        lhs.y /= rhs
        lhs.z /= rhs
    }
}
