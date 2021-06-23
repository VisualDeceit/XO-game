//
//  AddMarkCommand.swift
//  XO-game
//
//  Created by Alexander Fomin on 18.04.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

protocol Command {
    func execute()
}

class AddMarkCommand: Command {
    
    var player: Player
    var position: GameboardPosition
    let markView: MarkView
    
    weak var gameboard: Gameboard?
    weak var gameboardView: GameboardView?
    weak var gameViewController: GameViewController?
    
    init(player: Player, gameViewController: GameViewController?, position: GameboardPosition, gameboard: Gameboard?, gameboardView: GameboardView?, markView: MarkView) {
        self.player = player
        self.gameViewController = gameViewController
        self.position = position
        self.gameboard = gameboard
        self.gameboardView = gameboardView
        self.markView = markView
    }
    
    func execute() {
        switch self.player {
        case .first:
            self.gameViewController?.firstPlayerTurnLabel.isHidden = false
            self.gameViewController?.secondPlayerTurnLabel.isHidden = true
        case .second:
            self.gameViewController?.firstPlayerTurnLabel.isHidden = true
            self.gameViewController?.secondPlayerTurnLabel.isHidden = false
        default:
            break
        }
        
        self.gameboard?.setPlayer(self.player, at: self.position)
        self.gameboardView?.removeMarkView(at: position)
        self.gameboardView?.placeMarkView(self.markView, at: position)
    }
}
