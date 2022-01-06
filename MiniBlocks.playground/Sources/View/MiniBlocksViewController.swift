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
        
        // Add a funky torus
        let torus = SCNTorus(ringRadius: 1, pipeRadius: 0.35)
        torus.firstMaterial?.diffuse.contents  = NSColor.red
        torus.firstMaterial?.specular.contents = NSColor.white
        let torusNode = SCNNode(geometry: torus)
        torusNode.rotation = SCNVector4(x: 1.0, y: 1.0, z: 0.0, w: 0.0) // set up rotation axis for nicer keypath below
        scene.rootNode.addChildNode(torusNode)
        
        // You spin me right round, baby, right round!
        let spin = CABasicAnimation(keyPath: "rotation.w") // only animate the angle
        spin.toValue = 2.0*Double.pi
        spin.duration = 3
        spin.repeatCount = HUGE // for infinity
        torusNode.addAnimation(spin, forKey: "spin around")
        
        // Set up SCNView
        let sceneView = SCNView(frame: sceneFrame)
        sceneView.scene = scene
        sceneView.allowsCameraControl = debugMode
        sceneView.showsStatistics = debugMode
        sceneView.backgroundColor = NSColor.black
        
        view = sceneView
    }
}

