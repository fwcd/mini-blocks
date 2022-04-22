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
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        let delta = drag.location - drag.predictedEndLocation
                        viewController.controlPlayer { component in
                            component.rotateYaw(by: SceneFloat(delta.x / 40))
                            component.rotatePitch(by: SceneFloat(delta.y / 40))
                        }
                    }
            )
        }
    }
}
