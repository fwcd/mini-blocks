//
//  GKPerlinNoiseSource.swift
//  WatchGameplayKit
//
//  Created by Fredrik on 22.04.22.
//

import Foundation

public class GKPerlinNoiseSource: GKNoiseSource {
    private let frequency: Double
    private let octaveCount: Int
    private let persistence: Double
    private let lacunarity: Double
    private let seed: Int32
    
    public init(
        frequency: Double,
        octaveCount: Int,
        persistence: Double,
        lacunarity: Double,
        seed: Int32
    ) {
        self.frequency = frequency
        self.octaveCount = octaveCount
        self.persistence = persistence
        self.lacunarity = lacunarity
        self.seed = seed
    }
    
    // TODO: Use the parameters
    // Implementation based on https://en.wikipedia.org/wiki/Perlin_noise
    
    func sample(x: Float, y: Float) -> Float {
        // Determine grid cell coordinates
        let x0 = Int(x)
        let x1 = x0 + 1
        let y0 = Int(y)
        let y1 = y0 + 1
        
        // Determine interpolation weights
        let sx = x - Float(x0)
        let sy = y - Float(y0)
        
        // Interpolate between grid point gradients
        let ix0 = interpolate(
            between: dotGridGradient(ix: x0, iy: y0, x: x, y: y),
            and: dotGridGradient(ix: x1, iy: y0, x: x, y: y),
            weight: sx
        )
        let ix1 = interpolate(
            between: dotGridGradient(ix: x0, iy: y1, x: x, y: y),
            and: dotGridGradient(ix: x1, iy: y1, x: x, y: y),
            weight: sx
        )
        
        return interpolate(between: ix0, and: ix1, weight: sy)
    }
    
    private func dotGridGradient(ix: Int, iy: Int, x: Float, y: Float) -> Float {
        // Generate random vector
        let angle = Float([ix, iy].hashValue)
        let gx = cos(angle)
        let gy = sin(angle)
        
        // Compute distance to grid cell
        let dx = x - Float(ix)
        let dy = y - Float(iy)
        
        // Compute dot product
        return dx * gx + dy * gy
    }
    
    private func interpolate(between x: Float, and y: Float, weight w: Float) -> Float {
        // Interpolate linearly
        x + w * (y - x)
    }
}
