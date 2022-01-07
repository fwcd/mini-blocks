import SceneKit

/// A SceneKit view that fixes key handling when an overlayed SpriteKit scene is present. See https://developer.apple.com/library/archive/samplecode/Badger/Listings/Common_View_swift.html
class MiniBlocksSceneView: SCNView {
    weak var keyEventsDelegate: NSResponder?
    
    override func keyDown(with event: NSEvent) {
        if let keyEventsDelegate = keyEventsDelegate {
            keyEventsDelegate.keyDown(with: event)
        } else {
            super.keyDown(with: event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let keyEventsDelegate = keyEventsDelegate {
            keyEventsDelegate.keyUp(with: event)
        } else {
            super.keyUp(with: event)
        }
    }
}
