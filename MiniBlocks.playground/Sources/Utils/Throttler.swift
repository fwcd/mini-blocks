import Foundation

/// A facility that only executes an action if it hasn't executed within the last interval.
struct Throttler {
    let interval: TimeInterval
    private var lastRun: TimeInterval = 0
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    mutating func run(deltaTime: TimeInterval, action: () -> Void, orElse alternativeAction: () -> Void = {}) {
        lastRun += deltaTime
        if lastRun > interval {
            action()
            lastRun = 0
        } else {
            alternativeAction()
        }
    }
}
