import Foundation
import SceneKit

/// The application's primary view controller.
public final class MiniBlocksViewController: NSViewController {
    private let sceneFrame: CGRect?
    private let debugModeEnabled: Bool
    private let debugInteractionMode: SCNInteractionMode
    
    public init(
        sceneFrame: CGRect? = nil,
        debugModeEnabled: Bool = false,
        debugInteractionMode: SCNInteractionMode = .fly
    ) {
        self.sceneFrame = sceneFrame
        self.debugModeEnabled = debugModeEnabled
        self.debugInteractionMode = debugInteractionMode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        nil
    }
    
    public override func loadView() {
        // Create scene
        let scene = SCNScene(named: "MiniBlocksScene.scn")!
        
        // Set up the player node with a camera
        let playerHeight: CGFloat = 1.5
        let playerShape = SCNPhysicsShape(
            shapes: [SCNPhysicsShape(geometry: SCNBox(width: 1, height: playerHeight, length: 1, chamferRadius: 0))],
            transforms: [NSValue(scnMatrix4: SCNMatrix4MakeTranslation(0, -playerHeight, 0))]
        )
        let playerCamera = SCNCamera()
        let playerNode = SCNNode()
        playerNode.camera = playerCamera
        playerNode.position = SCNVector3(x: 0, y: 10, z: 15)
        scene.rootNode.addChildNode(playerNode)
        
        // Add player physics if not in debug mode
        if !debugModeEnabled {
            let playerPhysics = SCNPhysicsBody(type: .dynamic, shape: playerShape)
            playerPhysics.isAffectedByGravity = true
            playerPhysics.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
            playerNode.physicsBody = playerPhysics
        }
        
        // Set up another physics-affected node for testing
        let otherBox = SCNBox(width: 1, height: 3, length: 1, chamferRadius: 0)
        let otherPhysics = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: otherBox))
        otherPhysics.isAffectedByGravity = true
        otherPhysics.angularVelocityFactor = SCNVector3(x: 0, y: 1, z: 0) // constrain physics-based rotation to only rotation around y-axis (vertical)
        let otherNode = SCNNode(geometry: otherBox)
        otherNode.position = SCNVector3(x: 2, y: 20, z: 8)
        otherNode.physicsBody = otherPhysics
        scene.rootNode.addChildNode(otherNode)
        
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
                let blockPhysics = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: block))
                let blockNode = SCNNode(geometry: block)
                blockNode.position = SCNVector3(x: CGFloat(x), y: (-5 * sin(CGFloat(x) / 10) * cos(CGFloat(z) / 10)).rounded(), z: CGFloat(z))
                blockNode.physicsBody = blockPhysics
                scene.rootNode.addChildNode(blockNode)
            }
        }
        
        // Set up SCNView
        let sceneView = sceneFrame.map { SCNView(frame: $0) } ?? SCNView()
        sceneView.scene = scene
        sceneView.allowsCameraControl = debugModeEnabled
        sceneView.defaultCameraController.interactionMode = debugInteractionMode
        sceneView.showsStatistics = debugModeEnabled
        sceneView.backgroundColor = NSColor.black
        
        view = sceneView
    }
}

