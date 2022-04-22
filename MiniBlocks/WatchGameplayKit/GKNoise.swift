//
//  GKNoise.swift
//  WatchGameplayKit
//
//  Created by Fredrik on 22.04.22.
//

import Foundation

public class GKNoise {
    private let source: GKPerlinNoiseSource
    
    public init(_ source: GKPerlinNoiseSource) {
        self.source = source
    }
    
    public func value(atPosition pos: vector_float2) -> Float {
        source.sample(x: pos.x, y: pos.y)
    }
}


