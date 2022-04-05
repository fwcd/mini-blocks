protocol Vec3Convertible {
    associatedtype AssociatedVec3: Vec3Protocol
    
    func with(y: AssociatedVec3.Coordinate) -> AssociatedVec3
}

extension Vec3Convertible where Self: Vec2Protocol, Coordinate == AssociatedVec3.Coordinate {
    func with(y: AssociatedVec3.Coordinate) -> AssociatedVec3 {
        AssociatedVec3(x: x, y: y, z: z)
    }
}
