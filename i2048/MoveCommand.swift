//
//  MoveCommand.swift
//  i2048
//
//  Created by Hubert Legęć on 11.01.2017.
//  Copyright © 2017 Hubert Legęć. All rights reserved.
//

import Foundation

struct MoveCommand {
    let direction : MoveDirection
    let completion : (Bool) -> ()
}