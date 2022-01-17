import XCTest
@testable import MiniBlocks

class GridIterator2Tests: XCTestCase {
    func testIterator() {
        let topLeft = BlockPos2(x: 3, z: 6)
        let bottomRight = BlockPos2(x: 5, z: 10)
        let iterator = GridIterator2(topLeftInclusive: topLeft, bottomRightExclusive: bottomRight)
        let values = Array(iterator)
        
        XCTAssertEqual(values, [
            BlockPos2(x: 3, z: 6),
            BlockPos2(x: 4, z: 6),
            BlockPos2(x: 3, z: 7),
            BlockPos2(x: 4, z: 7),
            BlockPos2(x: 3, z: 8),
            BlockPos2(x: 4, z: 8),
            BlockPos2(x: 3, z: 9),
            BlockPos2(x: 4, z: 9),
        ])
    }
}
