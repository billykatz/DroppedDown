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
    func finishGameAfterGameLose(playerData updatedPlayerData: EntityModel, currentRun: RunModel)
    func loadedProfile(_ profile: Profile, hasLaunchedBefore: Bool)
    
    /// exposed so that we can save the profile
//    var profile: Profile? { get }
}


class MenuCoordinator: MenuCoordinating, MainMenuDelegate {
    
    var view: SKView
    var levelCoordinator: LevelCoordinating
    var codexCoordinator: CodexCoordinator
    var creditsCoordinator: CreditsCoordinator
    var settingsCoordinator: SettingsCoordinator
    var profileViewModel: ProfileViewModel?
    var tutorialConductor: TutorialConductor?
    var gameMusicManager: GameMusicManager
    
    private lazy var mainMenuScene: MainMenu? = {
        guard let scene = GKScene(fileNamed: Identifiers.mainMenuScene)?.rootNode as? MainMenu else { return nil }
        scene.mainMenuDelegate = self
        scene.scaleMode = .aspectFill
        return scene
    }()
    
    init(levelCoordinator: LevelCoordinating, codexCoordinator: CodexCoordinator, settingsCoordinator: SettingsCoordinator, tutorialConductor: TutorialConductor, creditsCoordinator: CreditsCoordinator, gameMusicManager: GameMusicManager, view: SKView) {
        self.levelCoordinator = levelCoordinator
        self.codexCoordinator = codexCoordinator
        self.settingsCoordinator = settingsCoordinator
        self.tutorialConductor = tutorialConductor
        self.creditsCoordinator = creditsCoordinator
        self.gameMusicManager = gameMusicManager
        self.view = view
    }
    
    private func presentMainMenu(transition: SKTransition? = nil, allowContinueRun: Bool = true) {
        guard let mainMenu = mainMenuScene else { fatalError("Unable to unwrap the main menu scene") }
        mainMenu.playerModel = profileViewModel?.profile.player
        
        if allowContinueRun && (profileViewModel?.profile.currentRun != nil && profileViewModel?.profile.currentRun != .zero) {
            if let seed = profileViewModel?.profile.currentRun?.seed,
               let profile = profileViewModel?.profile,
               !profile.pastRunSeeds.contains(seed)
            {
                mainMenu.runToContinue = profileViewModel?.profile.currentRun
            } else {
                mainMenu.runToContinue = nil
            }
            
        } else {
            mainMenu.runToContinue = nil
        }

        view.presentScene(mainMenu, transition: transition)
        view.ignoresSiblingOrder = true

    }
    
    func abandonRun() {
        profileViewModel?.abandonRun(playerData: profileViewModel!.profile.player, currentRun: profileViewModel!.profile.currentRun!)
    }
    
    func loadedProfile(_ profile: Profile, hasLaunchedBefore: Bool) {
        self.profileViewModel = ProfileViewModel(profile: profile)
        levelCoordinator.profileViewModel = profileViewModel
        if hasLaunchedBefore {
            gameMusicManager.isInMainMenu = true
            presentMainMenu()
        } else {
            // This springs us into the tutorial
            profileViewModel?.nilCurrenRun()
            levelCoordinator.loadRun(nil, profile: profileViewModel!.profile)
            gameMusicManager.isInMainMenu = false
        }
    }
    
    func newGame(_ playerModel: EntityModel?) {
        profileViewModel?.nilCurrenRun()
        codexCoordinator.presentCodexView(profileViewModel: profileViewModel!) { [weak self] in
            // start run callback, turn off main menu music
            self?.gameMusicManager.isInMainMenu = false 
        }
    }
    
    func continueRun() {
        levelCoordinator.loadRun(profileViewModel!.profile.currentRun, profile: profileViewModel!.profile)
        gameMusicManager.isInMainMenu = false
    }
    
    /// Updates and saves the player data based on the current run
    /// Optionally directly navigates to the store (soon will be removed)
    func finishGameAfterGameLose(playerData updatedPlayerData: EntityModel, currentRun: RunModel) {
        profileViewModel?.finishRun(playerData: updatedPlayerData, currentRun: currentRun)
    }
    
    /// Updates and saves the player data based on the current run
    /// Optionally directly navigates to the store (soon will be removed)
    func finishGame(playerData updatedPlayerData: EntityModel, currentRun: RunModel) {
        profileViewModel?.finishRun(playerData: updatedPlayerData, currentRun: currentRun)
        presentMainMenu(transition: SKTransition.fade(withDuration: 0.2), allowContinueRun: false)
        gameMusicManager.isInMainMenu = true
    }
    
    func statsViewSelected() {
        guard let profileViewModel = profileViewModel else { preconditionFailure("Profile view model needed to view stats") }
        settingsCoordinator.presentSettingsView(profileViewModel: profileViewModel)
    }
    
    func optionsSelected() {
        
    }
    
    func addRandomRune() {
        profileViewModel?.givePlayerARandomRune()
    }
    
    func goToTestScene() {
        #if DEBUG
        if let scene = GKScene(fileNamed: "BossTestScene")!.rootNode as? BossTestScene {
            scene.scaleMode = .aspectFill
            scene.commonInit()
            view.presentScene(scene)

        }
        #endif
    }
    
    func setUpPowerupScreenshot() {
        profileViewModel?.setUpPowerUpScreenShot()
    }
    
    func goToCredits() {
        creditsCoordinator.presentCredits()
    }
}
