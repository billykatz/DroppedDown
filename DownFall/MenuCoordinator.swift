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
    
    func finishGameAndGoToStore(playerData updatedPlayerData: EntityModel, currentRun: RunModel)
    func finishGame(playerData updatedPlayerData: EntityModel, currentRun: RunModel)
    func loadedProfile(_ profile: Profile, hasLaunchedBefore: Bool)
    
    /// exposed so that we can save the profile
//    var profile: Profile? { get }
}


class MenuCoordinator: MenuCoordinating, MainMenuDelegate {
    
    var view: SKView
    var levelCoordinator: LevelCoordinating
    var codexCoordinator: CodexCoordinator
    var settingsCoordinator: SettingsCoordinator
    var profileViewModel: ProfileViewModel?
    var tutorialConductor: TutorialConductor?
    
    // hack for now, remove later
    var playerTappedOnStore: Bool = false
    
    private lazy var mainMenuScene: MainMenu? = {
        guard let scene = GKScene(fileNamed: Identifiers.mainMenuScene)?.rootNode as? MainMenu else { return nil }
        scene.mainMenuDelegate = self
        scene.scaleMode = .aspectFill
        return scene
    }()
    
    init(levelCoordinator: LevelCoordinating, codexCoordinator: CodexCoordinator, settingsCoordinator: SettingsCoordinator, tutorialConductor: TutorialConductor, view: SKView) {
        self.levelCoordinator = levelCoordinator
        self.codexCoordinator = codexCoordinator
        self.settingsCoordinator = settingsCoordinator
        self.tutorialConductor = tutorialConductor
        self.view = view
    }
    
    func viewWillAppear() {
        if playerTappedOnStore {
            mainMenuScene?.removeStoreBadge()
        }
    }
    
    private func presentMainMenu(transition: SKTransition? = nil, allowContinueRun: Bool = true) {
        guard let mainMenu = mainMenuScene else { fatalError("Unable to unwrap the main menu scene")}
        mainMenu.playerModel = profileViewModel?.profile.player
        mainMenu.hasRunToContinue = allowContinueRun && (profileViewModel?.profile.currentRun != nil && profileViewModel?.profile.currentRun != .zero)
        mainMenu.displayStoreBadge = profileViewModel?.playerHasPurchasableUnlockables() ?? false

        view.presentScene(mainMenu, transition: transition)
        view.ignoresSiblingOrder = true

    }
    
    func abandonRun() {
        //TODO implement
        profileViewModel?.abandonRun(playerData: profileViewModel!.profile.player, currentRun: profileViewModel!.profile.currentRun!)
    }
    
    func loadedProfile(_ profile: Profile, hasLaunchedBefore: Bool) {
        self.profileViewModel = ProfileViewModel(profile: profile)
        if hasLaunchedBefore {
            presentMainMenu()
        } else {
            newGame(profileViewModel?.profile.player)
        }
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
        presentMainMenu(transition: SKTransition.fade(withDuration: 0.2), allowContinueRun: false)
    }
    
    func finishGameAndGoToStore(playerData updatedPlayerData: EntityModel, currentRun: RunModel) {
        profileViewModel?.finishRun(playerData: updatedPlayerData, currentRun: currentRun)
        presentMainMenu(transition: nil, allowContinueRun: false)
        menuStore()
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
}
