//
//  GKPerlinNoiseSource.swift
//  WatchGameplayKit
//
//  Created by Fredrik on 22.04.22.
//

import Foundation

public class GKPerlinNoiseSource {
    private let frequency: Double
    private let octaveCount: Int
    private let persistence: Double
    private let lacunarity: Double
    private let seed: Int32
    
    // TODO
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
}
