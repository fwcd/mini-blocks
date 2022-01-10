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

#endif

#if canImport(UIKit)

import UIKit

public typealias Color = UIColor
public typealias Image = UIImage
public typealias ViewController = UIViewController
public typealias SceneFloat = Float

#endif
