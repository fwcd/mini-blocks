import Foundation

/// A small compatibility layer for running the playground on different platforms
/// like macOS and iOS while sharing a common codebase. This works, since AppKit
/// and UIKit share many similarities, making it easy to abstract over the (few)
/// differences.

#if canImport(AppKit)

import AppKit

typealias Color = NSColor

#endif

#if canImport(UIKit)

import UIKit

typealias Color = UIColor

#endif
