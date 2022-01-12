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
    
    init(capacity: Int) {
        self.capacity = capacity
        
        elements = []
        elements.reserveCapacity(capacity)
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
    mutating func pushFront(_ element: Element) {
        let nextFront = (front - 1).floorMod(capacity)
        elements[nextFront] = element
        front = nextFront
        incrementCountIfNeeded()
    }
    
    /// Inserts an element at the back. O(1).
    mutating func pushBack(_ element: Element) {
        elements[back] = element
        back = (back + 1) % capacity
        incrementCountIfNeeded()
    }
    
    /// Extracts an element at the front. O(1).
    mutating func popFront() -> Element? {
        guard count > 0 else { return nil }
        let element = elements[front]
        front = (front + 1) % capacity
        decrementCountIfNeeded()
        return element
    }
    
    /// Extracts an element at the back. O(1).
    mutating func popBack() -> Element? {
        guard count > 0 else { return nil }
        let nextBack = (back - 1).floorMod(capacity)
        let element = elements[nextBack]
        back = nextBack
        decrementCountIfNeeded()
        return element
    }
    
    func makeIterator() -> Iterator {
        Iterator(deque: self, i: front)
    }
    
    struct Iterator: IteratorProtocol {
        let deque: CyclicDeque<Element>
        var i: Int
        
        mutating func next() -> Element? {
            guard i != deque.back else { return nil }
            let element = deque.elements[i]
            i = (i + 1) % deque.capacity
            return element
        }
    }
}
