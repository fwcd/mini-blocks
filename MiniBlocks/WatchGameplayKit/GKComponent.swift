//
//  GKComponent.swift
//  WatchGameplayKit
//
//  Created by Fredrik on 22.04.22.
//

import Foundation

public class GKComponent {
    public internal(set) weak var entity: GKEntity?
    
    public func update(deltaTime seconds: TimeInterval) {}
}
