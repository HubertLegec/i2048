
import UIKit

class ResetButton : UIButton {
    
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        backgroundColor = UIColor.darkGray
        setTitle("Reset", for: .normal)
        layer.cornerRadius = 6.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        super.addTarget(target, action: action, for: controlEvents)
    }
}
