import Foundation
import SceneKit
import GameplayKit

/// The game's primary view controller.
public final class MiniBlocksViewController: NSViewController, SCNSceneRendererDelegate {
    private let sceneFrame: CGRect?
    private let debugModeEnabled: Bool
    private let debugInteractionMode: SCNInteractionMode
    private var previousUpdateTime: TimeInterval = 0
    
    // SceneKit properties
    private var scene: SCNScene!
    private var playerNode: SCNNode!
    private var playerPhysics: SCNPhysicsBody?
    private var playerForce: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    // GameplayKit properties
    private let gridPositionedComponentSystem = GKComponentSystem(componentClass: GridPositionedComponent.self)
    private let playerControlComponentSystem = GKComponentSystem(componentClass: PlayerControlComponent.self)
    private let gravityComponentSystem = GKComponentSystem(componentClass: GravityComponent.self)
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
        
        // Add the world
        add(entity: makeWorldEntity(world: World.wavyGrassHills()))
        
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
        gridPositionedComponentSystem.addComponent(foundIn: entity)
        playerControlComponentSystem.addComponent(foundIn: entity)
        gravityComponentSystem.addComponent(foundIn: entity)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - previousUpdateTime
        
        // Perform updates to the components through their corresponding systems
        gridPositionedComponentSystem.update(deltaTime: deltaTime)
        playerControlComponentSystem.update(deltaTime: deltaTime)
        gravityComponentSystem.update(deltaTime: deltaTime)
        
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
        
        // Map the pressed key to motion input and add it to the corresponding components
        if let motion = motionInput(for: event.keyCode) {
            for case let component as PlayerControlComponent in playerControlComponentSystem.components {
                component.motionInput.insert(motion)
            }
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        // Map the pressed key to motion input and remove it from the corresponding components
        if let motion = motionInput(for: event.keyCode) {
            for case let component as PlayerControlComponent in playerControlComponentSystem.components {
                component.motionInput.remove(motion)
            }
        }
    }
    
    private func motionInput(for keyCode: UInt16) -> PlayerControlComponent.MotionInput? {
        switch keyCode {
        case KeyCodes.w: return .forward
        case KeyCodes.s: return .back
        case KeyCodes.a: return .left
        case KeyCodes.d: return .right
        case KeyCodes.arrowUp: return .rotateUp
        case KeyCodes.arrowDown: return .rotateDown
        case KeyCodes.arrowLeft: return .rotateLeft
        case KeyCodes.arrowRight: return .rotateRight
        default: return nil
        }
    }
}

