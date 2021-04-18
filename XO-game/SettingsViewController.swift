//
//  SettingsViewController.swift
//  XO-game
//
//  Created by Alexander Fomin on 17.04.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import UIKit

enum GameMode: Int {
    case inTurn, inBlind, vsAI
}

class SettingsViewController: UIViewController {
    
    @IBOutlet var gameModeSwitchers: [UISwitch]!
    
    @IBAction func onGameModeSwitch(_ sender: UISwitch) {
        gameModeSwitchers.forEach {
            if $0.tag != sender.tag {
                $0.isOn = false
            }
        }
        if gameModeSwitchers[0].isOn {
            Game.shared.mode = .vsAI
        }
        if gameModeSwitchers[1].isOn {
            Game.shared.mode = .inBlind
        }
        if !gameModeSwitchers[0].isOn, !gameModeSwitchers[1].isOn {
            Game.shared.mode = .inTurn
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch Game.shared.mode {
        case .inTurn:
            gameModeSwitchers[0].isOn = false
            gameModeSwitchers[1].isOn = false
        case .inBlind:
            gameModeSwitchers[0].isOn = false
            gameModeSwitchers[1].isOn = true
        case .vsAI:
            gameModeSwitchers[0].isOn = true
            gameModeSwitchers[1].isOn = false
        }
    }
}
