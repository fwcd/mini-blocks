import XCTest
@testable import MiniBlocks

class CyclicDequeTests: XCTestCase {
    func testCyclicDeque() {
        var a = CyclicDeque<Int>(capacity: 3)
        XCTAssert(a.isEmpty)
        XCTAssert(!a.isFull)
        XCTAssertNil(a.first)
        XCTAssertNil(a.last)
        XCTAssertEqual(Array(a), [])
        
        a.pushBack(23)
        XCTAssert(!a.isFull)
        XCTAssertEqual(a.count, 1)
        XCTAssertEqual(a.first, 23)
        XCTAssertEqual(a.last, 23)
        XCTAssertEqual(Array(a), [23])
        
        a.pushBack(43)
        a.pushBack(59)
        XCTAssert(a.isFull)
        XCTAssertEqual(a.count, 3)
        XCTAssertEqual(a.first, 23)
        XCTAssertEqual(a.last, 59)
        XCTAssertEqual(Array(a), [23, 43, 59])
        
        a.pushBack(98)
        XCTAssert(a.isFull)
        XCTAssertEqual(a.count, 3)
        XCTAssertEqual(a.first, 43)
        XCTAssertEqual(a.last, 98)
        XCTAssertEqual(Array(a), [43, 59, 98])
        
        XCTAssertEqual(a.popFront(), 43)
        XCTAssert(!a.isFull)
        XCTAssertEqual(Array(a), [59, 98])
        XCTAssertEqual(a.popBack(), 98)
        XCTAssertEqual(a.popFront(), 59)
        XCTAssert(a.isEmpty)
        XCTAssertNil(a.popFront())
        XCTAssertNil(a.popFront())
        
        var b = CyclicDeque<Int>(capacity: 2)
        
        XCTAssertNil(b.pushFront(1))
        XCTAssertEqual(b.count, 1)
        
        XCTAssertNil(b.pushFront(2))
        XCTAssertEqual(b.pushFront(9), 1)
        XCTAssertEqual(b.pushFront(7), 2)
        XCTAssertEqual(b.count, 2)
        XCTAssertEqual(Array(b), [7, 9])
        
        XCTAssertEqual(b.pushBack(12), 7)
        XCTAssertEqual(b.count, 2)
        XCTAssertEqual(Array(b), [9, 12])
        
        XCTAssertEqual(b.popFront(), 9)
        XCTAssertEqual(b.count, 1)
        XCTAssertEqual(Array(b), [12])
        
        XCTAssertNil(b.pushFront(98))
        XCTAssertEqual(b.count, 2)
        XCTAssertEqual(Array(b), [98, 12])
        
        XCTAssertEqual(b.popBack(), 12)
        XCTAssertEqual(b.count, 1)
        XCTAssertEqual(Array(b), [98])
        
        XCTAssertNil(b.pushBack(70))
        XCTAssertEqual(b.count, 2)
        XCTAssertEqual(Array(b), [98, 70])
        
        XCTAssertEqual(b.pushBack(34), 98)
        XCTAssertEqual(b.count, 2)
        XCTAssertEqual(Array(b), [70, 34])
    }
}
