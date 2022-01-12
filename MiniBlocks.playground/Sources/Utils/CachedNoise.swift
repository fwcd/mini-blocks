import GameplayKit

/// A memorizing variant of GKNoise that operates on grid positions.
struct CachedNoise {
    private let noise: GKNoise
    private let scale: Float
    @Box private var cache = FIFOCache<GridPos2, Float>()
    
    init(noise: GKNoise, scale: Float) {
        self.noise = noise
        self.scale = scale
    }
    
    func value(at pos: GridPos2) -> Float {
        if let cachedValue = cache[pos] {
            return cachedValue
        } else {
            let newValue = noise.value(atPosition: vectorOf(pos: pos))
            cache.insert(pos, newValue)
            return newValue
        }
    }
    
    private func vectorOf(pos: GridPos2) -> vector_float2 {
        vector_float2(x: Float(pos.x) / scale, y: Float(pos.z) / scale)
    }
}
