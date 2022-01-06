//: An open-world sandbox game.

// +------------------------------------------------+
// | Please make sure that your playgrounds preview |
// | is wide enough to display the app!             |
// +------------------------------------------------+

import PlaygroundSupport
import SceneKit

// Set up frame and main view controller
let frame = CGRect(x: 0, y: 0, width: 640, height: 480)
PlaygroundPage.current.liveView = MiniBlocksViewController(
    sceneFrame: frame,
    debugModeEnabled: true,
    debugInteractionMode: .fly
)

