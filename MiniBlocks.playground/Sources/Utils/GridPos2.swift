import SceneKit

/// A flat position on the grid.
struct GridPos2: Hashable, Codable {
    let x: Int
    let z: Int
    
    static func +(lhs: Self, rhs: Self) -> Self {
        GridPos2(x: lhs.x + rhs.x, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        GridPos2(x: lhs.x - rhs.x, z: lhs.z - rhs.z)
    }
    
    func with(y: Int) -> GridPos3 {
        GridPos3(x: x, y: y, z: z)
    }
}
