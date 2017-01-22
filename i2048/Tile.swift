
enum Tile {
    case empty
    case tile(Int)
    
    func get() -> Int {
        switch self {
        case .tile(let v):
            return v
        case .empty :
            assert(false, "Can't get value from empty tile")
        }
    }
}
