import XCTest
@testable import MiniBlocks

class GridIterator2Tests: XCTestCase {
    func testIterator() {
        let topLeft = GridPos2(x: 3, z: 6)
        let bottomRight = GridPos2(x: 5, z: 10)
        let iterator = GridIterator2(topLeftInclusive: topLeft, bottomRightExclusive: bottomRight)
        let values = Array(iterator)
        
        XCTAssertEqual(values, [
            GridPos2(x: 3, z: 6),
            GridPos2(x: 4, z: 6),
            GridPos2(x: 3, z: 7),
            GridPos2(x: 4, z: 7),
            GridPos2(x: 3, z: 8),
            GridPos2(x: 4, z: 8),
            GridPos2(x: 3, z: 9),
            GridPos2(x: 4, z: 9),
        ])
    }
}