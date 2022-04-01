/// A wrapper that adds reference semantics/shared ownership and isolation to a value.
actor ActorBox<Wrapped> {
    private var wrappedValue: Wrapped
    
    init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }
}
