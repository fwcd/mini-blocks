import SceneKit

// Adds the missing operator overloads to SceneKit vectors.
extension SCNVector3: Vec3Protocol {}

extension Vec3Protocol where Coordinate: SignedInteger {
    init(rounding scnVector: SCNVector3) {
        self.init(
            x: Coordinate(scnVector.x.rounded()),
            y: Coordinate(scnVector.y.rounded()),
            z: Coordinate(scnVector.z.rounded())
        )
    }
    
    var asSCNVector: SCNVector3 {
        SCNVector3(x: SceneFloat(x), y: SceneFloat(y), z: SceneFloat(z))
    }
}
