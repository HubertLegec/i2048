//
//  TileView.swift
//  i2048
//
//  Created by Hubert Legęć on 19.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

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
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
}
