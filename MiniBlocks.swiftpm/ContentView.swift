import SwiftUI
import SceneKit

struct ContentView: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: MiniBlocksViewController, context: Context) {}
    
    func makeUIViewController(context: Context) -> MiniBlocksViewController {
        MiniBlocksViewController()
    }
}
