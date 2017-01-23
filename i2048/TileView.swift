
import UIKit

class TileView : UIView {
    
    var value : Int = 0 {
        didSet {
            backgroundColor = TileAppearance.backgroundColor(value)
            label.textColor = TileAppearance.numberColor(value)
            label.text = "\(value)"
        }
    }
    let label : UILabel
    
    init(position: CGPoint, size: CGFloat, value: Int, radius: CGFloat) {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: size, height: size))
        label.textAlignment = NSTextAlignment.center
        label.minimumScaleFactor = 0.5
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        super.init(frame: CGRect(x: position.x, y: position.y, width: size, height: size))
        addSubview(label)
        layer.cornerRadius = radius
        self.value = value
        backgroundColor = TileAppearance.backgroundColor(value)
        label.textColor = TileAppearance.numberColor(value)
        label.text = "\(value)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
