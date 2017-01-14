//
//  gameModel.swift
//  i2048
//
//  Created by Hubert Legęć on 11.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

import Foundation

class GameModel : NSObject {
    let size : Int
    let threshold : Int
    var gameboard : Gameboard
    
    var score : Int = 0 {
        didSet {
            delegate.scoreChanged(score)
        }
    }
    
    unowned var delegate : GameProtocol
    
    var timer : Timer
    var queue : [Move]
    
    let MAX_COMMANDS = 100
    let QUEUE_DELAY = 0.3
    
    init(size : Int, threshold : Int, delegate d : GameProtocol) {
        self.size = size
        self.threshold = threshold
        self.delegate = d
        queue = [Move]()
        timer = Timer()
        gameboard = Gameboard(size: size, initialValue: .empty)
        super.init()
    }
    
    func reset() {
        score = 0
        gameboard.setAll(.empty)
        queue.removeAll(keepingCapacity: true)
        timer.invalidate()
    }
    
    func lost() -> Bool {
        guard gameboard.getEmptySpots().isEmpty else {
            return false
        }
        return !gameboard.hasNeighboursWithSameValues()
    }
    
    func won() -> (Bool, (Int, Int)?) {
        for i in 0 ..< size {
            for j in 0 ..< size {
                if case let .tile(v) = gameboard[i, j], v >= threshold {
                    return (true, (i, j))
                }
            }
        }
        return (false, nil)
    }
    
    func move(_ moveDirection : MoveDirection) -> Bool {
        var atLeastOneMove = false
        for i in 0 ..< self.size {
            let coords = generateCoords(iteration: i, direction: moveDirection)
            let tiles = coords.map() {
                (c : (Int, Int)) -> Tile in
                let (x, y) = c
                return self.gameboard[x, y]
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
    
    func generateCoords(iteration : Int, direction : MoveDirection) -> [(Int, Int)] {
        var buffer = Array<(Int, Int)>(repeating: (0, 0), count: self.size)
        for i in 0 ..< self.size {
            switch direction {
            case .up :
                buffer[i] = (i, iteration)
            case .down :
                buffer[i] = (self.size - i - 1, iteration)
            case .left :
                buffer[i] = (iteration, i)
            case .right :
                buffer[i] = (iteration, self.size - i - 1)
            }
        }
        return buffer
    }
    
    func merge(_ tiles : [Tile]) -> [Move] {
        return convertActionsToMoves(joinELements(removeEmptySpace(tiles)))
    }
    
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
    
    func joinELements(_ elements : [Action]) -> [Action] {
        var buffer = [Action]()
        var skipNext = false
        for (idx, elem) in elements.enumerated() {
            if (skipNext) {
                skipNext = false
                continue
            }
            switch elem {
            case .singleCombine :
                    assert(false, "Can't have single combine elem in input")
            case .doubleCombine :
                assert(false, "Can't have double combine elem in input")
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
    
    class func noActionIsUnmoved(_ inputPosition : Int, _ outputLength : Int, _ originalPosition : Int) -> Bool {
        return (inputPosition == originalPosition) && (inputPosition == outputLength)
    }
}