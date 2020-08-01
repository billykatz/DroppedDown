//
//  MainMenuCoordinator.swift
//  DownFall
//
//  Created by Katz, Billy on 7/24/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit
import GameplayKit

extension SKView {
    func presentScene(_ scene: SKScene?, transition: SKTransition?) {
        if let scene = scene, let transition = transition {
            presentScene(scene, transition: transition)
        } else {
            presentScene(scene)
        }
    }
    
}

protocol MenuCoordinating: class {
    var levelCoordinator: LevelCoordinating { get }
    
    func finishGame(playerData updatedPlayerData: EntityModel)
    func loadedProfile(_ profile: Profile)
}


class MenuCoordinator: MenuCoordinating, MainMenuDelegate, OptionsSceneDelegate {
    
    
    var view: SKView
    var profile: Profile?
    var levelCoordinator: LevelCoordinating
    
    private lazy var mainMenuScene: MainMenu? = {
        guard let scene = GKScene(fileNamed: Identifiers.mainMenuScene)?.rootNode as? MainMenu else { return nil }
        scene.mainMenuDelegate = self
        scene.scaleMode = .aspectFill
        return scene
    }()
    
    private lazy var optionsScene: OptionsScene? = {
        guard let scene = GKScene(fileNamed: Identifiers.optionsScene)?.rootNode as? OptionsScene else { return nil }
        scene.myDelegate = self
        scene.scaleMode = .aspectFill
        return scene
    }()
    
    init(levelCoordinator: LevelCoordinating, view: SKView) {
        self.levelCoordinator = levelCoordinator
        self.view = view
    }
    
    private func presentMainMenu(transition: SKTransition? = nil) {
        guard let mainMenu = mainMenuScene else { fatalError("Unable to unwrap the main menu scene")}
        mainMenu.playerModel = profile?.player

        view.presentScene(mainMenu, transition: transition)
        view.ignoresSiblingOrder = true

    }
    
    func loadedProfile(_ profile: Profile) {
        self.profile = profile
        
        presentMainMenu()
    }
    
    func newGame(_ difficulty: Difficulty, _ playerModel: EntityModel?, level: LevelType) {
        levelCoordinator.startGame(profile: profile!)
    }
    
    func finishGame(playerData updatedPlayerData: EntityModel) {
        /// update the profile to show
        /// the player's gems
        guard let profile = profile else { fatalError("We need a profile to continue") }
        let profileUpdateWithGems = profile.player.updateCarry(carry: updatedPlayerData.carry)
        self.profile = profile.updatePlayer(profileUpdateWithGems)
        presentMainMenu(transition: SKTransition.fade(withDuration: 0.2))
        
    }
    
    func optionsSelected() {
        view.presentScene(optionsScene, transition: SKTransition.push(with: .left, duration: 0.5))
    }
    
    func backSelected() {
        presentMainMenu(transition: SKTransition.push(with: .right, duration: 0.5))
    }

}
