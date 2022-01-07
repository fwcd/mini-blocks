import Foundation
import SceneKit
import SpriteKit
import GameplayKit

/// The game's primary view controller.
public final class MiniBlocksViewController: NSViewController, SCNSceneRendererDelegate {
    private let debugModeEnabled: Bool
    private let debugInteractionMode: SCNInteractionMode
    private var previousUpdateTime: TimeInterval = 0
    
    // MARK: View properties
    
    private let sceneFrame: CGRect?
    private var receivedFirstMouseEvent: Bool = false
    private var mouseCaptured: Bool = false {
        willSet {
            if newValue != mouseCaptured {
                if newValue {
                    receivedFirstMouseEvent = false
                    warpMouseCursorToCenter()
                    CGDisplayHideCursor(kCGNullDirectDisplay)
                } else {
                    CGDisplayShowCursor(kCGNullDirectDisplay)
                }
            }
        }
    }
    
    // MARK: Model properties
    
    @Box private var world: World = World.wavyGrassHills()
    
    // MARK: SpriteKit/SceneKit properties
    
    private var overlayScene: SKScene!
    private var scene: SCNScene!
    
    // MARK: GameplayKit properties
    
    private let playerControlComponentSystem = GKComponentSystem(componentClass: PlayerControlComponent.self)
    private let gravityComponentSystem = GKComponentSystem(componentClass: GravityComponent.self)
    private let worldInteractionComponentSystem = GKComponentSystem(componentClass: WorldInteractionComponent.self)
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
        // Create main scene
        scene = SCNScene(named: "MiniBlocksScene.scn")!
        
        // Create overlay scene
        overlayScene = sceneFrame.map { SKScene(size: $0.size) } ?? SKScene()
        overlayScene.isUserInteractionEnabled = false
        
        // Add player
        let playerEntity = makePlayerEntity(world: _world)
        let playerNode = playerEntity.component(ofType: SceneNodeComponent.self)!.node
        add(entity: playerEntity)
        
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
        let worldEntity = makeWorldEntity(world: _world, playerNode: playerNode)
        add(entity: worldEntity)
        
        // Add overlay HUD
        add(entity: makeCrosshairHUDEntity(at: CGPoint(x: overlayScene.frame.midX, y: overlayScene.frame.midY)))
        
        // Set up SCNView
        let sceneView = sceneFrame.map { SCNView(frame: $0) } ?? SCNView()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.allowsCameraControl = debugModeEnabled
        sceneView.defaultCameraController.interactionMode = debugInteractionMode
        sceneView.showsStatistics = true
        sceneView.backgroundColor = NSColor.black
        sceneView.overlaySKScene = overlayScene
        
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
        if let node = entity.component(ofType: SceneNodeComponent.self)?.node {
            scene.rootNode.addChildNode(node)
        }
        
        // Add attached sprite node to the overlay, if present
        if let node = entity.component(ofType: SpriteNodeComponent.self)?.node {
            overlayScene.addChild(node)
        }
        
        // Add components to their corresponding systems
        playerControlComponentSystem.addComponent(foundIn: entity)
        gravityComponentSystem.addComponent(foundIn: entity)
        worldInteractionComponentSystem.addComponent(foundIn: entity)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - previousUpdateTime
        
        // Perform updates to the components through their corresponding systems
        playerControlComponentSystem.update(deltaTime: deltaTime)
        gravityComponentSystem.update(deltaTime: deltaTime)
        worldInteractionComponentSystem.update(deltaTime: deltaTime)
        
        previousUpdateTime = time
    }
    
    private func controlPlayer(with action: (PlayerControlComponent) -> Void) {
        for case let component as PlayerControlComponent in playerControlComponentSystem.components {
            action(component)
        }
    }
    
    public override func keyDown(with event: NSEvent) {
        guard !debugModeEnabled && !event.isARepeat else { return }
        
        if event.keyCode == KeyCodes.escape {
            // Uncapture cursor when user presses escape
            mouseCaptured = false
        } else if let motion = motionInput(for: event.keyCode) {
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
    
    public override func flagsChanged(with event: NSEvent) {
        // Sprint on shift
        controlPlayer { component in
            if event.modifierFlags.contains(.shift) {
                component.motionInput.insert(.sprint)
            } else {
                component.motionInput.remove(.sprint)
            }
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        mouseCaptured = true
    }
    
    public override func mouseMoved(with event: NSEvent) {
        if mouseCaptured {
            // Skip first event since this one may have large deltas
            guard receivedFirstMouseEvent else {
                receivedFirstMouseEvent = true
                return
            }
            
            // Rotate view
            controlPlayer { component in
                component.rotateYaw(by: -event.deltaX / 50)
                component.rotatePitch(by: -event.deltaY / 50)
            }
            
            // Keep mouse at center of window
            warpMouseCursorToCenter()
        }
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
        case KeyCodes.space: return .jump
        default: return nil
        }
    }
}

