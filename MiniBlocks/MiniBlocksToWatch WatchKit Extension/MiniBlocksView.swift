//
//  MiniBlocksView.swift
//  MiniBlocksToWatch WatchKit Extension
//
//  Created by Fredrik on 22.04.22.
//

import SwiftUI
import SceneKit

private let viewController = MiniBlocksViewController(
    worldGenerator: .wavyHills
)

struct MiniBlocksView: View {
    var body: some View {
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

struct MiniBlocksView_Previews: PreviewProvider {
    static var previews: some View {
        MiniBlocksView()
    }
}
