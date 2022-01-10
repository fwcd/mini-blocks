import XCTest
@testable import MiniBlocks

class MathUtilsTests: XCTestCase {
    func testFloorDiv() {
        XCTAssertEqual(11.floorDiv(5), 2)
        XCTAssertEqual(5.floorDiv(5), 1)
        XCTAssertEqual(4.floorDiv(5), 0)
        XCTAssertEqual(2.floorDiv(5), 0)
        XCTAssertEqual(0.floorDiv(5), 0)
        XCTAssertEqual((-1).floorDiv(5), -1)
        XCTAssertEqual((-4).floorDiv(5), -1)
        XCTAssertEqual((-5).floorDiv(5), -1)
        XCTAssertEqual((-6).floorDiv(5), -2)
        XCTAssertEqual((-24).floorDiv(5), -5)
        XCTAssertEqual((-25).floorDiv(5), -5)
        XCTAssertEqual((-26).floorDiv(5), -6)
    }
    
    func testFloorMod() {
        XCTAssertEqual(5.floorMod(4), 1)
        XCTAssertEqual(4.floorMod(4), 0)
        XCTAssertEqual(3.floorMod(4), 3)
        XCTAssertEqual(0.floorMod(4), 0)
        XCTAssertEqual((-1).floorMod(4), 3)
        XCTAssertEqual((-2).floorMod(4), 2)
        XCTAssertEqual((-3).floorMod(4), 1)
        XCTAssertEqual((-4).floorMod(4), 0)
        XCTAssertEqual((-5).floorMod(4), 3)
    }
}
