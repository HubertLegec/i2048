
import UIKit

class ScoreView : UIView {
    let defaultFrame = CGRect(x: 0, y: 0, width: 150, height: 40)
    var label : UILabel
    var score : Int {
        didSet {
            label.text = "Score: \(score)"
        }
    }
    
    init() {
        label = UILabel(frame: defaultFrame)
        label.textAlignment = NSTextAlignment.center
        score = 0
        super.init(frame: defaultFrame)
        backgroundColor = UIColor.darkGray
        label.textColor = UIColor.white
        label.font = UIFont(name: "HelveticaNeue", size: 16.0)
        layer.cornerRadius = 6.0
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
