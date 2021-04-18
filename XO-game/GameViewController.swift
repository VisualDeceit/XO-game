//
//  GameViewController.swift
//  XO-game
//
//  Created by Evgeny Kireev on 25/02/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    let movesInvoker = MovesInvoker()
    var gameMode: GameMode = .inTurn
    var gameModeStrategy: GameModeStrategy!

    private let gameboard = Gameboard()
    private lazy var referee = Referee(gameboard: self.gameboard)
    private var currentState: GameState! {
        didSet {
            self.currentState.begin()
        }
    }
    
    @IBOutlet var gameboardView: GameboardView!
    @IBOutlet var firstPlayerTurnLabel: UILabel!
    @IBOutlet var secondPlayerTurnLabel: UILabel!
    @IBOutlet var winnerLabel: UILabel!
    @IBOutlet var restartButton: UIButton!
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        restart()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SettingsViewController {
            controller.gameMode = self.gameMode
            controller.onSelectSettings = { [weak self] gameMode in
                self?.gameMode = gameMode
                self?.selectGameMode()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectGameMode()
        
        gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            self.currentState.addMark(at: position)
            
            if self.currentState.isCompleted {
                self.goToNextState()
            }
        }
    }
    
    func selectGameMode() {
        switch gameMode {
        case .inTurn:
            gameModeStrategy = InTurnGameModeStrategy(referee: referee, gameViewController: self, gameboard: gameboard, gameboardView: gameboardView)
        case .inBlind:
            gameModeStrategy = InBlindGameModeStrategy(referee: referee, gameViewController: self, gameboard: gameboard, gameboardView: gameboardView, invoker: movesInvoker)
        case .vsAI:
            gameModeStrategy = vsAIGameModeStrategy(referee: referee, gameViewController: self, gameboard: gameboard, gameboardView: gameboardView)
        }
        restart()
    }
    
    func restart() {
        gameboard.clear()
        gameboardView.clear()
        goToFirstState()
    }
    
    func goToFirstState() {
        self.currentState = gameModeStrategy.firstState()
    }

     func goToNextState() {
        if let endState = gameModeStrategy.endState() {
            self.currentState = endState
            return
        }
        self.currentState = gameModeStrategy.nextState()
    }
    
    /// эту функцию так и не смог перенести в GameModeStrategy из-за return GameEndedState в замыкании =(
    func goToFinalState() {
        let completionBlock = { [weak self] in
            if let self = self {
                let winner = self.referee.determineWinner()
                    self.currentState = GameEndedState(winner: winner, gameViewController: self)
            }
        }
        
        self.currentState = BlindModeExecuteState(gameViewController: self,
                                                  invoker: movesInvoker,
                                                  completion: completionBlock)
    }
}

