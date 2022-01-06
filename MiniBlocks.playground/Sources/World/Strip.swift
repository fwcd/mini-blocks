/// A vertical 1x1 'slice' of blocks.
struct Strip {
    var blocks: [StripBlock] = []
    
    var topmostBlock: StripBlock? {
        blocks.max { $0.y < $1.y }
    }
}
