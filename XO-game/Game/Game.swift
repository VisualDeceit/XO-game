//
//  Game.swift
//  XO-game
//
//  Created by Alexander Fomin on 17.04.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

class Game {
    static var shared = Game()
    
    var mode: GameMode = .inTurn
    
    private init() {}
}
