/// A cache that removes mappings in FIFO order.
struct FIFOCache<Key, Value> where Key: Hashable {
    private var queue: CyclicDeque<Key>
    private var mappings: [Key: Value] = [:]
    
    init(capacity: Int = 16) {
        queue = CyclicDeque(capacity: capacity)
    }
    
    subscript(key: Key) -> Value? {
        mappings[key]
    }
    
    mutating func insert(key: Key, value: Value) {
        mappings[key] = value
    }
}
