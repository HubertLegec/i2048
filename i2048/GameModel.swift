
import UIKit

class GameModel : NSObject {
    let size : Int
    var gameboard : Gameboard
    var timer : Timer
    var queue : [MoveCommand]
    unowned var delegate : GameViewController
    
    var score : Int = 0 {
        didSet {
            delegate.scoreChanged(score)
        }
    }
    
    init(size s : Int, delegate d : GameViewController) {
        self.size = s
        self.delegate = d
        queue = [MoveCommand]()
        timer = Timer()
        gameboard = Gameboard(size: s, initialValue: .empty)
        super.init()
    }
    
    func reset() {
        score = 0
        gameboard.setAll(.empty)
        queue.removeAll(keepingCapacity: true)
        timer.invalidate()
    }
    
    //funkcja kolejkuje zdarzenie przesunięcia po ekranie w określonym kierunku, jeśli timer nie działa, to odpala go
    func addMoveToQueue(_ direction : UISwipeGestureRecognizerDirection, completion : @escaping (Bool) -> ()) {
        queue.append(MoveCommand(direction: direction, completion: completion))
        if !timer.isValid {
            timerFired(timer)
        }
    }
    
    //funkcja uruchamiana po wyzwoleniu timera, pobiera z kolejki kolejne zdarzenia dopóki któreś nie spowoduje zmiany stanu planszy
    //jeśli nastąpiła zmiana stanu planszy, to to ustawia timer, żeby uruchomił się za chwilę ponownie
    func timerFired(_ : Timer) {
        var changed = false
        while queue.count > 0 && !changed {
            let command = queue.remove(at: 0)
            changed = move(command.direction)
            command.completion(changed)
        }
        if changed {
            timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(GameModel.timerFired(_:)), userInfo: nil, repeats: false)
        }
    }
    
    //dodanie nowego kafelka do planszy
    func insertTile(_ position : (Int, Int), value: Int) {
        let (x, y) = position
        if case .empty = gameboard[x, y] {
            gameboard[x, y] = Tile.tile(value)
            delegate.addTile(position, value: value)
        }
    }
    
    //wstawia nowy kafelek o zadanej wartości na losowo wybranej z dostępnych pozycji
    //jeśli żadna pozycja nie jest wolna, nic się nie dzieje
    func insertTileAtRandomLocation(_ value : Int) {
        let openSpots = gameboard.getEmptySpots()
        if openSpots.isEmpty {
            return
        }
        let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
        let (x, y) = openSpots[idx]
        insertTile((x, y), value: value)
    }
    
    //sprawdzenie czy użytkownik przegrał
    //najpierw sprawdzona zostaje dostępność wolnych miejsc na planszy a następnie możliwość połączenia kafelków o tej samej wartości
    func lost() -> Bool {
        return gameboard.getEmptySpots().isEmpty && !gameboard.hasNeighboursWithSameValues()
    }
    
    //sprawdzenie czy użytkownik wygrał, sprowadza się do sprawdzenia czy na planszy występuje kafelek o wartości 2048
    func won() -> Bool {
        return gameboard.hasTileWithValue(2048).0
    }
    
    //przetwarza pojedynczy gest użytkownika
    func move(_ moveDirection : UISwipeGestureRecognizerDirection) -> Bool {
        var atLeastOneMove = false
        for i in 0 ..< self.size {
            let coords = generateCoords(iteration: i, direction: moveDirection)
            let tiles = coords.map() {
                (c : (Int, Int)) -> Tile in
                return self.gameboard[c.0, c.1]
            }
            let orders = merge(tiles)
            atLeastOneMove = orders.count > 0 ? true : atLeastOneMove
            for object in orders {
                switch object {
                case let Move.singleMove(s, dest, val, wasMerged) :
                    let (sx, sy) = coords[s]
                    let (dx, dy) = coords[dest]
                    if wasMerged {
                        score += val
                    }
                    gameboard[sx, sy] = Tile.empty
                    gameboard[dx, dy] = Tile.tile(val)
                    delegate.moveOneTile(coords[s], to: coords[dest], value: val)
                case let Move.doubleMove(s1, s2, dest, val) :
                    let (s1x, s1y) = coords[s1]
                    let (s2x, s2y) = coords[s2]
                    let (dx, dy) = coords[dest]
                    score += val
                    gameboard[s1x, s1y] = Tile.empty
                    gameboard[s2x, s2y] = Tile.empty
                    gameboard[dx, dy] = Tile.tile(val)
                    delegate.moveTwoTiles((coords[s1], coords[s2]), to: coords[dest], value: val)
                }
            }
        }
        return atLeastOneMove
    }
    
    //zależnie od kierunku ruchu tworzy listę wszystkich kafelków w wierszu lub kolumnie, które powinny zostać przesunięte ustawiając je w odpowiedniej kolejności
    func generateCoords(iteration : Int, direction : UISwipeGestureRecognizerDirection) -> [(Int, Int)] {
        var buffer = Array<(Int, Int)>(repeating: (0, 0), count: self.size)
        for i in 0 ..< self.size {
            switch direction {
            case UISwipeGestureRecognizerDirection.up :
                buffer[i] = (i, iteration)
            case UISwipeGestureRecognizerDirection.down :
                buffer[i] = (self.size - i - 1, iteration)
            case UISwipeGestureRecognizerDirection.left :
                buffer[i] = (iteration, i)
            case UISwipeGestureRecognizerDirection.right :
                buffer[i] = (iteration, self.size - i - 1)
            default:
                assert(false, "Error")
            }
        }
        return buffer
    }
    
    func merge(_ tiles : [Tile]) -> [Move] {
        return convertActionsToMoves(joinELements(removeEmptySpace(tiles)))
    }
    
    //usuwa z listy podanej jako argument puste kafelki jednocześnie pozostawionym przypisuje potrzebną do wykonania akcję jeśli trzeba je przesunąć
    func removeEmptySpace(_ tiles : [Tile]) -> [Action] {
        var buffer = [Action]()
        for (idx, tile) in tiles.enumerated() {
            switch tile {
            case let .tile(value) where buffer.count == idx:
                buffer.append(Action.noAction(source: idx, value: value))
            case let .tile(value) :
                buffer.append(Action.move(source: idx, value: value))
            default:
                break
            }
        }
        return buffer
    }
    
    //dokonuje scalenia elementów stojących na liście obok siebie i mających taką samą wartość
    //każdy kafelek w jednym ruchu może wziąć udział tylko w jednym scalaniu
    func joinELements(_ elements : [Action]) -> [Action] {
        var buffer = [Action]()
        var skipNext = false
        for (idx, elem) in elements.enumerated() {
            if (skipNext) {
                skipNext = false
                continue
            }
            switch elem {
            case let .noAction(s, v) where (idx < elements.count - 1 && v == elements[idx + 1].getValue()
                && GameModel.noActionIsUnmoved(idx, buffer.count, s)) :
                let next = elements[idx + 1]
                let nv = v + next.getValue()
                skipNext = true
                buffer.append(Action.singleCombine(source: next.getSource(), value: nv))
            case let t where (idx < elements.count - 1 && t.getValue() == elements[idx + 1].getValue()) :
                let next = elements[idx + 1]
                let nv = t.getValue() + next.getValue()
                skipNext = true
                buffer.append(Action.doubleCombine(source1: t.getSource(), source2: next.getSource(), value: nv))
            case let .noAction(s, v) where !GameModel.noActionIsUnmoved(idx, buffer.count, s) :
                buffer.append(Action.move(source: s, value: v))
            case let .noAction(s, v) :
                buffer.append(Action.noAction(source: s, value: v))
            case let .move(s, v) :
                buffer.append(Action.move(source: s, value: v))
            default :
                break
            }
        }
        return buffer
    }
    
    //metoda ta zamienia tokeny opisujące akcje do wykoania na konkretne ruchy przesłane do kontrolera widoku
    func convertActionsToMoves(_ actions : [Action]) -> [Move] {
        var buffer = [Move]()
        for (idx, a) in actions.enumerated() {
            switch a {
            case let .move(s, v) :
                buffer.append(Move.singleMove(source: s, destination: idx, value: v, wasMerged: false))
            case let .singleCombine(s, v) :
                buffer.append(Move.singleMove(source: s, destination: idx, value: v, wasMerged: true))
            case let .doubleCombine(s1, s2, v) :
                buffer.append(Move.doubleMove(source1: s1, source2: s2, destination: idx, value: v))
            default:
                break
            }
        }
        return buffer
    }
    
    //sprawdza czy token 'NoAction' wciąż przedstawia nieprzesunięty kafelek
    class func noActionIsUnmoved(_ inputPosition : Int, _ outputLength : Int, _ originalPosition : Int) -> Bool {
        return (inputPosition == originalPosition) && (inputPosition == outputLength)
    }
}
