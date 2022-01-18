import Foundation

/// A facility that only executes an action after some time has passed. Relies on an update loop (such as the one provided by SceneKit) that repeatedly calls update.
struct Debouncer {
    let interval: TimeInterval
    private var state: State = .idling
    
    private enum State {
        case idling
        case deferring(timeSinceLastRun: TimeInterval)
    }
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    mutating func run(deltaTime: TimeInterval, defer: Bool, action: () -> Void) {
        switch state {
        case .idling:
            if `defer` {
                state = .deferring(timeSinceLastRun: 0)
            }
        case .deferring(timeSinceLastRun: let timeSinceLastRun):
            if `defer` {
                state = .deferring(timeSinceLastRun: timeSinceLastRun + deltaTime)
            } else if timeSinceLastRun > interval {
                action()
            }
        }
    }
}
