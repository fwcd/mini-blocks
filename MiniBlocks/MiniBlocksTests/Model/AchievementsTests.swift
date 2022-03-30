import XCTest
@testable import MiniBlocks

class AchivementsTests: XCTestCase {
    func testAchievements() {
        let empty: Achievements = []
        XCTAssert(empty.isEmpty)
        XCTAssertFalse(empty.isSingle)
        XCTAssertEqual(Array(empty), [])
        XCTAssertEqual(empty.next, [])
        
        let single: Achievements = .moveAround
        XCTAssertFalse(single.isEmpty)
        XCTAssert(single.isSingle)
        XCTAssertEqual(Array(single), [single])
        XCTAssertEqual(single.next, .jump)
        
        let another: Achievements = .jump
        XCTAssertFalse(another.isEmpty)
        XCTAssert(another.isSingle)
        XCTAssertEqual(Array(another), [another])
        XCTAssertEqual(another.next, .sprint)
        
        let composite: Achievements = [.moveAround, .sprint]
        XCTAssertFalse(composite.isEmpty)
        XCTAssertFalse(composite.isSingle)
        XCTAssertEqual(Array(composite), [.moveAround, .sprint])
        XCTAssertEqual(composite.next, .jump)
    }
}
