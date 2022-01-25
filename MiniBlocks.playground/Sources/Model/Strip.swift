/// A vertical 1x1 'slice' of blocks.
struct Strip: Hashable, Codable, Sequence {
    var blocks: [Int: Block] = [:]
    
    var isEmpty: Bool { blocks.isEmpty }
    var nilIfEmpty: Self? { isEmpty ? nil : self }
    
    var topmost: (y: Int, block: Block)? {
        block(below: nil)
    }
    
    subscript(y: Int) -> Block? {
        get { blocks[y] }
        set { blocks[y] = newValue }
    }
    
    func block(below y: Int?) -> (y: Int, Block)? {
        blocks
            .filter { $0.key <= (y ?? .max) }
            .max { $0.key < $1.key }
            .map { (y: $0.key, block: $0.value) }
    }
    
    func makeIterator() -> Dictionary<Int, Block>.Iterator {
        blocks.makeIterator()
    }
}
