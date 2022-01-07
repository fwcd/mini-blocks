import SceneKit

/// A position in the 3D block grid.
struct GridPos3: Hashable, Codable, Pos3 {
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
}
