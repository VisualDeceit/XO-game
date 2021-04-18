//
//  GameViewController.swift
//  XO-game
//
//  Created by Evgeny Kireev on 25/02/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet var gameboardView: GameboardView!
    @IBOutlet var firstPlayerTurnLabel: UILabel!
    @IBOutlet var secondPlayerTurnLabel: UILabel!
    @IBOutlet var winnerLabel: UILabel!
    @IBOutlet var restartButton: UIButton!
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        gameboard.clear()
        gameboardView.clear()
        self.goToFirstState()
    }

    private let gameboard = Gameboard()
    private lazy var referee = Referee(gameboard: self.gameboard)
    private var currentState: GameState! {
        didSet {
            self.currentState.begin()
        }
    }
    
    let movesInvoker = MovesInvoker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goToFirstState()
        gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            self.currentState.addMark(at: position)
            
            if self.currentState.isCompleted {
                self.gameboard.clear()
                self.gameboardView.clear()
                self.goToNextState()
            }
        }
    }
    
    private func goToFirstState() {
//        self.currentState = PlayerInputState(player: .first,
//                                             gameViewController: self,
//                                             gameboard: gameboard,
//                                             gameboardView: gameboardView)
        self.currentState = PlayerBlindInputState(player: .first,
                                                  gameViewController: self,
                                                  gameboard: gameboard,
                                                  gameboardView: gameboardView,
                                                  invoker: movesInvoker, completion: nil)
    }

    private func goToNextState() {
//        let winner = self.referee.determineWinner()
//        if winner != nil || self.gameboard.isFull() {
//            self.currentState = GameEndedState(winner: winner, gameViewController: self)
//            return
//        }
        
        if let playerInputState = currentState as? PlayerBlindInputState {
            self.currentState = PlayerBlindInputState(player: playerInputState.player.next,
                                                      gameViewController: self,
                                                      gameboard: gameboard,
                                                      gameboardView: gameboardView,
                                                      invoker: movesInvoker,
                                                      completion: { [weak self] in
                                                        self?.gameboard.clear()
                                                        self?.gameboardView.clear()
                                                        self?.goToFinalState()
                                                      })
        
//        if !Game.shared.gameVsAI {
//            if let playerInputState = currentState as? PlayerInputState {
//                self.currentState = PlayerInputState(player: playerInputState.player.next,
//                                                     gameViewController: self,
//                                                     gameboard: gameboard,
//                                                     gameboardView: gameboardView)
//            }
//        } else {
//            if let playerInputState = currentState as? PlayerInputState,
//               playerInputState.player == .ai {
//                self.currentState = PlayerInputState(player: .first,
//                                                     gameViewController: self,
//                                                     gameboard: gameboard,
//                                                     gameboardView: gameboardView)
//            } else {
//                self.currentState = AIinputState(player: .ai,
//                                                 gameViewController: self,
//                                                 gameboard: gameboard,
//                                                 gameboardView: gameboardView,
//                                                 callback: { self.goToNextState() })
//            }
        }
    }
    
    private func goToFinalState() {
        let completionBlock = { [weak self] in
              if let self = self {
                  let winner = self.referee.determineWinner()
                  if winner != nil || self.gameboard.isFull() {
                      self.currentState = GameEndedState(winner: winner, gameViewController: self)
                  }
              }
        }
        
        self.currentState = BlindModeExecuteState(gameViewController: self,
                                                  invoker: movesInvoker,
                                                  completion: completionBlock)
    }
}

