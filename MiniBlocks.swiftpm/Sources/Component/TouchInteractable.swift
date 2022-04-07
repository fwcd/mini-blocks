import SpriteKit

/// Indicates that the implementing component may be controlled by touch.
protocol TouchInteractable {
    func onTap(at point: CGPoint) -> Bool
    
    func onDragStart(at point: CGPoint) -> Bool
    
    func onDragMove(by delta: CGVector, start: CGPoint, current: CGPoint)
    
    func onDragEnd()
}

extension TouchInteractable {
    func onTap(at point: CGPoint) -> Bool { false }
    
    func onDragStart(at point: CGPoint) -> Bool { false }
    
    func onDragMove(by delta: CGVector, start: CGPoint, current: CGPoint) {}
    
    func onDragEnd() {}
}
