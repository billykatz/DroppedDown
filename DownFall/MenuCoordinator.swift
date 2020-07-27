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
    func loadedProfile(_ profile: Profile)
}


class MenuCoordinator: MenuCoordinating {
    
    var view: SKView
    var profile: Profile?
    var levelCoordinator: LevelCoordinating
    
    init(levelCoordinator: LevelCoordinating, view: SKView) {
        self.levelCoordinator = levelCoordinator
        self.view = view
    }
    
    func loadedProfile(_ profile: Profile) {
        self.profile = profile
        
        if let mainMenuScene = GKScene(fileNamed: Identifiers.mainMenuScene)?.rootNode as? MainMenu {
            mainMenuScene.scaleMode = .aspectFill
            mainMenuScene.playerModel = profile.player

            view.presentScene(mainMenuScene)
            view.ignoresSiblingOrder = true

        }
    }
    
    func levelSelect(_ updatedPlayerData: EntityModel) {
    }

}
