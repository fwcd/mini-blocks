/// A wrapper that adds reference semantics/shared ownership to a value.
@propertyWrapper
class Box<Wrapped> {
    var wrappedValue: Wrapped
    
    init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }
}
