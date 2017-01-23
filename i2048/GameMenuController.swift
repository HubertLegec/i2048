//
//  GameViewController.swift
//  i2048
//
//  Created by Hubert Legęć on 10.12.2016.
//  Copyright © 2016 Hubert Legęć. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameMenuController: UIViewController {
    
    @IBOutlet weak var boardSizeSelector: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        boardSizeSelector.selectedSegmentIndex = 1
    }

    override var shouldAutorotate: Bool {
        return true
    }

    @IBAction func startGameTapped(_ sender: Any) {
        let game = GameViewController(size: boardSizeSelector.selectedSegmentIndex + 3)
        self.present(game, animated: true, completion: nil)
    }
    
}
