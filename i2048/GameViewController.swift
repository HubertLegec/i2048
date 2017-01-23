
import UIKit

class GameViewController : UIViewController {
    var size: Int
    var model: GameModel?
    var board: BoardView?
    var scoreView: ScoreView?
    let viewPadding: CGFloat = 10.0
    
    var boardWidth: CGFloat?
    
    init(size s : Int) {
        self.size = s
        super.init(nibName: nil, bundle: nil)
        model = GameModel(size: s, delegate: self)
        view.backgroundColor = UIColor.white
        setupSwipes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boardWidth = view.bounds.size.width - 2 * viewPadding
        setupGame()
    }
    
    //metoda wywoływana po załadowaniu widoku, dodaje elementy do sceny i ustawia ich pozycje
    func setupGame() {
        let score = ScoreView()
        
        let padding: CGFloat = 6.0
        let v1 = boardWidth! - padding*(CGFloat(size + 1))
        let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(size)
        let gameboard = BoardView(size: size, tileSize: width, tilePadding: padding)
        
        let button = ResetButton()
        button.addTarget(self, action: #selector(handleReset(sender:)), for: .touchUpInside)
        
        let views = [score, gameboard, button]
        adjustViewPosition(gameboard, views: views, idx: 1)
        adjustViewPosition(score, views: views, idx: 0)
        adjustViewPosition(button, views: views, idx: 2)
        board = gameboard
        scoreView = score
        scoreChanged(0)
        
        model!.insertTileAtRandomLocation(2)
        model!.insertTileAtRandomLocation(2)
    }
    
    //metoda ustawiająca pozycję elementu na ekranie, tak aby wszystkie były wyśrodkowane
    func adjustViewPosition(_ view : UIView, views v : [UIView], idx index : Int) {
        var f = view.frame
        f.origin.x = xPositionToCenterView(view)
        f.origin.y = yPositionForViewAtPos(index, v)
        view.frame  = f
        self.view.addSubview(view)
    }
    
    //metoda wyśrodkowująca element horyzontalnie
    func xPositionToCenterView(_ v : UIView) -> CGFloat {
        let screenWidth = view.bounds.size.width
        let viewWidth = v.bounds.size.width
        let deltaWidth = 0.5 * (screenWidth - viewWidth)
        return deltaWidth > 0 ? deltaWidth : 0
    }
    
    //metoda ustawia pozycję wertykalną elementu, tak aby nie nachodził na żadne pozostałe oraz żeby wszystkie były wyśrodkowane
    func yPositionForViewAtPos(_ pos : Int, _ views : [UIView]) -> CGFloat {
        let screenHeight = view.bounds.size.height
        let totalHeight = CGFloat(views.count - 1) * viewPadding + views.map({ $0.bounds.size.height }).reduce(0.0, { $0 + $1 })
        let deltaHeight = 0.5 * (screenHeight - totalHeight)
        let viewsTop = deltaHeight >= 0 ? deltaHeight : 0
        var acc: CGFloat = 0
        for i in 0 ..< pos {
            acc += viewPadding + views[i].bounds.size.height
        }
        return viewsTop + acc
    }
    
    //dodanie hadlera do obsługi gestów przesuwania po ekranie
    func setupSwipes() {
        let directions: [UISwipeGestureRecognizerDirection] = [.up, .down, .left, .right]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
    }
    
    //obługa zdarzenia przesuwania palcem po ekranie w różnych kierunkach
    @objc(handleSwipe:)
    func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        self.model!.addMoveToQueue(sender.direction, completion: { (changed: Bool) -> () in
        if changed {
            let userWon = self.model!.won()
            if userWon {
                let alert = UIAlertController(title: "Success", message: "You won!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            let randVal = Int(arc4random_uniform(10))
            self.model!.insertTileAtRandomLocation(randVal == 1 ? 4 : 2)
            
            if self.model!.lost() {
                let alert = UIAlertController(title: "Game Over", message: "You lost...", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        })
    }
    
    //obsługa naciśnięcia przycisku restartu gry
    @objc(handleReset:)
    func handleReset(sender : UIButton!) {
        board!.reset()
        model!.reset()
        scoreView!.score = 0
        model!.insertTileAtRandomLocation(2)
        model!.insertTileAtRandomLocation(2)
    }
    
    func scoreChanged(_ score: Int) {
        scoreView!.score = score
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
