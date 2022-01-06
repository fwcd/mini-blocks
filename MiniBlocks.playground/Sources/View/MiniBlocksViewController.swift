import Foundation
import SceneKit

/// The application's primary view controller.
public final class MiniBlocksViewController: NSViewController {
    private let sceneFrame: CGRect
    private let debugMode: Bool
    
    public init(sceneFrame: CGRect, debugMode: Bool = false) {
        self.sceneFrame = sceneFrame
        self.debugMode = debugMode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        nil
    }
    
    public override func loadView() {
        // Create scene
        let scene = SCNScene(named: "MiniBlocksScene.scn")!
        
        // Set up and position camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        scene.rootNode.addChildNode(cameraNode)
        
        // Set up light
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)

        // Set up ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = NSColor.darkGray
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Add some blocks
        let radius = 50
        for x in -radius..<radius {
            for z in -radius..<radius {
                let blockMaterial = SCNMaterial()
                blockMaterial.diffuse.contents = NSImage(named: "TextureGrass.png")
                let block = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                block.materials = [blockMaterial]
                let blockNode = SCNNode(geometry: block)
                blockNode.position = SCNVector3(x: CGFloat(x), y: -2, z: CGFloat(z))
                scene.rootNode.addChildNode(blockNode)
            }
        }
        
        // Set up SCNView
        let sceneView = SCNView(frame: sceneFrame)
        sceneView.scene = scene
        sceneView.allowsCameraControl = debugMode
        sceneView.showsStatistics = debugMode
        sceneView.backgroundColor = NSColor.black
        
        view = sceneView
    }
}

