import UIKit

class BoardView : UIView {
    var size: Int
    var tileWidth: CGFloat
    var tilePadding: CGFloat
    var cornerRadius: CGFloat = 6.0
    var tiles: Dictionary<IndexPath, TileView>
    
    init(size s: Int, tileWidth width: CGFloat, tilePadding padding: CGFloat) {
        size = s
        tileWidth = width
        tilePadding = padding
        tiles = Dictionary()
        let sideLength = padding + CGFloat(size)*(width + padding)
        super.init(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
        layer.cornerRadius = cornerRadius
        setupBackground()
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func reset() {
        for (_, tile) in tiles {
            tile.removeFromSuperview()
        }
        tiles.removeAll(keepingCapacity: true)
    }
    
    func setupBackground() {
        backgroundColor = UIColor.darkGray
        var xCursor = tilePadding
        var yCursor: CGFloat
        for _ in 0 ..< size {
            yCursor = tilePadding
            for _ in 0 ..< size {
                let background = UIView(frame: CGRect(x: xCursor, y: yCursor, width: tileWidth, height: tileWidth))
                background.layer.cornerRadius = cornerRadius - 2
                background.backgroundColor = UIColor.lightGray
                addSubview(background)
                yCursor += tilePadding + tileWidth
            }
            xCursor += tilePadding + tileWidth
        }
    }
    
    func insertTile(_ pos: (Int, Int), value: Int) {
        let (row, col) = pos
        let x = positionFromIndex(col)
        let y = positionFromIndex(row)
        let tile = TileView(position: CGPoint(x: x, y: y), size: tileWidth, value: value, radius: cornerRadius - 2)
        tile.layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
        
        addSubview(tile)
        bringSubview(toFront: tile)
        tiles[IndexPath(row: row, section: col)] = tile
        
        UIView.animate(withDuration: 0.15, delay: 0.05, options: UIViewAnimationOptions(),
                       animations: {
                        tile.layer.setAffineTransform(CGAffineTransform(scaleX: 1.1, y: 1.1))
        },
                       completion: { finished in
                        UIView.animate(withDuration: 0.1, animations: { () -> Void in
                            tile.layer.setAffineTransform(CGAffineTransform.identity)
                        })
        })
    }
    
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int) {
        let (toRow, toCol) = to
        let fromKey = tupleToIndexPath(from)
        let toKey = IndexPath(row: toRow, section: toCol)
        
        guard let tile = tiles[fromKey] else {
            assert(false, "placeholder error")
        }
        let endTile = tiles[toKey]
        
        var finalFrame = tile.frame
        finalFrame.origin.x = positionFromIndex(toCol)
        finalFrame.origin.y = positionFromIndex(toRow)
        
        tiles.removeValue(forKey: fromKey)
        tiles[toKey] = tile
        
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: UIViewAnimationOptions.beginFromCurrentState,
                       animations: {
                        tile.frame = finalFrame
        },
                       completion: { (finished: Bool) -> Void in
                        tile.value = value
                        endTile?.removeFromSuperview()
        })
    }
    
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        let (toRow, toCol) = to
        let key1 = tupleToIndexPath(from.0)
        let key2 = tupleToIndexPath(from.1)
        let toKey = IndexPath(row: toRow, section: toCol)
        
        guard let tile1 = tiles[key1] else {
            assert(false, "placeholder error")
        }
        guard let tile2 = tiles[key2] else {
            assert(false, "placeholder error")
        }
        
        var finalFrame = tile1.frame
        finalFrame.origin.x = positionFromIndex(toCol)
        finalFrame.origin.y = positionFromIndex(toRow)
        
        let oldTile = tiles[toKey]
        oldTile?.removeFromSuperview()
        tiles.removeValue(forKey: key1)
        tiles.removeValue(forKey: key2)
        tiles[toKey] = tile1
        
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: UIViewAnimationOptions.beginFromCurrentState,
                       animations: {
                        tile1.frame = finalFrame
                        tile2.frame = finalFrame },
                       completion: { finished in
                        tile1.value = value
                        tile2.removeFromSuperview()
        })
    }
    
    func positionFromIndex(_ idx : Int) -> CGFloat {
        return tilePadding + CGFloat(idx)*(tileWidth + tilePadding)
    }
    
    func tupleToIndexPath(_ tuple : (Int, Int)) -> IndexPath {
        let (x, y) = tuple
        return IndexPath(row: x, section: y)
    }
}
