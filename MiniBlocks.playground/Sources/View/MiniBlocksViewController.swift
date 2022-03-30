import Foundation
import CoreGraphics
import SceneKit
import SpriteKit
import GameplayKit
import OSLog

private let log = Logger(subsystem: "MiniBlocks", category: "MiniBlocksViewController")

/// The game's primary view controller.
public final class MiniBlocksViewController: ViewController, SCNSceneRendererDelegate, GestureRecognizerDelegate {
    private let playerName: String
    private let gameMode: GameMode
    private let worldGenerator: WorldGeneratorType
    private let renderDistance: Int
    private let ambientOcclusionEnabled: Bool
    private let debugStatsShown: Bool
    private var previousUpdateTime: TimeInterval = 0
    
    // MARK: View properties
    
    private let sceneFrame: CGRect?
    private var inputSensivity: SceneFloat = 1
    
    #if canImport(AppKit)
    private var receivedFirstMouseEvent: Bool = false
    private var mouseCaptured: Bool = false {
        willSet {
            if newValue != mouseCaptured {
                // Update actual capturing
                if newValue {
                    receivedFirstMouseEvent = false
                    warpMouseCursorToCenter()
                    CGDisplayHideCursor(kCGNullDirectDisplay)
                } else {
                    CGDisplayShowCursor(kCGNullDirectDisplay)
                }
                
                // Notify component system
                for case let component as MouseCaptureVisibilityComponent in mouseCaptureVisibilityComponentSystem.components {
                    component.update(mouseCaptured: newValue)
                }
            }
        }
    }
    #endif
    
    #if canImport(UIKit)
    private var movementControlPadDragStart: CGPoint?
    private var movementControlPadRecognizer: UIGestureRecognizer!
    private var cameraControlPadRecognizer: UIGestureRecognizer!
    public override var prefersHomeIndicatorAutoHidden: Bool { true }
    #endif
    
    // MARK: SpriteKit/SceneKit properties
    
    private var overlayScene: SKScene!
    private var scene: SCNScene!
    
    // MARK: GameplayKit properties
    
    private let playerControlComponentSystem = GKComponentSystem(componentClass: PlayerControlComponent.self)
    private let playerPositioningComponentSystem = GKComponentSystem(componentClass: PlayerPositioningComponent.self)
    private let lookAtBlockComponentSystem = GKComponentSystem(componentClass: LookAtBlockComponent.self)
    private let playerGravityComponentSystem = GKComponentSystem(componentClass: PlayerGravityComponent.self)
    private let worldLoadComponentSystem = GKComponentSystem(componentClass: WorldLoadComponent.self)
    private let worldRetainComponentSystem = GKComponentSystem(componentClass: WorldRetainComponent.self)
    private let hotbarHUDLoadComponentSystem = GKComponentSystem(componentClass: HotbarHUDLoadComponent.self)
    private let debugHUDLoadComponentSystem = GKComponentSystem(componentClass: DebugHUDLoadComponent.self)
    private let achievementHUDLoadComponentSystem = GKComponentSystem(componentClass: AchievementHUDLoadComponent.self)
    private let mouseCaptureVisibilityComponentSystem = GKComponentSystem(componentClass: MouseCaptureVisibilityComponent.self)
    private var entities: [GKEntity] = []
    
    public init(
        sceneFrame: CGRect? = nil,
        playerName: String = "Player",
        worldGenerator: WorldGeneratorType = .nature(seed: "default"),
        gameMode: GameMode = .survival,
        renderDistance: Int = 8,
        ambientOcclusionEnabled: Bool = false,
        debugStatsShown: Bool = false
    ) {
        self.sceneFrame = sceneFrame
        self.playerName = playerName
        self.worldGenerator = worldGenerator
        self.gameMode = gameMode
        self.renderDistance = renderDistance
        self.ambientOcclusionEnabled = ambientOcclusionEnabled
        self.debugStatsShown = debugStatsShown
        
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
        overlayScene.scaleMode = .aspectFill
        overlayScene.isUserInteractionEnabled = false
        
        // Add light
        add(entity: makeSunEntity())
        add(entity: makeAmbientLightEntity())
        
        // Add the world
        let worldEntity = makeWorldEntity(world: World(generator: worldGenerator))
        add(entity: worldEntity)
        
        // Add player
        let playerSpawnPos = Vec3(y: 10)
        let playerEntity = makePlayerEntity(
            name: playerName,
            position: playerSpawnPos,
            gameMode: gameMode,
            worldEntity: worldEntity,
            retainRadius: renderDistance,
            ambientOcclusionEnabled: ambientOcclusionEnabled
        )
        add(entity: playerEntity)
        
        // Add (first-person player) hand
        add(entity: makeHandEntity())
        
        // Add overlay HUD
        add(entity: makeCrosshairHUDEntity(in: overlayScene.frame))
        add(entity: makeHotbarHUDEntity(in: overlayScene.frame, playerEntity: playerEntity))
        add(entity: makeDebugHUDEntity(in: overlayScene.frame, playerEntity: playerEntity))
        add(entity: makeAchievementHUDEntity(in: overlayScene.frame, playerEntity: playerEntity))
        #if canImport(AppKit)
        add(entity: makePauseHUDEntity(in: overlayScene.frame))
        #endif
        
        // Set up SCNView
        let sceneView = sceneFrame.map { MiniBlocksSceneView(frame: $0) } ?? MiniBlocksSceneView()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.allowsCameraControl = false
        sceneView.showsStatistics = debugStatsShown
        sceneView.backgroundColor = Color.black
        sceneView.overlaySKScene = overlayScene
        sceneView.antialiasingMode = .none
        sceneView.isJitteringEnabled = false
        
        // Keep scene active, otherwise it will stop sending renderer(_:updateAtTime:)s when nothing changes. See also https://stackoverflow.com/questions/39336509/how-do-you-set-up-a-game-loop-for-scenekit
        sceneView.isPlaying = true
        
        // Set up mouse/keyboard handling when using AppKit (on macOS)
        #if canImport(AppKit)
        sceneView.keyEventsDelegate = self
        
        if let sceneFrame = sceneFrame {
            sceneView.addTrackingArea(NSTrackingArea(
                rect: sceneFrame,
                options: [.activeAlways, .mouseMoved, .inVisibleRect],
                owner: self,
                userInfo: nil
            ))
        }
        #endif
        
        // Set up touch gesture handling when using UIKit (on iOS)
        #if canImport(UIKit)
        movementControlPadRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMovementControl(_:)))
        movementControlPadRecognizer.delegate = self
        sceneView.addGestureRecognizer(movementControlPadRecognizer)
        
        cameraControlPadRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCameraControl(_:)))
        cameraControlPadRecognizer.delegate = self
        sceneView.addGestureRecognizer(cameraControlPadRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapRecognizer.delegate = self
        sceneView.addGestureRecognizer(tapRecognizer)
        
        let pressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        pressRecognizer.minimumPressDuration = 0.5
        pressRecognizer.delegate = self
        sceneView.addGestureRecognizer(pressRecognizer)
        #endif
        
        view = sceneView
        log.info("Loaded view")
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
        
        #if canImport(AppKit)
        // Provide initial update to mouse capture visibility component
        if let component = entity.component(ofType: MouseCaptureVisibilityComponent.self) {
            component.update(mouseCaptured: mouseCaptured)
        }
        #endif
        
        // Add components to their corresponding systems
        playerControlComponentSystem.addComponent(foundIn: entity)
        playerPositioningComponentSystem.addComponent(foundIn: entity)
        playerGravityComponentSystem.addComponent(foundIn: entity)
        lookAtBlockComponentSystem.addComponent(foundIn: entity)
        worldLoadComponentSystem.addComponent(foundIn: entity)
        worldRetainComponentSystem.addComponent(foundIn: entity)
        hotbarHUDLoadComponentSystem.addComponent(foundIn: entity)
        debugHUDLoadComponentSystem.addComponent(foundIn: entity)
        achievementHUDLoadComponentSystem.addComponent(foundIn: entity)
        mouseCaptureVisibilityComponentSystem.addComponent(foundIn: entity)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - previousUpdateTime
        
        // Perform updates to the components through their corresponding systems
        playerControlComponentSystem.update(deltaTime: deltaTime)
        playerPositioningComponentSystem.update(deltaTime: deltaTime)
        playerGravityComponentSystem.update(deltaTime: deltaTime)
        lookAtBlockComponentSystem.update(deltaTime: deltaTime)
        worldLoadComponentSystem.update(deltaTime: deltaTime)
        worldRetainComponentSystem.update(deltaTime: deltaTime)
        hotbarHUDLoadComponentSystem.update(deltaTime: deltaTime)
        debugHUDLoadComponentSystem.update(deltaTime: deltaTime)
        achievementHUDLoadComponentSystem.update(deltaTime: deltaTime)
        mouseCaptureVisibilityComponentSystem.update(deltaTime: deltaTime)
        
        previousUpdateTime = time
    }
    
    private func controlPlayer(with action: (PlayerControlComponent) -> Void) {
        for case let component as PlayerControlComponent in playerControlComponentSystem.components {
            action(component)
        }
    }
    
    // MARK: Mouse/keyboard controls
    
    #if canImport(AppKit)
    
    public override func keyDown(with event: NSEvent) {
        guard !event.isARepeat else { return }
        let keyCode = KeyCode(rawValue: event.keyCode)
        
        if keyCode == .escape {
            // Uncapture cursor when user presses escape
            mouseCaptured = false
        } else if keyCode == .f3 {
            // Toggle debug information shown as an overlay (e.g. the current position)
            controlPlayer { component in
                component.toggleDebugHUD()
            }
        } else if let n = keyCode.numericValue {
            if (1...InventoryConstants.hotbarSlotCount).contains(n) {
                // Select hotbar slot
                controlPlayer { component in
                    component.select(hotbarSlot: n - 1)
                }
            }
        } else {
            let motion = motionInput(for: keyCode)
            // Pressed key could be mapped motion input, add it to the corresponding components
            controlPlayer { component in
                component.add(motionInput: motion)
            }
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        let motion = motionInput(for: KeyCode(rawValue: event.keyCode))
        // Pressed key could be mapped motion input, remove it from the corresponding components
        controlPlayer { component in
            component.remove(motionInput: motion)
        }
    }
    
    public override func flagsChanged(with event: NSEvent) {
        let flags = event.modifierFlags
        
        // Sprint on shift
        controlPlayer { component in
            if flags.contains(.shift) {
                component.add(motionInput: .sprint)
            } else {
                component.remove(motionInput: .sprint)
            }
            
            if flags.contains(.control) {
                component.add(motionInput: .sneak)
            } else {
                component.remove(motionInput: .sneak)
            }
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        if mouseCaptured {
            // Break blocks on left-click if captured
            controlPlayer { component in
                component.add(motionInput: .breakBlock)
            }
        } else {
            // Capture mouse otherwise
            mouseCaptured = true
        }
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        if mouseCaptured {
            // Use blocks on right-click if captured
            controlPlayer { component in
                component.add(motionInput: .useBlock)
            }
        }
    }
    
    public override func mouseUp(with event: NSEvent) {
        if mouseCaptured {
            // Stop breaking blocks
            controlPlayer { component in
                component.remove(motionInput: .breakBlock)
            }
        }
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        if mouseCaptured {
            // Stop using blocks
            controlPlayer { component in
                component.remove(motionInput: .useBlock)
            }
        }
    }
    
    public override func mouseMoved(with event: NSEvent) {
        if mouseCaptured {
            // Skip first event since this one may have large deltas
            guard receivedFirstMouseEvent else {
                receivedFirstMouseEvent = true
                return
            }
            
            // Rotate camera
            controlPlayer { component in
                component.rotateYaw(by: -(event.deltaX * inputSensivity) / 50)
                component.rotatePitch(by: -(event.deltaY * inputSensivity) / 50)
            }
            
            // Keep mouse at center of window
            warpMouseCursorToCenter()
        }
    }
    
    public override func scrollWheel(with event: NSEvent) {
        if mouseCaptured {
            let slotDelta = Int(event.scrollingDeltaX + event.scrollingDeltaY)
            
            // Move the selected slot
            controlPlayer { component in
                component.moveHotbarSelection(by: slotDelta)
            }
        }
    }
    
    public override func mouseDragged(with event: NSEvent) {
        mouseMoved(with: event)
    }
    
    public override func rightMouseDragged(with event: NSEvent) {
        mouseMoved(with: event)
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
    
    private func motionInput(for keyCode: KeyCode) -> PlayerControlComponent.MotionInput {
        switch keyCode {
        case .w: return .forward
        case .s: return .back
        case .a: return .left
        case .d: return .right
        case .space: return .jump
        default: return []
        }
    }
    
    #endif
    
    // MARK: Touch controls
    
    #if canImport(UIKit)
    
    public func gestureRecognizer(_ recognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        // Support multi-touch
        true
    }
    
    public func gestureRecognizer(_ recognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard [movementControlPadRecognizer, cameraControlPadRecognizer].contains(recognizer) else { return true }
        
        let bounds = view.bounds
        let location = touch.location(in: view)
        
        // Left side of screen controls movement, right side the camera
        if location.x < bounds.midX {
            return recognizer == movementControlPadRecognizer
        } else {
            return recognizer == cameraControlPadRecognizer
        }
    }
    
    @objc
    private func handleMovementControl(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view)
        let start = movementControlPadDragStart ?? location
        let deltaPoint = location - start
        let delta = Vec3(x: deltaPoint.x, y: 0, z: deltaPoint.y).normalized
        
        // Move player as needed
        switch recognizer.state {
        case .began:
            movementControlPadDragStart = start
        case .changed:
            controlPlayer { component in
                component.requestedBaseVelocity = delta
            }
        case .ended:
            movementControlPadDragStart = nil
            controlPlayer { component in
                component.requestedBaseVelocity = Vec3()
            }
        default:
            break
        }
    }
    
    @objc
    private func handleCameraControl(_ recognizer: UIPanGestureRecognizer) {
        let delta = recognizer.velocity(in: view)
        
        // Rotate camera
        controlPlayer { component in
            component.rotateYaw(by: (-SceneFloat(delta.x) * inputSensivity) / 800)
            component.rotatePitch(by: (-SceneFloat(delta.y) * inputSensivity) / 800)
        }
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        // Respond to tap by jumping
        controlPlayer { component in
            component.jump()
        }
    }
    
    @objc
    private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        controlPlayer { component in
            switch recognizer.state {
            case .began:
                component.add(motionInput: .breakBlock)
            case .ended:
                component.remove(motionInput: .breakBlock)
            default:
                break
            }
        }
    }
    
    #endif
}

