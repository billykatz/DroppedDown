//
//  MainMenu.swift
//  DownFall
//
//  Created by William Katz on 6/30/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol MainMenuDelegate: AnyObject {
    func newGame(_ playerModel: EntityModel?)
    func statsViewSelected()
    func optionsSelected()
    func continueRun()
    func abandonRun()
    func goToTestScene()
}

class MainMenu: SKScene {
    
    struct Constants {
        static let buttonPadding = CGFloat(50.0)
        static let notificationName = "notificationRed"
        static let blankButtonName = "blankButton"
        static let soundIconName = "soundSprite"
        static let musicIconName = "musicSprite"
        static let toggleIconName = "toggleSprite"
        static let feedbackFormURLString = "https://linktr.ee/shiftshaft"
        
    }
    
    private var background: SKSpriteNode!
    private var buttonContainer: SKNode!
    
    private lazy var logo: SKSpriteNode = {
        let ratio: CGFloat = 60.0/210.0
        let width = self.size.playableRect.width*0.8
        let height = width * ratio
        let loadingSprite = SKSpriteNode(texture: SKTexture(imageNamed: "logo"), size: CGSize(width: width, height: height))
        loadingSprite.zPosition = Precedence.menu.rawValue
        loadingSprite.position = .zero
        
        return loadingSprite
    }()
    
    private var buttonFadeInAction: SKAction {
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        fadeIn.timingMode = .easeInEaseOut
        return fadeIn
    }
    
    
    weak var mainMenuDelegate: MainMenuDelegate?
    var playerModel: EntityModel?
    var hasRunToContinue: Bool?
    var runToContinue: RunModel?
    
    lazy var detectedSavedGameMenu: MenuSpriteNode = {
        let detectedSavedGame = MenuSpriteNode(.detectedSavedGame, playableRect: size.playableRect, precedence: .menu, level: nil, buttonDelegate: self)
        
        return detectedSavedGame
    }()
    
    lazy var confirmAbandonRun: MenuSpriteNode = {
        let confirmAbandonRun = MenuSpriteNode(.confirmation, playableRect: size.playableRect, precedence: .menu, level: nil, buttonDelegate: self)
        confirmAbandonRun.zPosition = 10_000_000
        return confirmAbandonRun
    }()
    
    lazy var detectedSavedTutorial: MenuSpriteNode = {
        let detectedSavedGame = MenuSpriteNode(.detectedSavedTutorial, playableRect: size.playableRect, precedence: .menu, level: nil, buttonDelegate: self)
        
        return detectedSavedGame
    }()
    
    lazy var confirmAbandonTutorial: MenuSpriteNode = {
        let confirmAbandonRun = MenuSpriteNode(.confirmAbandonTutorial, playableRect: size.playableRect, precedence: .menu, level: nil, buttonDelegate: self)
        confirmAbandonRun.zPosition = 10_000_000
        return confirmAbandonRun
    }()
    
    
    override func didMove(to view: SKView) {
        background = self.childNode(withName: "background") as? SKSpriteNode
        background.color = UIColor.backgroundGray
        self.removeAllChildren(exclude: ["background"])
        buttonContainer = SKNode()
        buttonContainer.position = .zero.translateVertically(-100)
        self.addChild(buttonContainer)
        
        
        let startButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .newGame, image: SKSpriteNode(imageNamed: Constants.blankButtonName), shape: .rectangle, addTextLabel: true)
        
        
        startButton.position = CGPoint.position(startButton.frame,
                                                inside: size.playableRect,
                                                verticalAlign: .center,
                                                horizontalAnchor: .center,
                                                yOffset: 200.0
        )
        startButton.zPosition = 0
        buttonContainer.addChild(startButton)
        
        startButton.alpha = 0
        startButton.run(buttonFadeInAction)
        
        logo.position = .position(logo.frame,
                                  inside: size.playableRect,
                                  verticalAlign: .top,
                                  horizontalAnchor: .center,
                                  yOffset: 150.0)
        logo.zPosition = 1_000_000_000_000
        addChild(logo)

        
        let statsViewButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .mainMenuStats, image: SKSpriteNode(imageNamed: Constants.blankButtonName), shape: .rectangle, addTextLabel: true)
        
        statsViewButton.position = CGPoint.alignHorizontally(statsViewButton.frame,
                                                             relativeTo: startButton.frame,
                                                             horizontalAnchor: .center,
                                                             verticalAlign: .bottom,
                                                             verticalPadding: Constants.buttonPadding,
                                                             translatedToBounds: true)
        statsViewButton.zPosition = 0
        
        buttonContainer.addChild(statsViewButton)
        statsViewButton.alpha = 0
        statsViewButton.run(buttonFadeInAction)
        
        
        /// Feedback button
        let feedbackButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .mainMenuFeedback, image: SKSpriteNode(imageNamed: Constants.blankButtonName), shape: .rectangle, addTextLabel: true)
        
        feedbackButton.position = CGPoint.alignHorizontally(statsViewButton.frame,
                                                            relativeTo: statsViewButton.frame,
                                                            horizontalAnchor: .center,
                                                            verticalAlign: .bottom,
                                                            verticalPadding: Constants.buttonPadding,
                                                            translatedToBounds: true)
        feedbackButton.zPosition = 0
        
        buttonContainer.addChild(feedbackButton)
        feedbackButton.alpha = 0
        feedbackButton.run(buttonFadeInAction)
        
        
        // animate the buttons to move slightly up
        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 0.30)
        moveUp.timingMode = .easeInEaseOut
        buttonContainer.run(moveUp)
        
        
        // Show the detected saved game UX
        if let run = runToContinue {
            if run.isTutorial &&
                run.areas.count < 2 {
                
                // only show the detected tutorial screen if the player has not chosen to skip the tutorialm
                if !UserDefaults.standard.bool(forKey: UserDefaults.hasSkippedTutorialKey) {
                    addChild(detectedSavedTutorial)
                    detectedSavedTutorial.zPosition = 10_000_000
                    detectedSavedTutorial.playMenuBounce()
                }
            } else {
                addChild(detectedSavedGameMenu)
                detectedSavedGameMenu.zPosition = 10_000_000
                detectedSavedGameMenu.playMenuBounce()
            }
        }
        
        let settingsTapTarget = SKSpriteNode(texture: nil, size: Style.HUD.settingsTapTargetSize)
        let setting = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.settings), color: .clear , size: Style.HUD.settingsSize)
        
        settingsTapTarget.name = Identifiers.settings
        settingsTapTarget.position = CGPoint.position(setting.frame,
                                                      inside: self.frame.size.playableRect,
                                                      verticalAlign: .top,
                                                      horizontalAnchor: .right,
                                                      xOffset: 80.0,
                                                      yOffset: 35.0
                                                      
        )
        settingsTapTarget.zPosition = 1_000_000
        settingsTapTarget.addChild(setting)
        
        self.addChild(settingsTapTarget)
        
        
        
        // show some FTUE if needed
        FTUEConductor().showFirstDeathDialog(playableRect: size.playableRect, in: self)
        
    }
    
    func removeStoreBadge() {
        self.removeChild(with: Constants.notificationName)
    }
    
    var soundOptions: MenuSpriteNode?
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let nodes = self.nodes(at: position)
        for node in nodes {
            if node.name == Identifiers.settings && soundOptions == nil {
                let menuSpriteNode = MenuSpriteNode(.options, playableRect: self.size.playableRect, precedence: .menu, level: nil, buttonDelegate: self)
                soundOptions = menuSpriteNode
                self.addChild(menuSpriteNode)
            }
        }
        if let overlay = soundOptions?.childNode(withName: "overlaySpriteName"),
           let containerView = soundOptions?.containerView,
           nodes.contains(overlay),
           !nodes.contains(containerView) {
            soundOptions?.removeFromParent()
            soundOptions = nil
        }
        
    }
    
}

extension MainMenu: ButtonDelegate {
    func buttonTapped(_ button: ShiftShaft_Button) {
        guard let playerModel = self.playerModel else { return }
        switch button.identifier {
        case .newGame:
            mainMenuDelegate?.newGame(playerModel.previewAppliedEffects().healFull())
            
        case .mainMenuStats:
            mainMenuDelegate?.statsViewSelected()
            
        case .mainMenuContinueRun:
            detectedSavedGameMenu.fadeOut { [mainMenuDelegate, detectedSavedGameMenu] in
                mainMenuDelegate?.continueRun()
                detectedSavedGameMenu.removeFromParent()
            }
            
        case .mainMenuContinueTutorial:
            detectedSavedTutorial.fadeOut { [mainMenuDelegate, detectedSavedTutorial] in
                mainMenuDelegate?.continueRun()
                detectedSavedTutorial.removeFromParent()
            }
            
            
        case .mainMenuAbandonRun:
            detectedSavedGameMenu.fadeOut { [weak self, confirmAbandonRun, detectedSavedGameMenu] in
                self?.addChild(confirmAbandonRun)
                confirmAbandonRun.playMenuBounce()
                detectedSavedGameMenu.removeFromParent()
            }
            
        case .mainMenuAbandonTutorial:
            detectedSavedTutorial.fadeOut { [weak self, confirmAbandonTutorial, detectedSavedTutorial] in
                self?.addChild(confirmAbandonTutorial)
                confirmAbandonTutorial.playMenuBounce()
                detectedSavedTutorial.removeFromParent()
            }
            
        case .yesAbandonRun:
            confirmAbandonRun.fadeOut { [mainMenuDelegate, confirmAbandonRun] in
                mainMenuDelegate?.abandonRun()
                confirmAbandonRun.removeFromParent()
            }
            
        case .yesSkipTutorial:
            confirmAbandonTutorial.fadeOut { [confirmAbandonTutorial, mainMenuDelegate] in
                UserDefaults.standard.setValue(true, forKey: UserDefaults.hasSkippedTutorialKey)
                UserDefaults.standard.setValue(false, forKey: UserDefaults.shouldShowCompletedTutorialKey)
                mainMenuDelegate?.abandonRun()
                confirmAbandonTutorial.removeFromParent()
            }
            
            
        case .doNotAbandonRun:
            confirmAbandonRun.fadeOut { [weak self, confirmAbandonRun, detectedSavedGameMenu] in
                self?.addChild(detectedSavedGameMenu)
                detectedSavedGameMenu.playMenuBounce()
                confirmAbandonRun.removeFromParent()
            }
            
        case .doNotAbandonTutorial:
            confirmAbandonTutorial.fadeOut { [weak self, confirmAbandonTutorial, detectedSavedTutorial] in
                self?.addChild(detectedSavedTutorial)
                detectedSavedTutorial.playMenuBounce()
                confirmAbandonTutorial.removeFromParent()
            }
            
        case .mainMenuFeedback:
#if DEBUG
            mainMenuDelegate?.goToTestScene()
#else
            let url = URL(string: Constants.feedbackFormURLString)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
#endif
            
            /// SOUND STUFF
            /// Yes, some of it is copied and pasted from MenuSpriteNode
        case .soundOptionsBack:
            soundOptions?.removeFromParent()
            soundOptions = nil
            
        case .toggleMusic:
            let muted = UserDefaults.standard.bool(forKey: UserDefaults.muteMusicKey)
            UserDefaults.standard.setValue(!muted, forKey: UserDefaults.muteMusicKey)
            
            guard let musicIcon = soundOptions?.containerView?.childNode(withName: Constants.musicIconName) as? SKSpriteNode else { return }
            let onOff = !muted ? "off" : "on"
            let newTexture = SKTexture(imageNamed: "sound-\(onOff)")
            musicIcon.texture = newTexture
            
            
        case .toggleSound:
            let muted = UserDefaults.standard.bool(forKey: UserDefaults.muteSoundKey)
            UserDefaults.standard.setValue(!muted, forKey: UserDefaults.muteSoundKey)
            
            guard let soundIcon = soundOptions?.containerView?.childNode(withName: Constants.soundIconName) as? SKSpriteNode else { return }
            let onOff = !muted ? "off" : "on"
            let newTexture = SKTexture(imageNamed: "sound-\(onOff)")
            soundIcon.texture = newTexture
            
        case .toggleShowGroupNumber:
            let show = UserDefaults.standard.bool(forKey: UserDefaults.showGroupNumberKey)
            UserDefaults.standard.setValue(!show, forKey: UserDefaults.showGroupNumberKey)
            
            guard let toggleIcon = soundOptions?.containerView?.childNode(withName: Constants.toggleIconName) as? SKSpriteNode else { return }
            let onOff = !show ? "on" : "off"
            let newTexture = SKTexture(imageNamed: "toggle-\(onOff)")
            toggleIcon.texture = newTexture
            
            
        default:
            ()
        }
    }
    
}
