import Foundation

/// Iterates over a rectangle on the 2D grid.
struct Grid2Iterator: IteratorProtocol, Sequence {
    let topLeftInclusive: GridPos2
    let bottomRightExclusive: GridPos2
    var i: Int = 0
    
    private var width: Int { bottomRightExclusive.x - topLeftInclusive.x }
    private var pos: GridPos2 { topLeftInclusive + GridPos2(x: i % width, z: i / width) }
    private var isDone: Bool { pos.x >= bottomRightExclusive.x || pos.z >= bottomRightExclusive.z }
    
    mutating func next() -> GridPos2? {
        guard !isDone else { return nil }
        let pos = pos
        i += 1
        return pos
    }
}
