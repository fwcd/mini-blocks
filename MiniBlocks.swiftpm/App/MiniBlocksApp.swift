import SwiftUI
import SceneKit

private let viewController = MiniBlocksViewController(
    worldGenerator: .wavyHills
)

@main
struct MiniBlocksApp: App {
    var body: some Scene {
        WindowGroup {
            SceneView(
                scene: viewController.scene,
                options: .rendersContinuously,
                antialiasingMode: .none,
                delegate: viewController
            )
        }
    }
}
