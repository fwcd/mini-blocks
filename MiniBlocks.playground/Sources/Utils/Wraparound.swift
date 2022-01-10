/// 'Wraps' the number around using modular arithemtic.
@propertyWrapper
struct Wraparound<Value>: Hashable where Value: SignedInteger {
    enum CodingKeys: String, CodingKey {
        case _wrappedValue = "value"
        case modulus
    }
    
    private var _wrappedValue: Value
    private let modulus: Value
    
    var wrappedValue: Value {
        get { _wrappedValue }
        set { _wrappedValue = newValue.floorMod(modulus) }
    }
    
    init(wrappedValue: Value, modulus: Value) {
        assert(modulus > 0)
        _wrappedValue = wrappedValue
        self.modulus = modulus
    }
}

extension Wraparound: Codable where Value: Codable {}
