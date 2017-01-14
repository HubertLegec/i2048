//
//  Move.swift
//  i2048
//
//  Created by Hubert Legęć on 14.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

import Foundation

enum Move {
    case singleMove(source : Int, destination: Int, value: Int, wasMerged : Bool)
    case doubleMove(source1 : Int, source2 : Int, destination : Int, value: Int)
}
