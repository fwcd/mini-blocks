struct Vec3: Hashable, Codable, Vec3Protocol {
    var x: Double
    var y: Double
    var z: Double
    
    init(x: Double = 0, y: Double = 0, z: Double = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
}
