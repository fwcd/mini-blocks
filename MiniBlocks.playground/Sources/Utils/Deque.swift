/// A double-ended queue. The protocol makes no guarantee about the precise semantics of such queues, in particular implementations are free to e.g. remove elements at the front when new ones are inserted at the back.
protocol Deque: Sequence {
    associatedtype Element
    
    /// The number of elements.
    var count: Int { get }
    
    /// Peeks at the front.
    var first: Element? { get }
    
    /// Peeks at the end.
    var last: Element? { get }
    
    /// Inserts an element at the beginning.
    mutating func pushFront(_ element: Element)
    
    /// Inserts an element at the end.
    mutating func pushBack(_ element: Element)
    
    /// Extracts an element at the beginning.
    @discardableResult
    mutating func popFront() -> Element?
    
    /// Extracts an element at the end.
    @discardableResult
    mutating func popBack() -> Element?
}

extension Deque {
    /// Whether the queue is empty.
    var isEmpty: Bool { count == 0 }
}
