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
}

class MainMenu: SKScene {
    
    struct Constants {
        static let buttonPadding = CGFloat(50.0)
    }
    
    private var background: SKSpriteNode!
    private var continueRunButton: ShiftShaft_Button?
    
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
    var displayStoreBadge: Bool = false
    
    
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
        addChild(startButton)
        
        logo.position = .position(logo.frame,
                                    inside: size.playableRect,
                                    verticalAlign: .top,
                                    horizontalAnchor: .center,
                                    yOffset: 150.0)
        addChild(logo)
        
        if hasRunToContinue ?? false {
            let levelButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .continueRun, image: SKSpriteNode(imageNamed: "blankButton"), shape: .rectangle, addTextLabel: true)

            
            levelButton.position = CGPoint.alignHorizontally(levelButton.frame,
                                                           relativeTo: startButton.frame,
                                                           horizontalAnchor: .center,
                                                           verticalAlign: .bottom,
                                                           verticalPadding: Constants.buttonPadding,
                                                           translatedToBounds: true)
            continueRunButton = levelButton
            
            addChild(levelButton)
        }
        
        let menuStoreButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .mainMenuStore, image: SKSpriteNode(imageNamed: "blankButton"), shape: .rectangle, addTextLabel: true)
        
        menuStoreButton.position = CGPoint.alignHorizontally(menuStoreButton.frame,
                                                           relativeTo: continueRunButton?.frame ?? startButton.frame,
                                                           horizontalAnchor: .center,
                                                           verticalAlign: .bottom,
                                                           verticalPadding: Constants.buttonPadding,
                                                           translatedToBounds: true)
        
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
        
        
        addChild(optionsButton)
        
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
            
        case .continueRun:
            mainMenuDelegate?.continueRun()
            
        case .mainMenuOptions:
            mainMenuDelegate?.optionsSelected()
            
        case .mainMenuStore:
            mainMenuDelegate?.menuStore()
            
        default:
            ()
        }
    }
}
