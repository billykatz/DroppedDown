//
//  MainMenuCoordinator.swift
//  DownFall
//
//  Created by Katz, Billy on 7/24/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit
import GameplayKit

protocol MenuCoordinating: class {
    var levelCoordinator: LevelCoordinating { get }
    
    func levelSelect(_ updatedPlayerData: EntityModel)
    func newGame(profile: Profile)
}


class MenuCoordinator: MenuCoordinating {
    
    var profile: Profile?
    var levelCoordinator: LevelCoordinating
    
    init(levelCoordinator: LevelCoordinating) {
        self.levelCoordinator = levelCoordinator
    }
    
    func newGame(profile: Profile) {
        self.profile = profile
        levelCoordinator.startGame(profile: profile)
    }
    
    func levelSelect(_ updatedPlayerData: EntityModel) {
        
//        if let mainMenuScene = GKScene(fileNamed: Identifiers.mainMenuScene)?.rootNode as? MainMenu {
//            mainMenuScene.scaleMode = .aspectFill
//            mainMenuScene.playerModel = updatedPlayerData
//
//            if let view = self.view as! SKView? {
//                view.presentScene(mainMenuScene)
//                view.ignoresSiblingOrder = true
//            }
//
//        }
    }

}
