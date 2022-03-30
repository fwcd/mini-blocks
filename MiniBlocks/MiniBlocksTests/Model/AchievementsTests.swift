import XCTest
@testable import MiniBlocks

class AchivementsTests: XCTestCase {
    func testAchievements() {
        let empty: Achievements = []
        XCTAssert(empty.isEmpty)
        XCTAssertFalse(empty.isSingle)
        XCTAssertEqual(Array(empty), [])
        
        let single: Achievements = .moveAround
        XCTAssertFalse(single.isEmpty)
        XCTAssert(single.isSingle)
        XCTAssertEqual(Array(single), [single])
        
        let another: Achievements = .jump
        XCTAssertFalse(another.isEmpty)
        XCTAssert(another.isSingle)
        XCTAssertEqual(Array(another), [another])
        
        let composite: Achievements = [.moveAround, .sprint]
        XCTAssertFalse(composite.isEmpty)
        XCTAssertFalse(composite.isSingle)
        XCTAssertEqual(Array(composite), [.moveAround, .sprint])
    }
}
