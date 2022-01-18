@testable import MiniBlocks
import XCTest

class DebouncerTests: XCTestCase {
    func testDebouncer() {
        var counter = 0
        let action = { counter += 1 }
        var debouncer = Debouncer(interval: 1)
        
        debouncer.submit(deltaTime: 0, defer: true, action: action)
        XCTAssertEqual(counter, 0)
        
        debouncer.submit(deltaTime: 0.2, defer: true, action: action)
        debouncer.submit(deltaTime: 0.4, defer: true, action: action)
        debouncer.submit(deltaTime: 0.8, defer: true, action: action)
        debouncer.submit(deltaTime: 0.3, defer: true, action: action)
        XCTAssertEqual(counter, 0)
        
        debouncer.submit(deltaTime: 1.2, defer: false, action: action)
        XCTAssertEqual(counter, 1)
        
        debouncer.submit(deltaTime: 1.4, defer: false, action: action)
        XCTAssertEqual(counter, 1)
        
        debouncer.submit(deltaTime: 1.4, defer: true, action: action)
        XCTAssertEqual(counter, 1)
        
        debouncer.submit(deltaTime: 1.2, defer: false, action: action)
        XCTAssertEqual(counter, 2)
    }
}
