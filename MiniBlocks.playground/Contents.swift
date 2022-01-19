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
    worldGenerator: .nature(seed: "Hello WWDC 2022!"),
    // The game mode determines the abilities of the player. In .survival mode the player is affected by gravity whereas .creative mode lets the player fly freely (ascend using space and descend using control).
    gameMode: .survival,
    // How many chunks to render in each direction. Large values may impact performance and memory usage. Note that this does not affect SceneKit's far plane, so the actual number of visible chunks may be lower.
    renderDistance: 8,
    // Ambient occlusion renders shadows in block corners for a more realistic look (which is, however, computationally more expensive). Disable to get better performance.
    ambientOcclusionEnabled: true,
    // Displays some SceneKit statistics such as frames-per-second when enabled.
    debugStatsShown: false
)

