//
//  MovesInvoker.swift
//  XO-game
//
//  Created by Alexander Fomin on 18.04.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

class MovesInvoker {
    
    var firstPlayerCommands: [AddMarkCommand] = []
    var secondPlayerCommands: [AddMarkCommand] = []
    var firstPlayerTurn: Bool = true
    
    func addCommand(_ command: AddMarkCommand) {
        switch command.player {
        case .first:
            self.firstPlayerCommands.append(command)
        case .second:
            self.secondPlayerCommands.append(command)
        case .ai:
            break
        }
     }
    
    func executeCommands(completion: @escaping () -> ()) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if self.firstPlayerTurn {
                self.firstPlayerCommands.removeFirst().execute()
                self.firstPlayerTurn.toggle()
            } else {
                self.secondPlayerCommands.removeFirst().execute()
                self.firstPlayerTurn.toggle()
            }
            
            if self.secondPlayerCommands.isEmpty || self.secondPlayerCommands.isEmpty {
                timer.invalidate()
                completion()
            }
        }
    }
}
