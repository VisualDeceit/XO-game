//
//  GameState.swift
//  XO-game
//
//  Created by Alexander Fomin on 17.04.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

protocol GameState {
    
    var isCompleted: Bool { get }
    func begin()
    func addMark(at position: GameboardPosition)
}

class PlayerInputState: GameState {
    
    public private(set) var isCompleted: Bool = false
    
    public let player: Player
    private(set) weak var gameViewController: GameViewController?
    private(set) weak var gameboard: Gameboard?
    private(set) weak var gameboardView: GameboardView?
    
    init(player: Player, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView) {
        self.player = player
        self.gameViewController = gameViewController
        self.gameboard = gameboard
        self.gameboardView = gameboardView
    }
    
    func begin() {
        switch self.player {
        case .first:
            self.gameViewController?.firstPlayerTurnLabel.isHidden = false
            self.gameViewController?.secondPlayerTurnLabel.isHidden = true
        case .second:
            self.gameViewController?.firstPlayerTurnLabel.isHidden = true
            self.gameViewController?.secondPlayerTurnLabel.isHidden = false
        }
        self.gameViewController?.winnerLabel.isHidden = true
    }
    
    func addMark(at position: GameboardPosition) {
        guard let gameboardView = self.gameboardView,
              gameboardView.canPlaceMarkView(at: position)
        else { return }
        
        let markView: MarkView
        switch self.player {
        case .first:
            markView = XView()
        case .second:
            markView = OView()
        }
        
        self.gameboard?.setPlayer(self.player, at: position)
        self.gameboardView?.placeMarkView(markView, at: position)
        self.isCompleted = true
    }
}

class GameEndedState: GameState {
    
    public let isCompleted = false
    
    public let winner: Player?
    private(set) weak var gameViewController: GameViewController?
    
    public init(winner: Player?, gameViewController: GameViewController) {
        self.winner = winner
        self.gameViewController = gameViewController
    }
    
    public func begin() {
        self.gameViewController?.winnerLabel.isHidden = false
        if let winner = winner {
            self.gameViewController?.winnerLabel.text = self.winnerName(from: winner) + " win"
        } else {
            self.gameViewController?.winnerLabel.text = "No winner"
        }
        self.gameViewController?.firstPlayerTurnLabel.isHidden = true
        self.gameViewController?.secondPlayerTurnLabel.isHidden = true
    }
    
    public func addMark(at position: GameboardPosition) { }
    
    private func winnerName(from winner: Player) -> String {
        switch winner {
        case .first: return "1st player"
        case .second: return "2nd player"
        }
    }
}
