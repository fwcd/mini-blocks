import Foundation

/// A facility that only executes an action if it hasn't executed within the last interval.
struct Throttler {
    let interval: TimeInterval
    private var timeSinceLastRun: TimeInterval = .infinity
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    mutating func submit(deltaTime: TimeInterval, action: () -> Void, orElse alternativeAction: () -> Void = {}) {
        advance(deltaTime: deltaTime)
        if timeSinceLastRun > interval {
            action()
            timeSinceLastRun = 0
        } else {
            alternativeAction()
        }
    }
    
    mutating func advance(deltaTime: TimeInterval) {
        timeSinceLastRun += deltaTime
    }
    
    mutating func reset() {
        timeSinceLastRun = .infinity
    }
}
