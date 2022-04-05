struct Vec2: Hashable, Codable, Vec2Protocol {
    var x: Double
    var z: Double
    
    init(x: Double = 0, z: Double = 0) {
        self.x = x
        self.z = z
    }
}
