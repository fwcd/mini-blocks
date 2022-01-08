/// A vertical 1x1 'slice' of blocks.
struct Strip: Sequence {
    private var blocks: [Block?]
    
    var isEmpty: Bool { blocks.isEmpty }
    var nilIfEmpty: Self? { isEmpty ? nil : self }
    
    init() {
        blocks = Array(repeating: nil, count: StripConstants.totalHeight)
    }
    
    init(blocks: [Int: Block]) {
        self.init()
        for (y, block) in blocks {
            self.blocks[y + StripConstants.offset] = block
        }
    }
    
    var topmost: (y: Int, block: Block)? {
        for (i, block) in blocks.enumerated().reversed() {
            if let block = block {
                return (y: i - StripConstants.offset, block: block)
            }
        }
        return nil
    }
    
    subscript(y: Int) -> Block? {
        get { StripConstants.range.contains(y) ? blocks[StripConstants.offset + y] : nil }
        set { blocks[y] = newValue }
    }
    
    func makeIterator() -> Iterator {
        Iterator(blocks: blocks)
    }
    
    struct Iterator: IteratorProtocol {
        private let blocks: [Block?]
        private var i: Int
        
        init(blocks: [Block?]) {
            self.blocks = blocks
            for (i, block) in blocks.enumerated() where block != nil {
                self.i = i
                return
            }
            i = 0
        }
        
        var isDone: Bool { i >= blocks.count }
        
        mutating func next() -> (y: Int, block: Block)? {
            guard !isDone else { return nil }
            let y = i - StripConstants.offset
            let block = blocks[i]!
            repeat {
                i += 1
            } while !isDone && blocks[i] == nil
            return (y: y, block: block)
        }
    }
}
