@testable import MiniBlocks
import XCTest

class ThrottlerTests: XCTestCase {
    func testThrottler() {
        var counter = 0
        let action = { counter += 1 }
        var throttler = Throttler(interval: 1)
        
        throttler.run(deltaTime: 0, action: action)
        XCTAssertEqual(counter, 1)
        
        throttler.run(deltaTime: 0.2, action: action)
        throttler.run(deltaTime: 0.4, action: action)
        XCTAssertEqual(counter, 1)
        
        throttler.run(deltaTime: 0.5, action: action)
        XCTAssertEqual(counter, 2)
        
        throttler.run(deltaTime: 1.2, action: action)
        XCTAssertEqual(counter, 3)
    }
}
