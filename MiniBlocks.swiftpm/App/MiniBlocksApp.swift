import SwiftUI
import SceneKit

@main
struct MiniBlocksApp: App {
    var body: some Scene {
        WindowGroup {
            MiniBlocksView()
                .ignoresSafeArea()
        }
    }
}
