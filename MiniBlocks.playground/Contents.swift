//: A procedurally generated open-world sandbox game.

// +------------------------------------------------+
// | Please make sure that your playgrounds preview |
// | is wide enough to display the scene!           |
// +------------------------------------------------+

import PlaygroundSupport
import SceneKit

// Set up the main view controller.
// Feel free to experiment with the parameters, in particular world generators and render distance!
PlaygroundPage.current.liveView = MiniBlocksViewController(
    // The size of the scene.
    sceneFrame: CGRect(x: 0, y: 0, width: 640, height: 480),
    // The world generator to use, e.g. .empty, .flat, .wavyHills, .nature or .ocean (Note that .ocean is quite resource-intensive though!).
    worldGenerator: .nature,
    // How many chunks to render in each direction. Large values may impact performance and memory usage. Note that this does not affect SceneKit's far plane, so the actual number of visible chunks may be lower.
    renderDistance: 8,
    // In debug mode gravity for the player is disabled, the camera can be moved freely and scene statistics will be shown.
    debugModeEnabled: false,
    // The camera interaction mode. Only used if debug mode is enabled.
    debugInteractionMode: .fly
)

