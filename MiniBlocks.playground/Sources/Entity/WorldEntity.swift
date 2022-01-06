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

func makeWorldEntity(world: Box<World>) -> GKEntity {
    // Create node
    let node = SCNNode()
    
    // TODO: Add e.g. a WorldUpdateComponent that efficiently (through deltas, e.g. on strip-basis) updates the scene
    for (mapPos, strip) in world.wrappedValue.map {
        if let topmost = strip.topmost {
            // Create block node
            let material = SCNMaterial()
            material.diffuse.contents = NSImage(named: "TextureGrass.png")
            material.diffuse.minificationFilter = .none
            material.diffuse.magnificationFilter = .none
            let blockBox = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
            blockBox.materials = [material]
            let physics = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: blockBox))
            let blockNode = SCNNode(geometry: blockBox)
            blockNode.position = mapPos.with(y: topmost.y).asSCNVector
            blockNode.physicsBody = physics
            node.addChildNode(blockNode)
        }
    }
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(WorldComponent(world: world))
    entity.addComponent(SceneNodeComponent(node: node))
    
    return entity
}
