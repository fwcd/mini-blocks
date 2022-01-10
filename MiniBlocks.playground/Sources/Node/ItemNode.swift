import SpriteKit

private func loadSpriteTexture(for itemType: ItemType) -> SKTexture {
    let texture: SKTexture
    
    switch itemType {
    case .block(let blockType):
        guard let image = blockTextureImages[blockType] else { fatalError("No block texture for \(blockType)") }
        texture = SKTexture(image: image)
    }
    
    return texture
}

// TODO: Cache SKTextures?

func makeItemNode(for item: Item, size: CGFloat) -> SKNode {
    let node = SKSpriteNode(texture: loadSpriteTexture(for: item.type))
    node.size = CGSize(width: size, height: size)
    return node
}
