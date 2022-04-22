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
    @State private var rotation: Double = 0
    
    var body: some View {
        SceneView(
            scene: viewController.scene,
            options: .rendersContinuously,
            antialiasingMode: .none,
            delegate: viewController
        )
        .onTapGesture {
            viewController.controlPlayer { component in
                component.jump()
            }
        }
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
        .focusable()
        .digitalCrownRotation($rotation)
        .onChange(of: rotation) { rotation in
            viewController.controlPlayer { component in
                component.requestedBaseVelocity = Vec3(z: -rotation)
            }
            
            // TODO: Add a way of stopping the movement
        }
    }
}

struct MiniBlocksView_Previews: PreviewProvider {
    static var previews: some View {
        MiniBlocksView()
    }
}
