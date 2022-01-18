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
    
    mutating func submit(deltaTime: TimeInterval, defer: Bool, force: Bool = false, action: () -> Void) {
        if force {
            action()
            state = .idling
        } else {
            switch state {
            case .idling:
                if `defer` {
                    state = .deferring(timeSinceLastRun: 0)
                }
            case .deferring(timeSinceLastRun: var timeSinceLastRun):
                timeSinceLastRun += deltaTime
                if `defer` {
                    state = .deferring(timeSinceLastRun: 0)
                } else if timeSinceLastRun <= interval {
                    state = .deferring(timeSinceLastRun: timeSinceLastRun)
                } else {
                    action()
                    state = .idling
                }
            }
        }
    }
}
