
import UIKit

class GameViewController : UIViewController {
    var size: Int
    var threshold: Int
    var model: GameModel?
    var board: BoardView?
    let viewPadding: CGFloat = 10.0
    
    var boardWidth: CGFloat?
    
    init(size s : Int, threshold tr : Int) {
        self.size = s
        self.threshold = tr
        super.init(nibName: nil, bundle: nil)
        model = GameModel(size: s, threshold: tr, delegate: self)
        view.backgroundColor = UIColor.white
        setupSwipes()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boardWidth = view.bounds.size.width - 2 * viewPadding
        setupGame()
    }
    
    func reset() {
        board!.reset()
        model!.reset()
        model!.insertTileAtRandomLocation(2)
        model!.insertTileAtRandomLocation(2)
    }
    
    func setupGame() {
        let padding: CGFloat = 6.0
        let v1 = boardWidth! - padding*(CGFloat(size + 1))
        let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(size)
        let gameboard = BoardView(size: size, tileWidth: width, tilePadding: padding)
        
        let views = [gameboard]
        
        var f = gameboard.frame
        f.origin.x = xPositionToCenterView(gameboard)
        f.origin.y = yPositionForViewAtPos(0, views)
        gameboard.frame = f
        
        view.addSubview(gameboard)
        board = gameboard
        
        model!.insertTileAtRandomLocation(2)
        model!.insertTileAtRandomLocation(2)
    }
    
    func xPositionToCenterView(_ v : UIView) -> CGFloat {
        let screenWidth = view.bounds.size.width
        let viewWidth = v.bounds.size.width
        return 0.5 * (screenWidth - viewWidth) > 0 ? 0.5 * (screenWidth - viewWidth) : 0
    }
    
    func yPositionForViewAtPos(_ pos : Int, _ views : [UIView]) -> CGFloat {
        let screenHeight = view.bounds.size.height
        let totalHeight = CGFloat(views.count - 1) * viewPadding + views.map({ $0.bounds.size.height }).reduce(0.0, { $0 + $1 })
        let viewsTop = 0.5*(screenHeight - totalHeight) >= 0 ? 0.5*(screenHeight - totalHeight) : 0
        
        var acc: CGFloat = 0
        for i in 0 ..< pos {
            acc += viewPadding + views[i].bounds.size.height
        }
        return viewsTop + acc
    }
    
    func setupSwipes() {
        let directions: [UISwipeGestureRecognizerDirection] = [.up, .down, .left, .right]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
    }
    
    @objc(handleSwipe:)
    func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        self.model!.addMoveToQueue(sender.direction, completion: { (changed: Bool) -> () in
        if changed {
            let (userWon, _) = self.model!.won()
            if userWon {
                let alertView = UIAlertView()
                alertView.title = "Success"
                alertView.message = "You won!"
                alertView.addButton(withTitle: "Cancel")
                alertView.show()
            }
            
            let randVal = Int(arc4random_uniform(10))
            self.model!.insertTileAtRandomLocation(randVal == 1 ? 4 : 2)
            
            if self.model!.lost() {
                let alertView = UIAlertView()
                alertView.title = "Game Over"
                alertView.message = "You lost..."
                alertView.addButton(withTitle: "Cancel")
                alertView.show()
            }
        }
        })
    }
    
    func scoreChanged(_ score: Int) {
        //TODO
    }
    
    func addTile(_ position: (Int, Int), value: Int) {
        board!.insertTile(position, value: value)
    }
    
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int) {
        board?.moveOneTile(from, to: to, value: value)
    }
    
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        board?.moveTwoTiles(from, to : to, value: value)
    }
    
}
