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
    
    func shouldReceiveDrag(at point: CGPoint) -> Bool {
        guard let node = node,
              let parent = node.parent,
              let scene = node.scene else { return false }
        return node.contains(scene.convert(point, to: parent))
    }
    
    func onDragMove(by delta: CGVector, start: CGPoint, current: CGPoint) {
        guard let stickNode = stickNode else { return }
        let offset = (current - start)
        let rawBaseVelocity = Vec3(x: offset.x, y: 0, z: -offset.y)
        let shouldSprint = rawBaseVelocity.length > stickNode.frame.width * 2
        let baseVelocity = rawBaseVelocity.normalized
        
        DispatchQueue.main.async {
            stickNode.position = offset
        }
        
        if shouldSprint {
            playerControlComponent?.add(motionInput: .sprint)
        } else {
            playerControlComponent?.remove(motionInput: .sprint)
        }
        playerControlComponent?.requestedBaseVelocity = baseVelocity
    }
    
    func onDragEnd() {
        if let stickNode = stickNode {
            DispatchQueue.main.async {
                stickNode.position = CGPoint(x: 0, y: 0)
            }
        }
        playerControlComponent?.remove(motionInput: .sprint)
        playerControlComponent?.requestedBaseVelocity = .zero
    }
}
