//
//  Gameboard.swift
//  i2048
//
//  Created by Hubert Legęć on 11.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

import Foundation


class Gameboard {
    let size : Int
    var board : [Tile]
    
    init(size s : Int, initialValue : Tile) {
        size = s
        board = [Tile](repeating: initialValue, count : s*s)
    }
    
    subscript(row : Int, column : Int) -> Tile {
        get {
            assert(row >= 0 && row < size)
            assert(column >= 0 && column < size)
            return board[row * size + column]
        }
        set {
            assert(row >= 0 && row < size)
            assert(column >= 0 && column < size)
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
    
    func hasNeighboursWithSameValues() -> Bool {
        for i in 0 ..< size {
            for j in 0 ..< size {
                if (tileBelowHasSameValue((i , j)) || tileToRightHasSameValue((i, j))) {
                    return true
                }
            }
        }
        return false
    }
    
    private func tileBelowHasSameValue(_ location : (Int, Int)) -> Bool {
        let (x, y) = location
        guard y != size - 1 else {
            return false
        }
        if case let .tile(v) = self[x, y+1] {
            return v == self[x, y].get()
        }
        return false
    }
    
    private func tileToRightHasSameValue(_ location : (Int, Int)) -> Bool {
        let (x, y) = location
        guard x != size - 1 else {
            return false
        }
        if case let .tile(v) = self[x+1, y] {
            return v == self[x, y].get()
        }
        return false
    }
}
