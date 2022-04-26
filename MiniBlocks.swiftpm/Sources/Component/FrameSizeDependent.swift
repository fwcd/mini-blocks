import SpriteKit

/// Indicates that the implementing component is dependent on the frame's size.
protocol FrameSizeDependent {
    func onUpdateFrame(to frame: CGRect)
}
