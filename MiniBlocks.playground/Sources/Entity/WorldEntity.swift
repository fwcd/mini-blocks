import GameplayKit

func makeDemoBlockPositions() -> [BlockPos3] {
    let radius = 50
    return (-radius...radius).flatMap { x in
        (-radius...radius).map { z in
            BlockPos3(
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
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(WorldComponent(world: world))
    entity.addComponent(WorldAssociationComponent(worldEntity: entity)) // a world is associated with itself too
    entity.addComponent(SceneNodeComponent(node: node))
    entity.addComponent(WorldLoadComponent())
    
    // Uncomment to keep spawn chunks retained
    // entity.addComponent(WorldRetainComponent())
    
    return entity
}
