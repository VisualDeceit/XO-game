//
//  GameModeStrategy.swift
//  XO-game
//
//  Created by Alexander Fomin on 17.04.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

protocol GameModeStrategy {
    func firstState() -> GameState?
    func nextState() -> GameState?
    func endState() -> GameState?
}

class InTurnGameModeStrategy: GameModeStrategy {
    
    var player: Player = .first
    weak var gameViewController: GameViewController?
    weak var gameboard: Gameboard?
    weak var gameboardView: GameboardView?
    weak var referee: Referee?
    
    init( referee: Referee, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView) {
        self.referee = referee
        self.gameViewController = gameViewController
        self.gameboard = gameboard
        self.gameboardView = gameboardView
    }
    
    func firstState() -> GameState? {
        guard let gameViewController = gameViewController,
              let gameboard = gameboard,
              let gameboardView = gameboardView else {
            return nil
        }
        player = .first
        return PlayerInputState(player: player,
                                gameViewController: gameViewController,
                                gameboard: gameboard,
                                gameboardView: gameboardView)
    }
    
    func nextState() -> GameState? {
        guard let gameViewController = gameViewController,
              let gameboard = gameboard,
              let gameboardView = gameboardView else {
            return nil
        }
        player = player.next
        return PlayerInputState(player: player,
                                gameViewController: gameViewController,
                                gameboard: gameboard,
                                gameboardView: gameboardView)
    }
    
    func endState() -> GameState? {
        guard let gameViewController = gameViewController,
              let gameboard = gameboard,
              let referee = referee else {
            return nil
        }
        
        let winner = referee.determineWinner()
        if winner != nil || gameboard.isFull() {
            return GameEndedState(winner: winner, gameViewController: gameViewController)
        }
        return nil
    }
}

class vsAIGameModeStrategy: GameModeStrategy {
    var player: Player = .first
    weak var gameViewController: GameViewController?
    weak var gameboard: Gameboard?
    weak var gameboardView: GameboardView?
    weak var referee: Referee?
    
    init( referee: Referee, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView) {
        self.referee = referee
        self.gameViewController = gameViewController
        self.gameboard = gameboard
        self.gameboardView = gameboardView
    }
    
    func firstState() -> GameState? {
        guard let gameViewController = gameViewController,
              let gameboard = gameboard,
              let gameboardView = gameboardView else {
            return nil
        }
        player = .first
        return PlayerInputState(player: player,
                                gameViewController: gameViewController,
                                gameboard: gameboard,
                                gameboardView: gameboardView)
    }
    
    func nextState() -> GameState? {
        guard let gameViewController = gameViewController,
              let gameboard = gameboard,
              let gameboardView = gameboardView else {
            return nil
        }
        
        if player == .ai {
            player = .first
            return PlayerInputState(player: .first,
                                    gameViewController: gameViewController,
                                    gameboard: gameboard,
                                    gameboardView: gameboardView)
        } else {
            player = .ai
            return AIinputState(player: .ai,
                                gameViewController: gameViewController,
                                gameboard: gameboard,
                                gameboardView: gameboardView,
                                completion: { gameViewController.goToNextState() })
        }
    }
    
    func endState() -> GameState? {
        guard let gameViewController = gameViewController,
              let gameboard = gameboard,
              let referee = referee else {
            return nil
        }
        let winner = referee.determineWinner()
        if winner != nil || gameboard.isFull() {
            return GameEndedState(winner: winner, gameViewController: gameViewController)
        }
        return nil
    }
}

class InBlindGameModeStrategy: GameModeStrategy {
    var player: Player = .first
    weak var gameViewController: GameViewController?
    weak var gameboard: Gameboard?
    weak var gameboardView: GameboardView?
    weak var referee: Referee?
    weak var invoker: MovesInvoker?
    
    init( referee: Referee, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView, invoker: MovesInvoker) {
        self.referee = referee
        self.gameViewController = gameViewController
        self.gameboard = gameboard
        self.gameboardView = gameboardView
        self.invoker = invoker
    }
    
    func firstState() -> GameState? {
        guard let gameViewController = gameViewController,
              let gameboard = gameboard,
              let gameboardView = gameboardView,
              let invoker = invoker else {
            return nil
        }
        player = .first
        return PlayerBlindInputState(player: .first,
                                     gameViewController: gameViewController,
                                     gameboard: gameboard,
                                     gameboardView: gameboardView,
                                     invoker: invoker)
    }
    
    func nextState() -> GameState? {
        guard let gameViewController = gameViewController,
              let gameboard = gameboard,
              let gameboardView = gameboardView,
              let invoker = invoker else {
            return nil
        }
        player = player.next
        return PlayerBlindInputState(player: player,
                                     gameViewController: gameViewController,
                                     gameboard: gameboard,
                                     gameboardView: gameboardView,
                                     invoker: invoker,
                                     completion: { [weak self] in
                                        self?.gameboard?.clear()
                                        self?.gameboardView?.clear()
                                        self?.gameViewController?.goToFinalState()
                                     })
    }
    
    func endState() -> GameState? {
            return nil
        }
}
