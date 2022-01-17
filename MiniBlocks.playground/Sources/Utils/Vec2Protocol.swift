/// A 2D vector.
protocol Vec2Protocol {
    associatedtype Coordinate: SignedNumeric
    
    var x: Coordinate { get set }
    var z: Coordinate { get set }
    
    init(x: Coordinate, z: Coordinate)
}

extension Vec2Protocol {
    var squaredLength: Coordinate {
        (x * x) + (z * z)
    }
    
    var neighbors: [Self] {
        [
            self + Self(x: 1),
            self - Self(x: 1),
            self + Self(z: 1),
            self - Self(z: 1)
        ]
    }
    
    init() {
        self.init(x: 0, z: 0)
    }
    
    init(x: Coordinate) {
        self.init(x: x, z: 0)
    }
    
    init(z: Coordinate) {
        self.init(x: 0, z: z)
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
    
    static func *(lhs: Self, rhs: Coordinate) -> Self {
        Self(x: lhs.x * rhs, z: lhs.z * rhs)
    }
    
    static func *(lhs: Coordinate, rhs: Self) -> Self {
        rhs * lhs
    }
    
    static func *=(lhs: inout Self, rhs: Coordinate) {
        lhs.x *= rhs
        lhs.z *= rhs
    }
}

extension Vec2Protocol where Coordinate: FloatingPoint {
    static func /(lhs: Self, rhs: Coordinate) -> Self {
        Self(x: lhs.x / rhs, z: lhs.z / rhs)
    }
    
    static func /=(lhs: inout Self, rhs: Coordinate) {
        lhs.x /= rhs
        lhs.z /= rhs
    }
}

extension Vec2Protocol where Coordinate: SignedInteger {
    static func /(lhs: Self, rhs: Coordinate) -> Self {
        Self(x: lhs.x / rhs, z: lhs.z / rhs)
    }
    
    static func /=(lhs: inout Self, rhs: Coordinate) {
        lhs.x /= rhs
        lhs.z /= rhs
    }
}
