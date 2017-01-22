
class Gameboard {
    let size : Int
    var board : [Tile]
    
    init(size s : Int, initialValue : Tile) {
        size = s
        board = [Tile](repeating: initialValue, count : s*s)
    }
    
    subscript(row : Int, column : Int) -> Tile {
        get {
            return board[row * size + column]
        }
        set {
            board[row * size + column] = newValue
        }
    }
    
    func setAll(_ value : Tile) {
        for i in 0 ..< size {
            for j in 0 ..< size {
                self[i, j] = value
            }
        }
    }
    
    func getEmptySpots() -> [(Int, Int)] {
        var buffer : [(Int, Int)] = []
        for i in 0 ..< size {
            for j in 0 ..< size {
                if case .empty = self[i, j] {
                    buffer.append((i, j))
                }
            }
        }
        return buffer
    }
    
    func hasTileWithValueGreaterThan(_ threshold: Int) -> (Bool, (Int, Int)?) {
        for i in 0 ..< size {
            for j in 0 ..< size {
                if case let .tile(v) = self[i, j], v >= threshold {
                    return (true, (i, j))
                }
            }
        }
        return (false, nil)
    }
    
    func hasNeighboursWithSameValues() -> Bool {
        for i in 0 ..< size {
            for j in 0 ..< size {
                switch self[i, j] {
                case .empty:
                    assert(false, "Gameboard inconsistency")
                case let .tile(v):
                    if tileBelowHasSameValue((i, j), v) || tileToRightHasSameValue((i, j), v) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func tileBelowHasSameValue(_ location : (Int, Int), _ value : Int) -> Bool {
        let (x, y) = location
        guard y != size - 1 else {
            return false
        }
        if case let .tile(v) = self[x, y+1] {
            return v == value
        }
        return false
    }
    
    private func tileToRightHasSameValue(_ location : (Int, Int), _ value : Int) -> Bool {
        let (x, y) = location
        guard x != size - 1 else {
            return false
        }
        if case let .tile(v) = self[x+1, y] {
            return v == value
        }
        return false
    }
}
