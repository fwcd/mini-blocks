//
//  GKComponentSystem.swift
//  WatchGameplayKit
//
//  Created by Fredrik on 22.04.22.
//

import Foundation

public class GKComponentSystem {
    private let componentClass: GKComponent.Type
    private var components: [GKComponent] = []
    
    public init(componentClass: GKComponent.Type) {
        self.componentClass = componentClass
    }
    
    public func addComponent(foundIn entity: GKEntity) {
        for component in entity.components where type(of: component) == componentClass {
            components.append(component)
        }
    }
    
    public func removeComponent(foundIn entity: GKEntity) {
        for component in entity.components where type(of: component) == componentClass {
            components.removeAll { $0 === component }
        }
    }
    
    public func update(deltaTime seconds: TimeInterval) {
        for component in components {
            component.update(deltaTime: seconds)
        }
    }
}
