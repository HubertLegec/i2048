import UIKit

class BoardView : UIView {
    var size: Int
    var tileSize: CGFloat
    var tilePadding: CGFloat
    var cornerRadius: CGFloat = 6.0
    var tiles: Dictionary<IndexPath, TileView>
    
    init(size s: Int, tileSize ts: CGFloat, tilePadding padding: CGFloat) {
        size = s
        tileSize = ts
        tilePadding = padding
        tiles = Dictionary()
        let sideLength = padding + CGFloat(size)*(ts + padding)
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
                drawTileBackground(xPos: xCursor, yPos: yCursor)
                yCursor += tilePadding + tileSize
            }
            xCursor += tilePadding + tileSize
        }
    }
    
    func drawTileBackground(xPos x: CGFloat, yPos y: CGFloat) {
        let background = UIView(frame: CGRect(x: x, y: y, width: tileSize, height: tileSize))
        background.layer.cornerRadius = cornerRadius - 2
        background.backgroundColor = UIColor.lightGray
        addSubview(background)
    }
    
    func insertTile(_ pos: (Int, Int), value: Int) {
        let (row, col) = pos
        let x = positionFromIndex(col)
        let y = positionFromIndex(row)
        let tile = TileView(position: CGPoint(x: x, y: y), size: tileSize, value: value, radius: cornerRadius - 2)
        tile.layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
        
        addSubview(tile)
        bringSubview(toFront: tile)
        tiles[tupleToIndexPath(pos)] = tile
        
        UIView.animate(withDuration: 0.15, delay: 0.05,
                       options: UIViewAnimationOptions(),
                       animations: { tile.layer.setAffineTransform(CGAffineTransform(scaleX: 1.1, y: 1.1)) },
                       completion: { finished in
                        UIView.animate(withDuration: 0.1, animations: { () -> Void in tile.layer.setAffineTransform(CGAffineTransform.identity) })}
        )
    }
    
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int) {
        let (toRow, toCol) = to
        let toKey = IndexPath(row: toRow, section: toCol)
        let tile = processOneTile(from)
        let endTile = tiles[toKey]
        let finalFrame = createFinalFrame(to, tile)
        tiles[toKey] = tile
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: UIViewAnimationOptions.beginFromCurrentState,
                       animations: { tile.frame = finalFrame },
                       completion: { (finished: Bool) -> Void in
                        tile.value = value
                        endTile?.removeFromSuperview() }
        )
    }
    
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        let (toRow, toCol) = to
        let toKey = IndexPath(row: toRow, section: toCol)
        let tile1 = processOneTile(from.0)
        let tile2 = processOneTile(from.1)
        let finalFrame = createFinalFrame(to, tile1)
        let oldTile = tiles[toKey]
        oldTile?.removeFromSuperview()
        tiles[toKey] = tile1
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState,
                       animations: {
                        tile1.frame = finalFrame
                        tile2.frame = finalFrame },
                       completion: { finished in
                        tile1.value = value
                        tile2.removeFromSuperview() }
        )
    }
    
    func createFinalFrame(_ to : (Int, Int), _ tile : TileView) -> CGRect {
        let (toRow, toCol) = to
        var finalFrame = tile.frame
        finalFrame.origin.x = positionFromIndex(toCol)
        finalFrame.origin.y = positionFromIndex(toRow)
        return finalFrame
    }
    
    func processOneTile(_ tuple : (Int, Int)) -> TileView {
        let key1 = tupleToIndexPath(tuple)
        let tile1 = tiles[key1]
        tiles.removeValue(forKey: key1)
        return tile1!
    }
    
    func positionFromIndex(_ idx : Int) -> CGFloat {
        return tilePadding + CGFloat(idx)*(tileSize + tilePadding)
    }
    
    func tupleToIndexPath(_ tuple : (Int, Int)) -> IndexPath {
        let (x, y) = tuple
        return IndexPath(row: x, section: y)
    }
}
