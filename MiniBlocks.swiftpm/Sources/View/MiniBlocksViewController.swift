import Foundation
import CoreGraphics
import SceneKit
import SpriteKit
import GameController
import GameplayKit
import OSLog

private let log = Logger(subsystem: "MiniBlocks", category: "MiniBlocksViewController")

/// The game's primary view controller, responsible for
/// presenting the scene and handling input. Depending on
/// the platform, input is either handled using AppKit (macOS)
/// or UIKit/GameController (iOS/iPadOS).
public final class MiniBlocksViewController: ViewController, SCNSceneRendererDelegate, GestureRecognizerDelegate {
    private let playerName: String
    private let gameMode: GameMode
    private let worldGenerator: WorldGeneratorType
    private let renderDistance: Int
    private let ambientOcclusionEnabled: Bool
    private let debugStatsShown: Bool
    private let achievementsShown: Bool
    private let handShown: Bool
    private var previousUpdateTime: TimeInterval = 0
    
    // MARK: View properties
    
    private var sceneView: MiniBlocksSceneView!
    private let sceneFrame: CGRect?
    private var inputSensivity: SceneFloat = 1
    
    #if canImport(AppKit)
    @Box private var usesMouseKeyboardControls = true
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
    @Box private var usesMouseKeyboardControls = false
    private var panDragStart: CGPoint?
    private var panDraggedComponent: TouchInteractable?
    private var panDragRecognizer: UIPanGestureRecognizer!
    private var panCameraRecognizer: UIPanGestureRecognizer!
    private var tapRecognizer: UITapGestureRecognizer!
    private var pressRecognizer: UILongPressGestureRecognizer!
    public override var prefersHomeIndicatorAutoHidden: Bool { true }
    public override var prefersPointerLocked: Bool { true }
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
    private let handLoadComponentSystem = GKComponentSystem(componentClass: HandLoadComponent.self)
    private let hotbarHUDLoadComponentSystem = GKComponentSystem(componentClass: HotbarHUDLoadComponent.self)
    private let debugHUDLoadComponentSystem = GKComponentSystem(componentClass: DebugHUDLoadComponent.self)
    private let achievementHUDLoadComponentSystem = GKComponentSystem(componentClass: AchievementHUDLoadComponent.self)
    private let mouseCaptureVisibilityComponentSystem = GKComponentSystem(componentClass: MouseCaptureVisibilityComponent.self)
    private var playerEntity: GKEntity!
    private var controlPadHUDEntity: GKEntity?
    private var entities: [GKEntity] = []
    
    public init(
        sceneFrame: CGRect? = nil,
        playerName: String = "Player",
        worldGenerator: WorldGeneratorType = .nature(seed: "default"),
        gameMode: GameMode = .survival,
        renderDistance: Int = 8,
        ambientOcclusionEnabled: Bool = false,
        debugStatsShown: Bool = false,
        achievementsShown: Bool = true,
        handShown: Bool = true
    ) {
        self.sceneFrame = sceneFrame
        self.playerName = playerName
        self.worldGenerator = worldGenerator
        self.gameMode = gameMode
        self.renderDistance = renderDistance
        self.ambientOcclusionEnabled = ambientOcclusionEnabled
        self.debugStatsShown = debugStatsShown
        self.achievementsShown = achievementsShown
        self.handShown = handShown
        
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
        let world = World(generator: worldGenerator)
        let worldEntity = makeWorldEntity(world: world)
        add(entity: worldEntity)
        
        // Add player
        let playerSpawnPos2 = BlockPos2.zero
        let playerSpawnPos3 = playerSpawnPos2.with(y: world.height(at: playerSpawnPos2) ?? 10)
        playerEntity = makePlayerEntity(
            name: playerName,
            position: Vec3(playerSpawnPos3),
            gameMode: gameMode,
            worldEntity: worldEntity,
            retainRadius: renderDistance,
            ambientOcclusionEnabled: ambientOcclusionEnabled,
            handShown: handShown
        )
        add(entity: playerEntity)
        
        // Add overlay HUD
        add(entity: makeCrosshairHUDEntity(in: overlayScene.frame))
        add(entity: makeHotbarHUDEntity(in: overlayScene.frame, playerEntity: playerEntity))
        add(entity: makeDebugHUDEntity(in: overlayScene.frame, playerEntity: playerEntity))
        
        if achievementsShown {
            add(entity: makeAchievementHUDEntity(in: overlayScene.frame, playerEntity: playerEntity, usesMouseKeyboardControls: _usesMouseKeyboardControls))
        }
        
        #if canImport(AppKit)
        add(entity: makePauseHUDEntity(in: overlayScene.frame))
        #endif
        
        // Set up SCNView
        sceneView = sceneFrame.map { MiniBlocksSceneView(frame: $0) } ?? MiniBlocksSceneView()
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
        
        #if canImport(AppKit)
        // Set up mouse/keyboard handling when using AppKit (on macOS)
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
        
        #if canImport(UIKit)
        // Set up mouse/keyboard handling via the GameController framework (on iOS)
        // TODO: Use GameController-based input on macOS too (replacing AppKit)
        let center = NotificationCenter.default
        center.addObserver(forName: .GCMouseDidConnect, object: nil, queue: .main) {
            if let mouse = $0.object as? GCMouse {
                self.usesMouseKeyboardControls = true
                self.deregisterUITouchControls()
                self.registerHandlers(for: mouse)
            }
        }
        center.addObserver(forName: .GCMouseDidBecomeCurrent, object: nil, queue: .main) { _ in
            self.usesMouseKeyboardControls = true
            self.deregisterUITouchControls()
        }
        center.addObserver(forName: .GCMouseDidDisconnect, object: nil, queue: .main) {
            if let mouse = $0.object as? GCMouse {
                self.usesMouseKeyboardControls = false
                self.registerUITouchControls()
                self.deregisterHandlers(from: mouse)
            }
        }
        center.addObserver(forName: .GCKeyboardDidConnect, object: nil, queue: .main) {
            if let keyboard = $0.object as? GCKeyboard {
                self.registerHandlers(for: keyboard)
            }
        }
        
        // Set up touch/gesture controls if not using a mouse
        let panDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanDrag(_:)))
        panDragRecognizer.delegate = self
        
        let panCameraRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanCamera(_:)))
        panCameraRecognizer.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapRecognizer.delegate = self
        
        let pressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        pressRecognizer.minimumPressDuration = 0.5
        pressRecognizer.delegate = self
        
        self.panDragRecognizer = panDragRecognizer
        self.panCameraRecognizer = panCameraRecognizer
        self.tapRecognizer = tapRecognizer
        self.pressRecognizer = pressRecognizer
        
        if GCMouse.current == nil {
            registerUITouchControls()
        }
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
            DispatchQueue.main.async { [self] in
                overlayScene.addChild(node)
            }
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
        handLoadComponentSystem.addComponent(foundIn: entity)
        hotbarHUDLoadComponentSystem.addComponent(foundIn: entity)
        debugHUDLoadComponentSystem.addComponent(foundIn: entity)
        achievementHUDLoadComponentSystem.addComponent(foundIn: entity)
        mouseCaptureVisibilityComponentSystem.addComponent(foundIn: entity)
    }
    
    private func remove(entity: GKEntity) {
        entities.removeAll { $0 === entity }
        
        // Remove attached scene node if needed
        if let node = entity.component(ofType: SceneNodeComponent.self)?.node {
            node.removeFromParentNode()
        }
        
        // Remove attached sprite note if needed
        if let node = entity.component(ofType: SpriteNodeComponent.self)?.node {
            DispatchQueue.main.async {
                node.removeFromParent()
            }
        }
        
        // Remove components from their corresponding systems
        playerControlComponentSystem.removeComponent(foundIn: entity)
        playerPositioningComponentSystem.removeComponent(foundIn: entity)
        playerGravityComponentSystem.removeComponent(foundIn: entity)
        lookAtBlockComponentSystem.removeComponent(foundIn: entity)
        worldLoadComponentSystem.removeComponent(foundIn: entity)
        worldRetainComponentSystem.removeComponent(foundIn: entity)
        handLoadComponentSystem.removeComponent(foundIn: entity)
        hotbarHUDLoadComponentSystem.removeComponent(foundIn: entity)
        debugHUDLoadComponentSystem.removeComponent(foundIn: entity)
        achievementHUDLoadComponentSystem.removeComponent(foundIn: entity)
        mouseCaptureVisibilityComponentSystem.removeComponent(foundIn: entity)
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
        handLoadComponentSystem.update(deltaTime: deltaTime)
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
    
    // MARK: GameController-based mouse/keyboard controls
    
    #if canImport(UIKit)
    
    private func registerGCMouseKeyboardControls() {
        if let mouse = GCMouse.current {
            registerHandlers(for: mouse)
        }
        if let keyboard = GCKeyboard.coalesced {
            registerHandlers(for: keyboard)
        }
    }
    
    private func registerHandlers(for mouse: GCMouse) {
        guard let input = mouse.mouseInput else { return }
        input.mouseMovedHandler = { (_, dx, dy) in
            self.controlPlayer { component in
                component.rotateYaw(by: -(SceneFloat(dx) * self.inputSensivity) / 100)
                component.rotatePitch(by: (SceneFloat(dy) * self.inputSensivity) / 100)
            }
        }
        input.scroll.valueChangedHandler = { (_, dx, dy) in
            let slotDelta = Int(dx + dy)
            
            // Move the selected slot
            self.controlPlayer { component in
                component.moveHotbarSelection(by: slotDelta)
            }
        }
        input.leftButton.valueChangedHandler = { (_, _, pressed) in
            self.controlPlayer { component in
                if pressed {
                    component.add(motionInput: .breakBlock)
                } else {
                    component.remove(motionInput: .breakBlock)
                }
            }
        }
        input.rightButton?.valueChangedHandler = { (_, _, pressed) in
            self.controlPlayer { component in
                if pressed {
                    component.add(motionInput: .useBlock)
                } else {
                    component.remove(motionInput: .useBlock)
                }
            }
        }
    }
    
    private func deregisterHandlers(from mouse: GCMouse) {
        guard let input = mouse.mouseInput else { return }
        input.mouseMovedHandler = nil
        input.scroll.valueChangedHandler = nil
        input.leftButton.valueChangedHandler = nil
        input.rightButton?.valueChangedHandler = nil
    }
    
    private func registerHandlers(for keyboard: GCKeyboard) {
        guard let input = keyboard.keyboardInput else { return }
        input.keyChangedHandler = { (_, _, keyCode, down) in
            if down {
                self.keyDown(with: keyCode)
            } else {
                self.keyUp(with: keyCode)
            }
        }
    }
    
    private func keyDown(with keyCode: GCKeyCode) {
        if keyCode == .F3 {
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
            // Pressed key could be mapped to motion input, add it to the corresponding components
            controlPlayer { component in
                component.add(motionInput: motion)
            }
        }
    }
    
    private func keyUp(with keyCode: GCKeyCode) {
        let motion = motionInput(for: keyCode)
        // Pressed key could be mapped motion input, remove it from the corresponding components
        controlPlayer { component in
            component.remove(motionInput: motion)
        }
    }
    
    private func motionInput(for keyCode: GCKeyCode) -> PlayerControlComponent.MotionInput {
        switch keyCode {
        case .keyW: return .forward
        case .keyS: return .back
        case .keyA: return .left
        case .keyD: return .right
        case .spacebar: return .jump
        case .leftShift, .rightShift: return .sprint
        case .leftControl, .rightControl: return .sneak
        default: return []
        }
    }
    
    #endif
    
    // MARK: AppKit-based mouse/keyboard controls
    
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
            // Pressed key could be mapped to motion input, add it to the corresponding components
            controlPlayer { component in
                component.add(motionInput: motion)
            }
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        let motion = motionInput(for: KeyCode(rawValue: event.keyCode))
        // Pressed key could be mapped to motion input, remove it from the corresponding components
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
    
    private func registerUITouchControls() {
        let controlPadHUDEntity = makeControlPadHUDEntity(in: overlayScene.frame, playerEntity: playerEntity)
        add(entity: controlPadHUDEntity)
        self.controlPadHUDEntity = controlPadHUDEntity
        
        sceneView.addGestureRecognizer(panDragRecognizer)
        sceneView.addGestureRecognizer(panCameraRecognizer)
        sceneView.addGestureRecognizer(tapRecognizer)
        sceneView.addGestureRecognizer(pressRecognizer)
    }
    
    private func deregisterUITouchControls() {
        if let controlPadHUDEntity = controlPadHUDEntity {
            remove(entity: controlPadHUDEntity)
            self.controlPadHUDEntity = nil
        }
        
        sceneView.removeGestureRecognizer(panDragRecognizer)
        sceneView.removeGestureRecognizer(panCameraRecognizer)
        sceneView.removeGestureRecognizer(tapRecognizer)
        sceneView.removeGestureRecognizer(pressRecognizer)
    }
    
    public func gestureRecognizer(_ recognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        // Support multi-touch
        true
    }
    
    private func findDraggedComponent(for location: CGPoint) -> TouchInteractable? {
        let point = overlayScene.convertPoint(fromView: location)
        for entity in entities {
            for case let component as TouchInteractable in entity.components {
                if component.shouldReceiveDrag(at: point) {
                    return component
                }
            }
        }
        return nil
    }
    
    public func gestureRecognizer(_ recognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard [panCameraRecognizer, panDragRecognizer].contains(recognizer) else { return true }
        guard recognizer.numberOfTouches < 1 else { return false }
        let component = findDraggedComponent(for: touch.location(in: sceneView))
        return (component != nil) == (recognizer == panDragRecognizer)
    }
    
    @objc
    private func handlePanDrag(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view)
        let delta = recognizer.velocity(in: view)
        let point = overlayScene.convertPoint(fromView: location)
        let start = overlayScene.convertPoint(fromView: panDragStart ?? location)
        
        switch recognizer.state {
        case .began:
            if let component = findDraggedComponent(for: location) {
                panDragStart = location
                panDraggedComponent = component
                component.onDragStart(at: point)
            } else {
                recognizer.state = .failed
            }
        case .changed:
            if let component = panDraggedComponent {
                // Forward drag to dragged component
                component.onDragMove(by: CGVector(dx: delta.x, dy: -delta.y), start: start, current: point)
            }
        case .ended:
            panDragStart = nil
            panDraggedComponent?.onDragEnd()
            panDraggedComponent = nil
        default:
            break
        }
    }
    
    @objc
    private func handlePanCamera(_ recognizer: UIPanGestureRecognizer) {
        let delta = recognizer.velocity(in: view)
        // Rotate camera
        controlPlayer { component in
            component.rotateYaw(by: (-SceneFloat(delta.x) * inputSensivity) / 800)
            component.rotatePitch(by: (-SceneFloat(delta.y) * inputSensivity) / 800)
        }
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        // Forward tap to TouchInteractable components
        let point = overlayScene.convertPoint(fromView: recognizer.location(in: sceneView))
        for entity in entities {
            for case let component as TouchInteractable in entity.components {
                if component.onTap(at: point) {
                    return
                }
            }
        }
        
        // Respond to tap by using/placing a block
        controlPlayer { component in
            component.useBlock()
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

