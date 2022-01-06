/// A vertical 1x1 'slice' of blocks.
struct Strip {
    var blocks: [Int: Block] = [:]
    
    var topmost: (y: Int, block: Block)? {
        blocks.max { $0.key < $1.key }.map { (y: $0.key, block: $0.value) }
    }
}
