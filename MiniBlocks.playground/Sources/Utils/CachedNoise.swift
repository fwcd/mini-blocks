import GameplayKit

/// A memorizing variant of GKNoise that operates on grid positions.
struct CachedNoise {
    private let noise: GKNoise
    private let scale: Float
    @Box private var cache = FIFOCache<GridPos2, Float>(capacity: 64)
    
    @Box private var hits: Int = 0
    @Box private var misses: Int = 0
    
    init(noise: GKNoise, scale: Float) {
        self.noise = noise
        self.scale = scale
    }
    
    func value(at pos: GridPos2) -> Float {
        if (hits + misses) % 10000 == 0 {
            print("Hits: \(hits), misses: \(misses), ratio: \(Float(hits) / Float(misses))")
        }
        if let cachedValue = cache[pos] {
            hits += 1
            return cachedValue
        } else {
            misses += 1
            let newValue = noise.value(atPosition: vectorOf(pos: pos))
            cache.insert(pos, newValue)
            return newValue
        }
    }
    
    private func vectorOf(pos: GridPos2) -> vector_float2 {
        vector_float2(x: Float(pos.x) / scale, y: Float(pos.z) / scale)
    }
}
