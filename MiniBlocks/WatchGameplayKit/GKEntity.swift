//
//  GKEntity.swift
//  WatchGameplayKit
//
//  Created by Fredrik on 22.04.22.
//

import Foundation

public class GKEntity {
    public private(set) var components: [GKComponent] = []
    
    public init() {}
    
    public func addComponent(_ component: GKComponent) {
        component.entity = self
        components.append(component)
    }
    
    public func component<T>(ofType t: T.Type) -> T? where T: GKComponent {
        components.compactMap { $0 as? T }.first
    }
}
