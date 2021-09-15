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
    var profile: Profile? {
        profileViewModel?.profile
    }
    var levelCoordinator: LevelCoordinating
    var codexCoordinator: CodexCoordinator
    var settingsCoordinator: SettingsCoordinator
    var profileViewModel: ProfileViewModel?
    
    
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
    
    init(levelCoordinator: LevelCoordinating, codexCoordinator: CodexCoordinator, settingsCoordinator: SettingsCoordinator, view: SKView) {
        self.levelCoordinator = levelCoordinator
        self.codexCoordinator = codexCoordinator
        self.settingsCoordinator = settingsCoordinator
        self.view = view
    }
    
    private func presentMainMenu(transition: SKTransition? = nil) {
        guard let mainMenu = mainMenuScene else { fatalError("Unable to unwrap the main menu scene")}
        mainMenu.playerModel = profile?.player
        mainMenu.hasRunToContinue = (profile?.currentRun != nil && profile?.currentRun != .zero)

        view.presentScene(mainMenu, transition: transition)
        view.ignoresSiblingOrder = true

    }
    
    func loadedProfile(_ profile: Profile) {
        self.profileViewModel = ProfileViewModel(profile: profile)
        
        presentMainMenu()
    }
    
    func newGame(_ playerModel: EntityModel?) {
        profileViewModel?.nilCurrenRun()
        levelCoordinator.loadRun(nil, profile: profile!)
    }
    
    func continueRun() {
        levelCoordinator.loadRun(profile!.currentRun, profile: profile!)
    }
    
    func finishGame(playerData updatedPlayerData: EntityModel, currentRun: RunModel) {
        profileViewModel?.finishRun(playerData: updatedPlayerData, currentRun: currentRun)
        presentMainMenu(transition: SKTransition.fade(withDuration: 0.2))
        
    }
    
    func optionsSelected() {
        guard let profileViewModel = profileViewModel else { preconditionFailure() }
        settingsCoordinator.presentSettingsView(profileViewModel: profileViewModel)
//        view.presentScene(optionsScene, transition: SKTransition.push(with: .left, duration: 0.5))
    }
    
    func backSelected() {
        presentMainMenu(transition: SKTransition.push(with: .right, duration: 0.5))
    }
    
    func addRandomRune() {
        profileViewModel?.givePlayerARandomRune()
    }
    
    func menuStore() {
        guard let profileViewModel = profileViewModel else { preconditionFailure() }
        codexCoordinator.presentCodexView(profileViewModel: profileViewModel)
    }
    
    func mainMenuTapped(updatedPlayerData: EntityModel) {
        profileViewModel?.updatePlayerData(updatedPlayerData)
        presentMainMenu(transition: SKTransition.push(with: .left, duration: 0.5))
    }

}
