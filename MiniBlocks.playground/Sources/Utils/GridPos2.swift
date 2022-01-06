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
        GridPos2(x: lhs.x + rhs.x, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        GridPos2(x: lhs.x - rhs.x, z: lhs.z - rhs.z)
    }
    
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.x += rhs.x
        lhs.z += rhs.z
    }
    
    static func -=(lhs: inout Self, rhs: Self) {
        lhs.x -= rhs.x
        lhs.z -= rhs.z
    }
    
    func with(y: Int) -> GridPos3 {
        GridPos3(x: x, y: y, z: z)
    }
}
