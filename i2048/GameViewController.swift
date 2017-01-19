//
//  GameViewController.swift
//  i2048
//
//  Created by Hubert Legęć on 19.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

import UIKit
import Foundation

class GameViewController : UIViewController, GameProtocol {
    
    var size : Int
    var threshold : Int
    
    var model : GameModel?
    var board : BoardView?
    
    init(size s : Int, threshold t : Int) {
        super.init(nibName: nil, bundle: nil)
        size = s
        threshold = t
        model = GameModel(size: s, threshold: t, delegate: self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func scoreChanged(_ score: Int) {
        <#code#>
    }
    
    func addTile(_ position: (Int, Int), value: Int) {
        <#code#>
    }
    
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int) {
        
    }
    
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        <#code#>
    }
    
}
