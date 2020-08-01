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


class MenuCoordinator: MenuCoordinating, MainMenuDelegate, OptionsSceneDelegate {
    
    
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
            mainMenuScene.mainMenuDelegate = self

            view.presentScene(mainMenuScene)
            view.ignoresSiblingOrder = true

        }
    }
    
    func newGame(_ difficulty: Difficulty, _ playerModel: EntityModel?, level: LevelType) {
        levelCoordinator.startGame(profile: profile!)
    }
    
    func levelSelect(_ updatedPlayerData: EntityModel) {
    }
    
    func optionsSelected() {
        if let scene = GKScene(fileNamed: Identifiers.optionsScene)?.rootNode as? OptionsScene {
            scene.scaleMode = .aspectFill
            scene.myDelegate = self
            let transition = SKTransition.push(with: .left, duration: 0.5)
            view.presentScene(scene, transition: transition)
            view.ignoresSiblingOrder = true

        }
    }
    
    func backSelected() {
        if let mainMenuScene = GKScene(fileNamed: Identifiers.mainMenuScene)?.rootNode as? MainMenu {
            mainMenuScene.scaleMode = .aspectFill
            mainMenuScene.playerModel = profile!.player
            mainMenuScene.mainMenuDelegate = self
            
            let transition = SKTransition.push(with: .right, duration: 0.5)
            
            view.presentScene(mainMenuScene, transition: transition)
            view.ignoresSiblingOrder = true

        }
    }

}
