import Foundation
import SceneKit
import GameplayKit

/// The game's primary view controller.
public final class MiniBlocksViewController: NSViewController, SCNSceneRendererDelegate {
    private let debugModeEnabled: Bool
    private let debugInteractionMode: SCNInteractionMode
    private var previousUpdateTime: TimeInterval = 0
    
    // MARK: View properties
    
    private let sceneFrame: CGRect?
    
    // MARK: Model properties
    
    @Box private var world: World = World.wavyGrassHills()
    
    // MARK: SceneKit properties
    
    private var scene: SCNScene!
    
    // MARK: GameplayKit properties
    
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
        add(entity: makePlayerEntity(world: _world))
        
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
        add(entity: makeWorldEntity(world: _world))
        
        // Set up SCNView
        let sceneView = sceneFrame.map { SCNView(frame: $0) } ?? SCNView()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.allowsCameraControl = debugModeEnabled
        sceneView.defaultCameraController.interactionMode = debugInteractionMode
        sceneView.showsStatistics = true
        sceneView.backgroundColor = NSColor.black
        
        // Keep scene active, otherwise it will stop sending renderer(_:updateAtTime:)s when nothing changes. See also https://stackoverflow.com/questions/39336509/how-do-you-set-up-a-game-loop-for-scenekit
        sceneView.isPlaying = true
        
        if let sceneFrame = sceneFrame {
            sceneView.addTrackingArea(NSTrackingArea(
                rect: sceneFrame,
                options: [.activeAlways, .mouseMoved, .inVisibleRect],
                owner: self,
                userInfo: nil
            ))
        }
        
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
    
    private func controlPlayer(with action: (PlayerControlComponent) -> Void) {
        for case let component as PlayerControlComponent in playerControlComponentSystem.components {
            action(component)
        }
    }
    
    public override func keyDown(with event: NSEvent) {
        guard !debugModeEnabled && !event.isARepeat else { return }
        
        if let motion = motionInput(for: event.keyCode) {
            // Pressed key could be mapped motion input, add it to the corresponding components
            controlPlayer { component in
                component.motionInput.insert(motion)
            }
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        if let motion = motionInput(for: event.keyCode) {
            // Pressed key could be mapped motion input, remove it from the corresponding components
            controlPlayer { component in
                component.motionInput.remove(motion)
            }
        }
    }
    
    public override func mouseMoved(with event: NSEvent) {
        // Rotate view
        controlPlayer { component in
            component.rotateYaw(delta: -event.deltaX / 50)
            component.rotatePitch(delta: -event.deltaY / 50)
        }
        
        // Lock mouse to center of window
        warpMouseCursorToCenter()
    }
    
    private func warpMouseCursorToCenter() {
        if let window = view.window, let screen = window.screen {
            let frameInWindow = view.convert(view.bounds, to: nil)
            let frameOnScreen = window.convertToScreen(frameInWindow)
            let midX = frameOnScreen.midX
            // AppKit and Quartz use different coordinate systems so we need to convert here
            let midY = screen.frame.size.height - frameOnScreen.midY
            CGWarpMouseCursorPosition(CGPoint(x: midX, y: midY))
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
        case KeyCodes.space: return .jump
        default: return nil
        }
    }
}

