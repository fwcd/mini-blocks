//: An open-world sandbox game.

// +------------------------------------------------+
// | Please make sure that your playgrounds preview |
// | is wide enough to display the app!             |
// +------------------------------------------------+

import PlaygroundSupport
import SceneKit

// Set up the main view controller.
PlaygroundPage.current.liveView = MiniBlocksViewController(
    // The size of the scene.
    sceneFrame: CGRect(x: 0, y: 0, width: 640, height: 480),
    // In debug mode gravity for the player is disabled, the camera can be moved freely and scene statistics will be shown.
    debugModeEnabled: false,
    // The camera interaction mode. Only used if debug mode is enabled.
    debugInteractionMode: .fly
)

