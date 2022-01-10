import GameplayKit

/// Lets the associated entity have a name.
class NameComponent: GKComponent {
    let name: String
    
    init(name: String) {
        self.name = name
        super.init()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
