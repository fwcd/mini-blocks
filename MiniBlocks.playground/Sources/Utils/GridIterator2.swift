import Foundation

/// Iterates over a rectangle on the 2D grid.
struct GridIterator2<Element>: IteratorProtocol, Sequence where Element: Vec2 {
    let topLeftInclusive: Element
    let bottomRightExclusive: Element
    var i: Element.Coordinate = 0
    
    private var width: Element.Coordinate { bottomRightExclusive.x - topLeftInclusive.x }
    private var pos: Element { topLeftInclusive + Element(x: i % width, z: i / width) }
    private var isDone: Bool { pos.x >= bottomRightExclusive.x || pos.z >= bottomRightExclusive.z }
    
    mutating func next() -> Element? {
        guard !isDone else { return nil }
        let pos = pos
        i += 1
        return pos
    }
}
