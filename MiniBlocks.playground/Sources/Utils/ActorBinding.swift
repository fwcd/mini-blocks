struct ActorBinding<Wrapped> {
    private let get: () async -> Wrapped
    private let set: (Wrapped) async -> Void
    
    init(get: @escaping () async -> Wrapped, set: @escaping (Wrapped) async -> Void) {
        self.get = get
        self.set = set
    }
}
