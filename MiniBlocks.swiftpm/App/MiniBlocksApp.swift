import SwiftUI
import SceneKit

private let viewController = MiniBlocksViewController()

@main
struct MiniBlocksApp: App {
    var body: some Scene {
        WindowGroup {
            SceneView(scene: viewController.scene)
        }
    }
}
