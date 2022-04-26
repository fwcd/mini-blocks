import SwiftUI
import UIKit

struct MiniBlocksView: UIViewControllerRepresentable {
    func updateUIViewController(_ vc: MiniBlocksViewController, context: Context) {
        // Do nothing
    }
    
    func makeUIViewController(context: Context) -> MiniBlocksViewController {
        MiniBlocksViewController(
            sceneFrame: UIScreen.main.bounds,
            ambientOcclusionEnabled: true,
            autoJump: true
        )
    }
}
