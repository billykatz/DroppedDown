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
    }
    
    private var background: SKSpriteNode!
    
    private lazy var logo: SKSpriteNode = {
        let ratio: CGFloat = 60.0/210.0
        let width = self.size.playableRect.width*0.8
        let height = width * ratio
        let loadingSprite = SKSpriteNode(texture: SKTexture(imageNamed: "logo"), size: CGSize(width: width, height: height))
        loadingSprite.zPosition = Precedence.menu.rawValue
        loadingSprite.position = .zero
        
        return loadingSprite
    }()
    
    
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
        
        
        let startButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .newGame, image: SKSpriteNode(imageNamed: "blankButton"), shape: .rectangle, addTextLabel: true)

        
        startButton.position = CGPoint.position(startButton.frame,
                                                inside: size.playableRect,
                                                verticalAlign: .center,
                                                horizontalAnchor: .center,
                                                yOffset: 200.0
        )
        startButton.zPosition = 0
        addChild(startButton)
        
        logo.position = .position(logo.frame,
                                    inside: size.playableRect,
                                    verticalAlign: .top,
                                    horizontalAnchor: .center,
                                    yOffset: 150.0)
        logo.zPosition = 1_000_000_000_000
        addChild(logo)
        
        let menuStoreButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .mainMenuStore, image: SKSpriteNode(imageNamed: "blankButton"), shape: .rectangle, addTextLabel: true)
        
        menuStoreButton.position = CGPoint.alignHorizontally(menuStoreButton.frame,
                                                           relativeTo: startButton.frame,
                                                           horizontalAnchor: .center,
                                                           verticalAlign: .bottom,
                                                           verticalPadding: Constants.buttonPadding,
                                                           translatedToBounds: true)
        menuStoreButton.zPosition = 0
        
        if displayStoreBadge {
            let notificationBadge = SKSpriteNode(imageNamed: "notificationRed")
            notificationBadge.size = CGSize.fifty
            
            notificationBadge.position = CGPoint.position(notificationBadge.frame, inside: menuStoreButton.frame, verticalAlign: .top, horizontalAnchor: .right, xOffset: 0.0, yOffset: 5.0, translatedToBounds: true)
            
            notificationBadge.name = "notificationRed"
            notificationBadge.zPosition = Precedence.flying.rawValue
            
            addChild(notificationBadge)
        }
        
        addChild(menuStoreButton)
        
        
        let optionsButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .mainMenuOptions, image: SKSpriteNode(imageNamed: "blankButton"), shape: .rectangle, addTextLabel: true)
        
        optionsButton.position = CGPoint.alignHorizontally(optionsButton.frame,
                                                         relativeTo: menuStoreButton.frame,
                                                         horizontalAnchor: .center,
                                                         verticalAlign: .bottom,
                                                         verticalPadding: Constants.buttonPadding,
                                                         translatedToBounds: true)
        optionsButton.zPosition = 0
        
        addChild(optionsButton)
        
        
        // Show the detected saved game UX
        if let run = runToContinue {
            if run.isTutorial && run.areas.count < 2 {
                addChild(detectedSavedTutorial)
                detectedSavedGameMenu.zPosition = 10_000_000
            } else {
                addChild(detectedSavedGameMenu)
                detectedSavedGameMenu.zPosition = 10_000_000
            }
        }
        
    }
    
    func removeStoreBadge() {
        self.removeChild(with: "notificationRed")
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
            
        case .mainMenuContinueRun, .mainMenuContinueTutorial:
            mainMenuDelegate?.continueRun()
            
        case .mainMenuAbandonRun:
            detectedSavedGameMenu.removeFromParent()
            addChild(confirmAbandonRun)
            
        case .mainMenuAbandonTutorial:
            detectedSavedTutorial.removeFromParent()
            addChild(confirmAbandonTutorial)
    
        case .yesAbandonRun:
            confirmAbandonRun.removeFromParent()
            mainMenuDelegate?.abandonRun()
        
        case .yesSkipTutorial:
            confirmAbandonTutorial.removeFromParent()
            mainMenuDelegate?.abandonRun()
            
        case .doNotAbandonRun:
            confirmAbandonRun.removeFromParent()
            addChild(detectedSavedGameMenu)
        
        case .doNotAbandonTutorial:
            confirmAbandonTutorial.removeFromParent()
            addChild(detectedSavedTutorial)
            
        default:
            ()
        }
    }
}
