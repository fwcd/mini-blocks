public enum GameMode: Int, Codable, Hashable {
    case creative = 0
    case survival
    
    var permitsFlight: Bool {
        [.creative].contains(self)
    }
    
    var enablesGravityAndCollisions: Bool {
        [.survival].contains(self)
    }
}
