//
//  Tile.swift
//  i2048
//
//  Created by Hubert Legęć on 11.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

import Foundation


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
