import SceneKit

/// A flat position on the chunk grid.
struct ChunkPos: Hashable, Codable, Sequence {
    var x: Int
    var z: Int
    
    var topLeftInclusive: GridPos2 {
        GridPos2(x: x * ChunkConstants.size, z: z * ChunkConstants.size)
    }
    
    var bottomRightExclusive: GridPos2 {
        GridPos2(x: (x + 1) * ChunkConstants.size, z: (z + 1) * ChunkConstants.size)
    }
    
    init(x: Int = 0, z: Int = 0) {
        self.x = x
        self.z = z
    }
    
    func makeIterator() -> Grid2Iterator {
        Grid2Iterator(topLeftInclusive: topLeftInclusive, bottomRightExclusive: bottomRightExclusive)
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
}
