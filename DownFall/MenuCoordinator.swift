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
//        mainMenu.hasRunToContinue = allowContinueRun && (profileViewModel?.profile.currentRun != nil && profileViewModel?.profile.currentRun != .zero)
        mainMenu.displayStoreBadge = profileViewModel?.playerHasPurchasableUnlockables() ?? false
        if allowContinueRun && (profileViewModel?.profile.currentRun != nil && profileViewModel?.profile.currentRun != .zero) {
            mainMenu.runToContinue = profileViewModel?.profile.currentRun
        } else {
            mainMenu.runToContinue = nil
        }

        view.presentScene(mainMenu, transition: transition)
        view.ignoresSiblingOrder = true
        
        MenuMusicManager.shared.gameIsPlaying = false
        MenuMusicManager.shared.playBackgroundMusic()

    }
    
    func abandonRun() {
        //TODO implement
        profileViewModel?.abandonRun(playerData: profileViewModel!.profile.player, currentRun: profileViewModel!.profile.currentRun!)
    }
    
    func loadedProfile(_ profile: Profile, hasLaunchedBefore: Bool) {
        self.profileViewModel = ProfileViewModel(profile: profile)
        levelCoordinator.profileViewModel = profileViewModel
        if hasLaunchedBefore {
            presentMainMenu()
        } else {
            // This springs us into the tutorial
            newGame(profileViewModel?.profile.player)
        }
    }
    
    func newGame(_ playerModel: EntityModel?) {
        profileViewModel?.nilCurrenRun()
        playerTappedOnStore = false
        levelCoordinator.loadRun(nil, profile: profileViewModel!.profile)
        MenuMusicManager.shared.gameIsPlaying = true
    }
    
    func continueRun() {
        playerTappedOnStore = false
        levelCoordinator.loadRun(profileViewModel!.profile.currentRun, profile: profileViewModel!.profile)
        MenuMusicManager.shared.gameIsPlaying = true
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
    
    func statsViewSelected() {
        guard let profileViewModel = profileViewModel else { preconditionFailure() }
        settingsCoordinator.presentSettingsView(profileViewModel: profileViewModel)
    }
    
    func optionsSelected() {
        
    }
    
    func addRandomRune() {
        profileViewModel?.givePlayerARandomRune()
    }
    
    func menuStore() {
        guard let profileViewModel = profileViewModel else { preconditionFailure() }
        playerTappedOnStore = true
        codexCoordinator.presentCodexView(profileViewModel: profileViewModel)
    }
    
    func goToTestScene() {
        // GKScene(fileNamed: "LoadingScene")!.rootNode as? LoadingScene
        if let scene = GKScene(fileNamed: "BossTestScene")!.rootNode as? BossTestScene {
            scene.scaleMode = .aspectFill
            scene.commonInit()
            view.presentScene(scene)

        }
    }
}
