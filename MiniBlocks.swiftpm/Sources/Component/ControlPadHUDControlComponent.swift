import SpriteKit
import GameplayKit

/// Handles control pad touches.
class ControlPadHUDControlComponent: GKComponent, TouchInteractable {
    private var node: SKNode? {
        entity?.component(ofType: SpriteNodeComponent.self)?.node
    }
    
    private var stickNode: SKNode? {
        node?.children.filter({ ($0.userData?["isControlPadStick"] as? Bool) ?? false }).first
    }
    
    private var playerAssociationComponent: PlayerAssociationComponent? {
        entity?.component(ofType: PlayerAssociationComponent.self)
    }
    
    private var playerControlComponent: PlayerControlComponent? {
        playerAssociationComponent?.playerEntity.component(ofType: PlayerControlComponent.self)
    }
    
    func onTap(at point: CGPoint) -> Bool {
        guard let node = node,
              let parent = node.parent,
              let scene = node.scene,
              node.contains(scene.convert(point, to: parent)) else { return false }
        playerControlComponent?.jump()
        return true
    }
    
    func onDragStart(at point: CGPoint) -> Bool {
        guard let node = node,
              let parent = node.parent,
              let scene = node.scene else { return false }
        return node.contains(scene.convert(point, to: parent))
    }
    
    func onDragMove(by delta: CGVector, start: CGPoint, current: CGPoint) {
        guard let stickNode = stickNode else { return }
        let offset = (current - start)
        let baseVelocity = Vec3(x: offset.x, y: 0, z: -offset.y).normalized
        stickNode.position = offset
        playerControlComponent?.requestedBaseVelocity = baseVelocity
    }
    
    func onDragEnd() {
        stickNode?.position = CGPoint(x: 0, y: 0)
        playerControlComponent?.requestedBaseVelocity = .zero
    }
}
