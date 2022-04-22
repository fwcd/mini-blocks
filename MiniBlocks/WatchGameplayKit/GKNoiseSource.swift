//
//  GKNoiseSource.swift
//  WatchGameplayKit
//
//  Created by Fredrik on 22.04.22.
//

import Foundation

protocol GKNoiseSource {
    func sample(x: Float, y: Float) -> Float
}
