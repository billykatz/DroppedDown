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
//    var profile: Profile? { get }
}


class MenuCoordinator: MenuCoordinating, MainMenuDelegate {
    
    var view: SKView
    var levelCoordinator: LevelCoordinating
    var codexCoordinator: CodexCoordinator
    var settingsCoordinator: SettingsCoordinator
    var profileViewModel: ProfileViewModel?
    
    // hack for now, remove later
    var playerTappedOnStore: Bool = false
    
    private lazy var mainMenuScene: MainMenu? = {
        guard let scene = GKScene(fileNamed: Identifiers.mainMenuScene)?.rootNode as? MainMenu else { return nil }
        scene.mainMenuDelegate = self
        scene.scaleMode = .aspectFill
        return scene
    }()
    
    init(levelCoordinator: LevelCoordinating, codexCoordinator: CodexCoordinator, settingsCoordinator: SettingsCoordinator, view: SKView) {
        self.levelCoordinator = levelCoordinator
        self.codexCoordinator = codexCoordinator
        self.settingsCoordinator = settingsCoordinator
        self.view = view
    }
    
    func viewWillAppear() {
        if playerTappedOnStore {
            mainMenuScene?.removeStoreBadge()
        }
    }
    
    private func presentMainMenu(transition: SKTransition? = nil) {
        guard let mainMenu = mainMenuScene else { fatalError("Unable to unwrap the main menu scene")}
        mainMenu.playerModel = profileViewModel?.profile.player
        mainMenu.hasRunToContinue = (profileViewModel?.profile.currentRun != nil && profileViewModel?.profile.currentRun != .zero)
        mainMenu.displayStoreBadge = profileViewModel?.playerHasPurchasableUnlockables() ?? false

        view.presentScene(mainMenu, transition: transition)
        view.ignoresSiblingOrder = true

    }
    
    func loadedProfile(_ profile: Profile) {
        self.profileViewModel = ProfileViewModel(profile: profile)
        presentMainMenu()
    }
    
    func newGame(_ playerModel: EntityModel?) {
        profileViewModel?.nilCurrenRun()
        playerTappedOnStore = false
        levelCoordinator.loadRun(nil, profile: profileViewModel!.profile)
    }
    
    func continueRun() {
        playerTappedOnStore = false
        levelCoordinator.loadRun(profileViewModel!.profile.currentRun, profile: profileViewModel!.profile)
    }
    
    func finishGame(playerData updatedPlayerData: EntityModel, currentRun: RunModel) {
        profileViewModel?.finishRun(playerData: updatedPlayerData, currentRun: currentRun)
        presentMainMenu(transition: SKTransition.fade(withDuration: 0.2))
    }
    
    func optionsSelected() {
        guard let profileViewModel = profileViewModel else { preconditionFailure() }
        settingsCoordinator.presentSettingsView(profileViewModel: profileViewModel)
    }
    
    func addRandomRune() {
        profileViewModel?.givePlayerARandomRune()
    }
    
    func menuStore() {
        guard let profileViewModel = profileViewModel else { preconditionFailure() }
        playerTappedOnStore = true
        codexCoordinator.presentCodexView(profileViewModel: profileViewModel)
    }
    
    func mainMenuTapped(updatedPlayerData: EntityModel) {
        profileViewModel?.updatePlayerData(updatedPlayerData)
        presentMainMenu(transition: SKTransition.push(with: .left, duration: 0.5))
    }

}
