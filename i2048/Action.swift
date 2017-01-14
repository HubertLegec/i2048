//
//  Action.swift
//  i2048
//
//  Created by Hubert Legęć on 12.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

import Foundation

enum Action {
    case noAction(source : Int, value : Int)
    case move(source : Int, value : Int)
    case singleCombine(source : Int, value : Int)
    case doubleCombine(source1 : Int, source2 : Int, value: Int)
    
    func getValue() -> Int {
        switch self {
        case let .noAction(_, val) : return val
        case let .move(_, val) : return val
        case let .singleCombine(_, val) : return val
        case let .doubleCombine(_, _, val) : return val
        }
    }
    
    func getSource() -> Int {
        switch self {
        case let .noAction(source, _) : return source
        case let .move(source, _) : return source
        case let .singleCombine(source, _) : return source
        case let .doubleCombine(source, _, _) : return source
        }
    }
}
