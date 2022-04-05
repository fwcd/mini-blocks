import SceneKit

/// The texture mappings for every block type.
let blockTextureImages: [BlockType: Image] = [
    .grass: Image(named: "TextureGrass.png")!,
    .sand: Image(named: "TextureSand.png")!,
    .stone: Image(named: "TextureStone.png")!,
    .water: Image(named: "TextureWater.png")!,
    .wood: Image(named: "TextureWood.png")!,
    .leaves: Image(named: "TextureLeaves.png")!,
    .bedrock: Image(named: "TextureBedrock.png")!,
]

private func loadMaterial(for blockType: BlockType) -> SCNMaterial {
    let material = SCNMaterial()
    material.diffuse.contents = blockTextureImages[blockType]
    material.diffuse.minificationFilter = .none
    material.diffuse.magnificationFilter = .none
    return material
}

private func loadGeometry(for blockType: BlockType) -> SCNGeometry {
    let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
    box.materials = [loadMaterial(for: blockType)]
    return box
}

private let geometries: [BlockType: SCNGeometry] = Dictionary(
    uniqueKeysWithValues: blockTextureImages.keys.map { ($0, loadGeometry(for: $0)) }
)

func makeBlockNode(for block: Block) -> SCNNode {
    SCNNode(geometry: geometries[block.type])
}
