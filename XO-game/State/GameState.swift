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
    
    var isCompleted: Bool = false
    
    let player: Player
    weak var gameViewController: GameViewController?
    weak var gameboard: Gameboard?
    weak var gameboardView: GameboardView?
    
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
            self.gameViewController?.secondPlayerTurnLabel.text = "2nd player"
        default:
            break
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
        case .second, .ai:
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
    
    public init(winner: Player?, gameViewController: GameViewController?) {
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
        case .ai: return "AI"
        }
    }
}

class AIinputState: PlayerInputState {
    
    private var completion: () -> ()
    
    init(player: Player, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView, completion: @escaping () -> ()) {
        self.completion = completion
        super.init(player: player, gameViewController: gameViewController, gameboard: gameboard, gameboardView: gameboardView)
    }
    
    override func begin() {
        self.gameViewController?.firstPlayerTurnLabel.isHidden = true
        self.gameViewController?.secondPlayerTurnLabel.isHidden = false
        self.gameViewController?.secondPlayerTurnLabel.text = "AI"
        self.gameViewController?.winnerLabel.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.move()
        }
    }
    
    override func addMark(at position: GameboardPosition) {}
    
    private func move() {
        let markView: MarkView = OView()
        if let position = generateRandomPostion() {
            self.gameboard?.setPlayer(self.player, at: position)
            self.gameboardView?.placeMarkView(markView, at: position)
            self.completion()
        }
    }

    func generateRandomPostion() -> GameboardPosition? {
        guard let gameboardView = self.gameboardView else { return nil }
        var row = Int.random(in: 0...2)
        var col = Int.random(in: 0...2)
        var position = GameboardPosition(column: col, row: row)
        while !gameboardView.canPlaceMarkView(at: position) {
            row = Int.random(in: 0...2)
            col = Int.random(in: 0...2)
            position = GameboardPosition(column: col, row: row)
        }
        return position
    }
}

class PlayerBlindInputState: GameState {
    var isCompleted: Bool = false
    let maxMovesCount = 5
    var movesCount = 0
    
    let player: Player
    weak var gameViewController: GameViewController?
    weak var gameboard: Gameboard?
    weak var gameboardView: GameboardView?
    weak var invoker: MovesInvoker?
    
    private var completion: (() -> ())?
    
    init(player: Player, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView, invoker: MovesInvoker, completion: (() -> ())? = nil) {
        self.player = player
        self.gameViewController = gameViewController
        self.gameboard = gameboard
        self.gameboardView = gameboardView
        self.invoker = invoker
        self.completion = completion
    }
    
    func begin() {
        switch self.player {
        case .first:
            self.gameViewController?.firstPlayerTurnLabel.isHidden = false
            self.gameViewController?.secondPlayerTurnLabel.isHidden = true
        case .second:
            self.gameViewController?.firstPlayerTurnLabel.isHidden = true
            self.gameViewController?.secondPlayerTurnLabel.isHidden = false
            self.gameViewController?.secondPlayerTurnLabel.text = "2nd player"
        default:
            break
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
        case .second, .ai:
            markView = OView()
        }
        
        let command = AddMarkCommand(player: player,
                                     gameViewController: gameViewController,
                                     position: position,
                                     gameboard: gameboard,
                                     gameboardView: gameboardView,
                                     markView: markView)
        invoker?.addCommand(command)
        
        self.gameboard?.setPlayer(self.player, at: position)
        self.gameboardView?.placeMarkView(markView, at: position)
       
        movesCount += 1
        if movesCount == maxMovesCount {
            if player == .first {
                self.isCompleted = true
                self.gameboard?.clear()
                self.gameboardView?.clear()
            } else {
                completion!()
            }
        }
    }
}

class BlindModeExecuteState: GameState {
    var isCompleted: Bool = false
    
    weak var gameViewController: GameViewController?
    weak var invoker: MovesInvoker?
    
    private var completion: () -> ()
    
    init(gameViewController: GameViewController, invoker: MovesInvoker, completion: @escaping () -> ()) {
        self.gameViewController = gameViewController
        self.invoker = invoker
        self.completion = completion
    }
    
    func begin() {
        invoker?.executeCommands { [weak self] in
          self?.completion()
        }
    }
    
    func addMark(at position: GameboardPosition) {}
}

