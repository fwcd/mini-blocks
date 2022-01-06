import Foundation
import SceneKit

/// The game's primary view controller.
public final class MiniBlocksViewController: NSViewController {
    private let sceneFrame: CGRect?
    private let debugModeEnabled: Bool
    private let debugInteractionMode: SCNInteractionMode
    private var tickTimer: Timer!
    
    private var playerNode: SCNNode!
    private var playerPhysics: SCNPhysicsBody?
    private var playerForce: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    public init(
        sceneFrame: CGRect? = nil,
        debugModeEnabled: Bool = false,
        debugInteractionMode: SCNInteractionMode = .fly
    ) {
        self.sceneFrame = sceneFrame
        self.debugModeEnabled = debugModeEnabled
        self.debugInteractionMode = debugInteractionMode
        
        super.init(nibName: nil, bundle: nil)
        
        // Set up tick timer
        tickTimer = Timer.scheduledTimer(timeInterval: 1 / 20, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    public required init?(coder: NSCoder) {
        nil
    }
    
    deinit {
        tickTimer?.invalidate()
    }
    
    /// Creates the initial scene.
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
        self.playerNode = playerNode
        
        // Add player physics if not in debug mode
        if !debugModeEnabled {
            let playerPhysics = SCNPhysicsBody(type: .dynamic, shape: playerShape)
            playerPhysics.isAffectedByGravity = true
            playerPhysics.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
            playerPhysics.friction = 0
            playerNode.physicsBody = playerPhysics
            self.playerPhysics = playerPhysics
        }
        
        // Set up another physics-affected node for testing
        let otherBox = SCNBox(width: 1, height: 3, length: 1, chamferRadius: 0)
        let otherPhysics = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: otherBox))
        otherPhysics.isAffectedByGravity = true
        otherPhysics.angularVelocityFactor = SCNVector3(x: 0, y: 1, z: 0) // constrain physics-based rotation to only rotation around y-axis (vertical)
        otherPhysics.mass = 20
        let otherNode = SCNNode(geometry: otherBox)
        otherNode.position = SCNVector3(x: 0, y: 20, z: 8)
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
    
    /// Performs a single game tick. Ticks occur 20 times a second and updates the game (e.g. by moving the player forward).
    @objc
    private func tick() {
        // TODO: Do something on ticks
    }
    
    private func updatePlayerVelocity(dx: CGFloat? = nil, dy: CGFloat? = nil, dz: CGFloat? = nil) {
        if let playerPhysics = playerPhysics {
            let velocity = playerPhysics.velocity
            print(playerPhysics.velocity)
            playerPhysics.velocity = SCNVector3(
                x: dx ?? velocity.x,
                y: dy ?? velocity.y,
                z: dz ?? velocity.z
            )
        }
    }
    
    public override func keyDown(with event: NSEvent) {
        guard !debugModeEnabled && !event.isARepeat else { return }
        
        let speed: CGFloat = 5
        // TODO: Use actual direction?
        switch event.keyCode {
        case KeyCodes.w:
            updatePlayerVelocity(dz: -speed)
        case KeyCodes.s:
            updatePlayerVelocity(dz: speed)
        case KeyCodes.a:
            updatePlayerVelocity(dx: -speed)
        case KeyCodes.d:
            updatePlayerVelocity(dx: speed)
        case KeyCodes.space:
            playerPhysics?.applyForce(SCNVector3(x: 0, y: 500, z: 0), asImpulse: false)
        default:
            break
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        updatePlayerVelocity(dx: 0, dz: 0)
    }
}

