import SwiftUI

struct MiniBlocksView: UIViewControllerRepresentable {
    func updateUIViewController(_ vc: MiniBlocksViewController, context: Context) {
        // Do nothing
    }
    
    func makeUIViewController(context: Context) -> MiniBlocksViewController {
        MiniBlocksViewController()
    }
}
