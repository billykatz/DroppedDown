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

protocol MenuCoordinating: AnyObject {
    var levelCoordinator: LevelCoordinating { get }
    
    func finishGame(playerData updatedPlayerData: EntityModel, currentRun: RunModel)
    func loadedProfile(_ profile: Profile)
    
    /// exposed so that we can save the profile
    var profile: Profile? { get }
}


class MenuCoordinator: MenuCoordinating, MainMenuDelegate, OptionsSceneDelegate, MenuStoreSceneDelegate {
    
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
        scene.optionsDelegate = self
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
        mainMenu.hasRunToContinue = profile?.currentRun != nil

        view.presentScene(mainMenu, transition: transition)
        view.ignoresSiblingOrder = true

    }
    
    func loadedProfile(_ profile: Profile) {
        self.profile = profile
        
        presentMainMenu()
    }
    
    func newGame(_ playerModel: EntityModel?) {
        profile?.currentRun = nil
        levelCoordinator.loadRun(nil, profile: profile!)
    }
    
    func continueRun() {
        levelCoordinator.loadRun(profile!.currentRun, profile: profile!)
    }
    
    func finishGame(playerData updatedPlayerData: EntityModel, currentRun: RunModel) {
        /// update the profile to show
        /// the player's gems
        guard let profile = profile else { fatalError("We need a profile to continue") }
        let currentRun: RunModel? = updatedPlayerData.isDead ? nil : currentRun
        /// update run
        let profileWithCurrentRun = profile.updateRunModel(currentRun)
        /// update player gem carry
        let playerUpdated = profileWithCurrentRun.player.updateCarry(carry: updatedPlayerData.carry).update(pickaxe: updatedPlayerData.pickaxe)
        
        
        /// update profile with new player
        let profileWithUpdatedPlayer = profileWithCurrentRun.updatePlayer(playerUpdated)
        
        //update profile with current depth
        self.profile = profileWithUpdatedPlayer.updateDepth(currentRun?.depth ?? 0)
        
        GameScope.shared.profileManager.saveProfile(self.profile!)
        
        presentMainMenu(transition: SKTransition.fade(withDuration: 0.2))
        
    }
    
    func optionsSelected() {
        view.presentScene(optionsScene, transition: SKTransition.push(with: .left, duration: 0.5))
    }
    
    func backSelected() {
        presentMainMenu(transition: SKTransition.push(with: .right, duration: 0.5))
    }
    
    func addRandomRune() {
        profile?.givePlayerARandomRune()
    }
    
    func menuStore() {
        guard let profile = profile else { return }
        let storeScene = MenuStoreScene(size: .universalSize,
                                        playerData: profile.player,
                                        coordinatorDelegate: self)
        
        storeScene.scaleMode = .aspectFill
        view.presentScene(storeScene, transition: SKTransition.push(with: .right, duration: 0.5))
    }
    
    func mainMenuTapped(updatedPlayerData: EntityModel) {
        guard let profile = profile else { return }
        self.profile = profile.updatePlayer(updatedPlayerData)
        GameScope.shared.profileManager.saveProfile(self.profile!)
        presentMainMenu(transition: SKTransition.push(with: .left, duration: 0.5))
    }

}
