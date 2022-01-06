import Foundation
import SceneKit
import GameplayKit

/// The game's primary view controller.
public final class MiniBlocksViewController: NSViewController, SCNSceneRendererDelegate {
    private let sceneFrame: CGRect?
    private let debugModeEnabled: Bool
    private let debugInteractionMode: SCNInteractionMode
    private var previousUpdateTime: TimeInterval = 0
    
    private var scene: SCNScene!
    private var playerNode: SCNNode!
    private var playerPhysics: SCNPhysicsBody?
    private var playerForce: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    private let sceneNodeComponentSystem = GKComponentSystem(componentClass: SceneNodeComponent.self)
    private let gridPositionedComponentSystem = GKComponentSystem(componentClass: GridPositionedComponent.self)
    private var entities: [GKEntity] = []
    
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
    
    /// Creates the initial scene.
    public override func loadView() {
        // Create scene
        scene = SCNScene(named: "MiniBlocksScene.scn")!
        
        // Add player
        add(entity: makePlayerEntity(physicsEnabled: !debugModeEnabled))
        
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
        for pos in makeDemoBlockPositions() {
            add(entity: makeBlockEntity(pos: pos))
        }
        
        // Set up SCNView
        let sceneView = sceneFrame.map { SCNView(frame: $0) } ?? SCNView()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.allowsCameraControl = debugModeEnabled
        sceneView.defaultCameraController.interactionMode = debugInteractionMode
        sceneView.showsStatistics = debugModeEnabled
        sceneView.backgroundColor = NSColor.black
        
        view = sceneView
    }
    
    private func add(entity: GKEntity) {
        entities.append(entity)
        
        // Add attached node to the scene, if entity has the corresponding component
        if let component = entity.component(ofType: SceneNodeComponent.self) {
            scene.rootNode.addChildNode(component.node)
        }
        
        // Add components to their corresponding systems
        sceneNodeComponentSystem.addComponent(foundIn: entity)
        gridPositionedComponentSystem.addComponent(foundIn: entity)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - previousUpdateTime
        
        // Perform updates to the components through their corresponding systems
        sceneNodeComponentSystem.update(deltaTime: deltaTime)
        gridPositionedComponentSystem.update(deltaTime: deltaTime)
        
        previousUpdateTime = time
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
        // TODO: Use actual direction
        switch event.keyCode {
        case KeyCodes.w:
            updatePlayerVelocity(dz: -speed)
        case KeyCodes.s:
            updatePlayerVelocity(dz: speed)
        case KeyCodes.a:
            updatePlayerVelocity(dx: -speed)
        case KeyCodes.d:
            updatePlayerVelocity(dx: speed)
        // TODO: Mouse camera control
        case KeyCodes.arrowLeft:
            playerPhysics?.applyTorque(SCNVector4(x: 0, y: 1, z: 0, w: 2), asImpulse: false)
        case KeyCodes.arrowRight:
            playerPhysics?.applyTorque(SCNVector4(x: 0, y: 1, z: 0, w: -2), asImpulse: false)
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

