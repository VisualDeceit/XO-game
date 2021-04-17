//
//  SettingsViewController.swift
//  XO-game
//
//  Created by Alexander Fomin on 17.04.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import UIKit

enum GameMode: Int {
    case inTurn, inBlind
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var gameWithAiSwitcher: UISwitch!
    @IBOutlet weak var blindGameModeSwitcher: UISwitch!
    
    @IBAction func onGameWithAiSwitch(_ sender: UISwitch) {
        Game.shared.gameVsAI = sender.isOn
    }
    
    @IBAction func onBlindGameModeSwitch(_ sender: UISwitch) {
        Game.shared.mode = sender.isOn ? .inBlind : .inTurn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameWithAiSwitcher.isOn = Game.shared.gameVsAI
        
        if Game.shared.mode == .inBlind {
            blindGameModeSwitcher.isOn = true
        } else {
            blindGameModeSwitcher.isOn = false
        }
    }
}
