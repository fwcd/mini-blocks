import Foundation
import CoreGraphics

/// A small compatibility layer for running the playground on different platforms
/// like macOS and iOS while sharing a common codebase. This works, since AppKit
/// and UIKit share many similarities, making it easy to abstract over the (few)
/// differences.

#if canImport(AppKit)

import AppKit

public typealias Color = NSColor
public typealias Image = NSImage
public typealias ViewController = NSViewController
public typealias SceneFloat = CGFloat

/// Dummy protocol.
public protocol GestureRecognizerDelegate {}

#else
#if canImport(UIKit)

import UIKit

public typealias Color = UIColor
public typealias Image = UIImage
public typealias SceneFloat = Float

#if os(watchOS)

import SceneKit
import SpriteKit

open class BaseView: NSObject {
    
}

open class SCNView: BaseView {
    public var scene: SCNScene? = nil
    public weak var delegate: SCNSceneRendererDelegate? = nil
    public var allowsCameraControl: Bool = false
    public var showsStatistics: Bool = false
    public var backgroundColor: Color?
    public var overlaySKScene: SKScene? = nil
    public var antialiasingMode: SCNAntialiasingMode = .none
    public var isJitteringEnabled: Bool = false
    public var isPlaying: Bool = false
    
    public override init() {
        super.init()
    }
    
    public init(frame: CGRect) {
        super.init()
    }
}

open class ViewController: NSObject {
    public var view: BaseView!
    
    public init(nibName: String? = nil, bundle: Bundle? = nil) {
        super.init()
    }
    
    open func loadView() {}
}

public protocol GestureRecognizerDelegate {}

#else

public typealias ViewController = UIViewController
public typealias GestureRecognizerDelegate = UIGestureRecognizerDelegate

#endif
#endif
#endif
