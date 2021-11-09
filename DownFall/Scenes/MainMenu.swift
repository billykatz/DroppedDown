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
    func optionsSelected()
    func continueRun()
    func menuStore()
    func abandonRun()
}

class MainMenu: SKScene {
    
    struct Constants {
        static let buttonPadding = CGFloat(50.0)
        static let notificationName = "notificationRed"
        static let blankButtonName = "blankButton"
        static let feedbackFormURLString = "https://docs.google.com/forms/d/e/1FAIpQLSce6_iG4z5Kbk3j4Uw9b1ob_I1M-2NPdA3MAmuG1zLocIvvSQ/viewform?usp=sf_link"
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
    var displayStoreBadge: Bool = false
    
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
        
        let menuStoreButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .mainMenuStore, image: SKSpriteNode(imageNamed: Constants.blankButtonName), shape: .rectangle, addTextLabel: true)
        
        menuStoreButton.position = CGPoint.alignHorizontally(menuStoreButton.frame,
                                                           relativeTo: startButton.frame,
                                                           horizontalAnchor: .center,
                                                           verticalAlign: .bottom,
                                                           verticalPadding: Constants.buttonPadding,
                                                           translatedToBounds: true)
        menuStoreButton.zPosition = 0
        
        if displayStoreBadge {
            let notificationBadge = SKSpriteNode(imageNamed: Constants.notificationName)
            notificationBadge.size = CGSize.fifty
            
            notificationBadge.position = CGPoint.position(notificationBadge.frame, inside: menuStoreButton.frame, verticalAlign: .top, horizontalAnchor: .right, xOffset: 0.0, yOffset: 5.0)
            
            notificationBadge.name = Constants.notificationName
            notificationBadge.zPosition = Precedence.flying.rawValue
            
            menuStoreButton.addChild(notificationBadge)
        }
        buttonContainer.addChild(menuStoreButton)
        menuStoreButton.alpha = 0
        menuStoreButton.run(buttonFadeInAction)
        
        
        let optionsButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .mainMenuOptions, image: SKSpriteNode(imageNamed: Constants.blankButtonName), shape: .rectangle, addTextLabel: true)
        
        optionsButton.position = CGPoint.alignHorizontally(optionsButton.frame,
                                                         relativeTo: menuStoreButton.frame,
                                                         horizontalAnchor: .center,
                                                         verticalAlign: .bottom,
                                                         verticalPadding: Constants.buttonPadding,
                                                         translatedToBounds: true)
        optionsButton.zPosition = 0
        
        buttonContainer.addChild(optionsButton)
        optionsButton.alpha = 0
        optionsButton.run(buttonFadeInAction)
        
        
        /// Feedback button
        let feedbackButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .mainMenuFeedback, image: SKSpriteNode(imageNamed: Constants.blankButtonName), shape: .rectangle, addTextLabel: true)
        
        feedbackButton.position = CGPoint.alignHorizontally(optionsButton.frame,
                                                         relativeTo: optionsButton.frame,
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
        
        
        // show some FTUE if needed
        FTUEConductor().showFirstDeathDialog(playableRect: size.playableRect, in: self)
        
    }
    
    func removeStoreBadge() {
        self.removeChild(with: Constants.notificationName)
    }
}

extension MainMenu: ButtonDelegate {
    func buttonTapped(_ button: ShiftShaft_Button) {
        guard let playerModel = self.playerModel else { return }
        switch button.identifier {
        case .newGame:
            mainMenuDelegate?.newGame(playerModel.previewAppliedEffects().healFull())
            
        case .mainMenuOptions:
            mainMenuDelegate?.optionsSelected()
            
        case .mainMenuStore:
            mainMenuDelegate?.menuStore()
            
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
            let url = URL(string: Constants.feedbackFormURLString)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        default:
            ()
        }
    }
}
