//
//  BoardView.swift
//  i2048
//
//  Created by Hubert Legęć on 19.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

import UIKit

class BoardView : UIView {
    var size : Int
    var tileWidth : CGFloat
    var tilePadding : CGFloat
    var cornerRadius : CGFloat
    var tiles : Dictionary<IndexPath, TileView>
    
    let tilePopStartScale: CGFloat = 0.1
    
    init(size s: Int, tileWidth w: CGFloat, tilePadding p: CGFloat, cornerRadius r: CGFloat) {
        size = s
        tileWidth = w
        tilePadding = p
        cornerRadius = r
        tiles = Dictionary()
        let sideLength = p + CGFloat(size) * (w + p)
        super.init(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
        layer.cornerRadius = r
        createBackground()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func createBackground() {
        backgroundColor = UIColor.init(red: 153, green: 96, blue: 21, alpha: 1)
        var xCursor = tilePadding
        var yCursor: CGFloat
        let bgRadius = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        for _ in 0 ..< size {
            yCursor = tilePadding
            for _ in 0 ..< size {
                // Draw each tile
                let background = UIView(frame: CGRect(x: xCursor, y: yCursor, width: tileWidth, height: tileWidth))
                background.layer.cornerRadius = bgRadius
                background.backgroundColor = UIColor.gray
                addSubview(background)
                yCursor += tilePadding + tileWidth
            }
            xCursor += tilePadding + tileWidth
        }
    }
    
    func reset() {
        for (_, tile) in tiles {
            tile.removeFromSuperview()
        }
        tiles.removeAll(keepingCapacity: true)
    }
    
    func add_tile(_ position: (Int, Int), value: Int) {
        let (row, col) = position
        let x = tilePadding + CGFloat(col) * (tileWidth + tilePadding)
        let y = tilePadding + CGFloat(row) * (tileWidth + tilePadding)
        let tile = TileView(position: CGPoint(x: x, y: y), size: tileWidth, value: value, radius: cornerRadius)
        tile.layer.setAffineTransform(CGAffineTransform(scaleX: tilePopStartScale, y: tilePopStartScale))
        
        addSubview(tile)
        bringSubview(toFront: tile)
        tiles[IndexPath(row: row, section: col)] = tile
        
        UIView.animate(withDuration: 0.2, delay: 0.05, options: UIViewAnimationOptions(),
            animations: {
                tile.layer.setAffineTransform(CGAffineTransform(scaleX: 1.1, y: 1.1))
            },
            completion: { finished in
                UIView.animate(withDuration: 0.08, animations: { () -> Void in
                    tile.layer.setAffineTransform(CGAffineTransform.identity)
                })
        })
    }
    
    func moveOneTile(_ from : (Int, Int), to: (Int, Int), value: Int) {
        
    }
    
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        
    }
    
}
