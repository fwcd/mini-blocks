import SpriteKit

protocol TouchInteractable {
    func onTap(at point: CGPoint) -> Bool
}

extension TouchInteractable {
    func onTap(at point: CGPoint) -> Bool { false }
}
