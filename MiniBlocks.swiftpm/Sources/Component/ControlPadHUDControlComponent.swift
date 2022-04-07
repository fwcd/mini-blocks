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
        guard let stickNode = stickNode,
              let parent = stickNode.parent,
              let scene = stickNode.scene else { return false }
        let dragged = stickNode.contains(scene.convert(point, to: parent))
        // DEBUG
        if dragged {
            print("Started dragging control pad")
        }
        return dragged
    }
    
    func onDragMove(by delta: CGVector) {
        // TODO
    }
}
