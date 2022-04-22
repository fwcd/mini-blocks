//
//  GKComponent.swift
//  WatchGameplayKit
//
//  Created by Fredrik on 22.04.22.
//

import Foundation

open class GKComponent: NSObject, NSCoding {
    public internal(set) weak var entity: GKEntity?
    
    public override init() {}
    
    open func update(deltaTime seconds: TimeInterval) {}
    
    public required init?(coder: NSCoder) {
        nil
    }
    
    public func encode(with coder: NSCoder) {
        fatalError("Encoding GKComponent is not supported")
    }
}
