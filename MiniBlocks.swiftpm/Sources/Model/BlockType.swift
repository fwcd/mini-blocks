/// A 'kind' of block.
enum BlockType: Int, Hashable, Codable {
    case grass = 0
    case sand
    case stone
    case water
    case wood
    case leaves
    case bedrock
    
    var isTranslucent: Bool {
        [.water, .leaves].contains(self)
    }
    
    var isOpaque: Bool {
        !isTranslucent
    }
    
    var isLiquid: Bool {
        self == .water
    }
}
