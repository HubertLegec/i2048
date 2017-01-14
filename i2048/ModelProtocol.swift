//
//  ModelProtocol.swift
//  i2048
//
//  Created by Hubert Legęć on 11.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

import Foundation

protocol GameProtocol : class {
    func scoreChanged(_ score : Int)
    func addTile(_ position : (Int, Int), value : Int)
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
}
