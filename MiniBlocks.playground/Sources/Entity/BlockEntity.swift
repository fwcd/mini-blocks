import GameplayKit

func makeDemoBlockPositions() -> [GridPos] {
    let radius = 50
    return (-radius...radius).flatMap { x in
        (-radius...radius).map { z in
            GridPos(
                x: x,
                y: Int((-5 * sin(CGFloat(x) / 10) * cos(CGFloat(z) / 10)).rounded()),
                z: z
            )
        }
    }
}

func makeBlockEntity(pos: GridPos) -> GKEntity {
    // Create state
    let pos = Box(wrappedValue: pos)
    
    // Create node
    let material = SCNMaterial()
    material.diffuse.contents = NSImage(named: "TextureGrass.png")
    let block = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
    block.materials = [material]
    let physics = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: block))
    let node = SCNNode(geometry: block)
    node.physicsBody = physics
    
    // Create entity
    let entity = GKEntity()
    entity.addComponent(SceneNodeComponent(node: node))
    entity.addComponent(GridPositionedComponent(pos: pos))
    
    return entity
}
