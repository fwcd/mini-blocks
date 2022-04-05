/// A fixed-size, ring buffer implementation of a double-ended queue.
struct CyclicDeque<Element>: Deque {
    /// The array storing the elements.
    private var elements: [Element?]
    /// Index of the first element.
    private var front: Int = 0
    /// Index of one element past the last element, i.e. the next insertion position.
    private var back: Int = 0
    
    /// The maximum size of the queue.
    let capacity: Int
    /// The current size of the queue.
    private(set) var count: Int = 0
    /// Whether the queue has reached its maximum size.
    var isFull: Bool { count == capacity }
    
    var first: Element? {
        guard count > 0 else { return nil }
        return elements[front]
    }
    
    var last: Element? {
        guard count > 0 else { return nil }
        return elements[(back - 1).floorMod(capacity)]
    }
    
    init(capacity: Int) {
        self.capacity = capacity
        elements = Array(repeating: nil, count: capacity)
    }
    
    private mutating func incrementCountIfNeeded() {
        if count < capacity {
            count += 1
        }
    }
    
    private mutating func decrementCountIfNeeded() {
        if count > 0 {
            count -= 1
        }
    }
    
    /// Inserts an element at the front. O(1).
    @discardableResult
    mutating func pushFront(_ element: Element) -> Element? {
        let nextFront = (front - 1).floorMod(capacity)
        var removedElement: Element? = nil
        if isFull {
            assert(front == back)
            removedElement = elements[nextFront]
            back = nextFront
        }
        elements[nextFront] = element
        front = nextFront
        incrementCountIfNeeded()
        return removedElement
    }
    
    /// Inserts an element at the back. O(1).
    @discardableResult
    mutating func pushBack(_ element: Element) -> Element? {
        let nextBack = (back + 1) % capacity
        var removedElement: Element? = nil
        if isFull {
            assert(front == back)
            removedElement = elements[back]
            front = nextBack
        }
        elements[back] = element
        back = nextBack
        incrementCountIfNeeded()
        return removedElement
    }
    
    /// Extracts an element at the front. O(1).
    @discardableResult
    mutating func popFront() -> Element? {
        guard count > 0 else { return nil }
        let element = elements[front]
        elements[front] = nil
        front = (front + 1) % capacity
        decrementCountIfNeeded()
        return element
    }
    
    /// Extracts an element at the back. O(1).
    @discardableResult
    mutating func popBack() -> Element? {
        guard count > 0 else { return nil }
        let nextBack = (back - 1).floorMod(capacity)
        let element = elements[nextBack]
        elements[nextBack] = nil
        back = nextBack
        decrementCountIfNeeded()
        return element
    }
    
    func makeIterator() -> Iterator {
        Iterator(deque: self)
    }
    
    struct Iterator: IteratorProtocol {
        let deque: CyclicDeque<Element>
        var i: Int = 0
        
        mutating func next() -> Element? {
            guard i < deque.count else { return nil }
            let element: Element = deque.elements[(deque.front + i) % deque.capacity]!
            i += 1
            return element
        }
    }
}
