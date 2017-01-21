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
    
    func addTile(_ position: (Int, Int), value: Int) {
        let (row, col) = position
        let x = calculateTilePosition(col)
        let y = calculateTilePosition(row)
        let tile = TileView(position: CGPoint(x: x, y: y), size: tileWidth, value: value, radius: cornerRadius)
        tile.layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
        
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
        let (fromRow, fromCol) = from
        let (toRow, toCol) = to
        let fromKey = IndexPath(row: fromRow, section: fromCol)
        let toKey = IndexPath(row: toRow, section: toCol)
        
        guard let tile = tiles[fromKey] else {
            assert(false, "get tile from key error")
        }
        
        var finalFrame = tile.frame
        finalFrame.origin.x = calculateTilePosition(toCol)
        finalFrame.origin.y = calculateTilePosition(toRow)
        
        tiles.removeValue(forKey: fromKey)
        tiles[toKey] = tile
        
        tile.frame = finalFrame
        tile.value = value
    }
    
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        let (fromRow1, fromCol1) = from.0
        let (fromRow2, fromCol2) = from.1
        let (toRow, toCol) = to
        let fromKey1 = IndexPath(row: fromRow1, section: fromCol1)
        let fromKey2 = IndexPath(row: fromRow2, section: fromCol2)
        let toKey = IndexPath(row: toRow, section: toCol)
        
        guard let tile1 = tiles[fromKey1] else {
            assert(false, "get tile from key error")
        }
        
        guard let tile2 = tiles[fromKey2] else {
            assert(false, "get tile from key error")
        }
        
        var finalFrame = tile1.frame
        let oldTile = tiles[toKey]
        oldTile?.removeFromSuperview()
        finalFrame.origin.x = calculateTilePosition(toCol)
        finalFrame.origin.y = calculateTilePosition(toRow)
        tiles.removeValue(forKey: fromKey1)
        tiles.removeValue(forKey: fromKey2)
        tiles[toKey] = tile1
        tile1.frame = finalFrame
        tile2.frame = finalFrame
        tile1.value = value
        tile2.removeFromSuperview()
    }
    
    func calculateTilePosition(_ idx: Int) -> CGFloat {
        return tilePadding + CGFloat(idx) * (tileWidth + tilePadding)
    }
    
}
