protocol Vec2Convertible {
    associatedtype AssociatedVec2: Vec2Protocol
    
    var asVec2: AssociatedVec2 { get }
}

extension Vec2Convertible where Self: Vec3Protocol, Coordinate == AssociatedVec2.Coordinate {
    var asVec2: AssociatedVec2 {
        AssociatedVec2(x: x, z: z)
    }
}

