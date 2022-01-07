import GameplayKit

func makeDemoBlockPositions() -> [GridPos3] {
    let radius = 50
    return (-radius...radius).flatMap { x in
        (-radius...radius).map { z in
            GridPos3(
                x: x,
                y: Int((-5 * sin(CGFloat(x) / 10) * cos(CGFloat(z) / 10)).rounded()),
                z: z
            )
        }
    }
}

func makeWorldEntity(world: World) -> GKEntity {
    // Create node
    let node = SCNNode()
    
    // TODO: Add e.g. a WorldUpdateComponent that efficiently (through deltas, e.g. on strip-basis) updates the scene
    
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(WorldComponent(world: world))
    entity.addComponent(WorldAssociationComponent(worldEntity: entity)) // a world is associated with itself too
    entity.addComponent(SceneNodeComponent(node: node))
    entity.addComponent(WorldLoadComponent())
    entity.addComponent(WorldRetainComponent()) // keep spawn chunks retained
    
    return entity
}
