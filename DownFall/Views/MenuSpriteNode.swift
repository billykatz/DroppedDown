//
//  Menu.swift
//  DownFall
//
//  Created by William Katz on 3/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class MenuSpriteNode: SKSpriteNode, ButtonDelegate {
    
    //TODO: Generally, we need to capture all the constants and move them to our Style struct.
    
    var playableRect: CGRect
    var precedence: Precedence
    var level: Level
    weak var buttonDelegate: ButtonDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence, level: Level, completedGoals: Int = 0, buttonDelegate: ButtonDelegate? = nil) {
        
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = playableRect.size.height * menuType.heightCoefficient
        
        self.playableRect = playableRect
        self.precedence = precedence
        self.level = level
        self.buttonDelegate = buttonDelegate
        
        
        super.init(texture: nil,
                   color: .menuPurple,
                   size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        self.zPosition = precedence.rawValue
        
        setup(menuType, playableRect: playableRect, precedence: precedence, level: level, completedGoals: completedGoals, buttonDelegate: buttonDelegate)
    }
    
    func setup(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence, level: Level, completedGoals: Int = 0, buttonDelegate: ButtonDelegate? = nil) {
        removeAllChildren()
        
        
        // set up the border
        let border = SKShapeNode(rect: self.frame)
        border.strokeColor = UIColor.darkGray
        border.lineWidth = Style.Menu.borderWidth
        addChild(border)
        
        
        // make it fly!
//        zPosition = 100_000
        
        // set up the buttons
        setupButtons(menuType, playableRect, precedence: precedence, level, completedGoals: completedGoals, buttonDelegate: buttonDelegate)

    }
    
    private func setupButtons(_ menuType: MenuType, _ playableRect: CGRect, precedence: Precedence, _ level: Level, completedGoals: Int = 0, buttonDelegate: ButtonDelegate? = nil) {
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let buttonSize = CGSize(width: menuSizeWidth * 0.4, height: 120)
        
        var hasSecondaryButton: Bool = false
        
        if menuType == .gameWin {
            
            let text =
                """

            You beat depth: \(level.humanReadableDepth)

            Your progress is saved

            """
            let paragraphNode = ParagraphNode.labelNode(text: text, paragraphWidth: menuSizeWidth * 0.95,
                                                        fontSize: .fontLargeSize)
            
            paragraphNode.position = CGPoint.position(paragraphNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
        }
        else if menuType == .pause {
            
            let text =
                """
            Paused

            This is the \(level.humanReadableDepth) depth
            """
            let paragraphNode = ParagraphNode.labelNode(text: text, paragraphWidth: menuSizeWidth * 0.95,
                                                        fontSize: .fontLargeSize)
            
            paragraphNode.position = CGPoint.position(paragraphNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
            
            hasSecondaryButton = true
            let mainMenuButton = ShiftShaft_Button(size: buttonSize,
                                        delegate: buttonDelegate ?? self,
                                        identifier: .mainMenu,
                                        precedence: precedence,
                                        fontSize: .fontLargeSize,
                                        fontColor: .clayRed,
                                        backgroundColor: .eggshellWhite)
            mainMenuButton.position = CGPoint.position(mainMenuButton.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: Style.Padding.most, yOffset: Style.Padding.most)
            addChild(mainMenuButton)
            
            
            let soundButton = ShiftShaft_Button(size: buttonSize,
                                     delegate: buttonDelegate ?? self,
                                     identifier: .toggleSound,
                                     precedence: precedence,
                                     fontSize: .fontLargeSize,
                                     fontColor: .clayRed,
                                     backgroundColor: .eggshellWhite)
            soundButton.position = CGPoint.position(soundButton.frame, inside: self.frame, verticalAlign: .center, horizontalAnchor: .center, yOffset: -2*Style.Padding.most)
            addChild(soundButton)
            
            
        }
        else if menuType == .gameLose {
            let text =
                """
                    Game Over.

                    You made it to \(level.humanReadableDepth) depth.
                    Your personal best is: \(RunScope.deepestDepth)
                """
            let paragraphNode = ParagraphNode.labelNode(text: text, paragraphWidth: menuSizeWidth * 0.95,
                                                        fontSize: .fontLargeSize)
            
            paragraphNode.position = CGPoint.position(paragraphNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
            
            
        }
        else if menuType == .confirmation {
            let text =
                """
                You have unredeemed offers.

                Are you sure you want to leave the store?
            """
            let paragraphNode = ParagraphNode.labelNode(text: text, paragraphWidth: menuSizeWidth * 0.95, fontSize: .fontLargeSize)
            
            paragraphNode.position = CGPoint.position(paragraphNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
            
            if let secondaryButtonIdentifier = menuType.secondaryButtonIdentifier {
                let secondaryButton = ShiftShaft_Button(size: buttonSize, delegate: buttonDelegate ?? self, identifier: secondaryButtonIdentifier, precedence: precedence, fontSize: .fontLargeSize, fontColor: .black)
                secondaryButton.position = CGPoint.position(secondaryButton.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: Style.Padding.most, yOffset: Style.Padding.most)
                addChild(secondaryButton)
                hasSecondaryButton = true
                
            }
                
        }
        // TODO: Remove DEBUG code
        else if menuType == .debug {
            let viewPauseMenu = ShiftShaft_Button.init(size: buttonSize, delegate: self, identifier: .debugPause)
            
            viewPauseMenu.position = CGPoint.position(viewPauseMenu.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: 50.0)
            
            
            let viewWinMenu = ShiftShaft_Button.init(size: buttonSize, delegate: self, identifier: .debugWin)
            
            viewWinMenu.position = CGPoint.alignHorizontally(viewWinMenu.frame, relativeTo: viewPauseMenu.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
            
            let viewLoseMenu = ShiftShaft_Button.init(size: buttonSize, delegate: self, identifier: .debugLose)
            
            viewLoseMenu.position = CGPoint.alignHorizontally(viewLoseMenu.frame, relativeTo: viewWinMenu.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
            
            addChildSafely(viewPauseMenu)
            addChildSafely(viewWinMenu)
            addChildSafely(viewLoseMenu)
            
        }
        
        // Add the default button
        // This button is added no matter what
        let button = ShiftShaft_Button(size: buttonSize,
                            delegate: buttonDelegate ?? self,
                            identifier: menuType.buttonIdentifer,
                            precedence: precedence,
                            fontSize: .fontLargeSize,
                            fontColor: .black,
                            backgroundColor: .clayRed)
        button.position = CGPoint.position(button.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: hasSecondaryButton ? .right : .center, xOffset: Style.Padding.most, yOffset: Style.Padding.most)
        button.zPosition = 1_000_000
        addChild(button)
        
        // TODO: Remove DEBUG code
        let xOutButton = ShiftShaft_Button(size: .oneHundred, delegate: self, identifier: .backpackCancel, image: SKSpriteNode(imageNamed: "buttonNegativeWhiteX"), shape: .circle)
        
        xOutButton.position = CGPoint.position(xOutButton.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .left)
        
        
        addChildSafely(xOutButton)
        
        for child in children {
            child.zPosition = 1_000_000
        }
        
        // set up the background
        let overlay = SKShapeNode(rect: playableRect)
        overlay.color = .white
        overlay.alpha = 0.25
        overlay.zPosition = -1
        addChild(overlay)
    }
    
    private func showRotate(_ frames: [SKTexture]) {
        let sprite = SKSpriteNode(color: .blue, size: size)
        sprite.position = .zero
        sprite.zPosition = 100
        
        let rotateSprite =  SKSpriteNode(texture: frames.first, color: .white, size: self.size)
        rotateSprite.position = .zero
        rotateSprite.zPosition = self.zPosition
        
        sprite.addChild(rotateSprite)
        
        let action = SKAction.animate(with: frames, timePerFrame: 0.5)
        
        self.addChild(sprite)
        rotateSprite.run(action)
    }
    
    
    func buttonPressBegan(_ button: ShiftShaft_Button) { }
    
    func buttonTapped(_ button: ShiftShaft_Button) {
        guard let identifier = ButtonIdentifier(rawValue: button.name ?? "") else { return }
        
        switch identifier {
        case .resume, .rotate:
            InputQueue.append(Input(.play))
        case .playAgain:
            InputQueue.append(Input(.playAgain))
        case .selectLevel:
            InputQueue.append(Input(.selectLevel))
        case .visitStore:
            InputQueue.append(Input(.visitStore))
        case .mainMenu:
            InputQueue.append(Input(.playAgain))
        case .toggleSound:
            let muted = UserDefaults.standard.bool(forKey: "muteSound")
            UserDefaults.standard.setValue(!muted, forKey: "muteSound")
            InputQueue.append(Input(.play))
            
        // TODO: Remove DEBUG code
        case .debugPause:
            setup(.pause, playableRect: self.playableRect, precedence: self.precedence, level: self.level, completedGoals: 2, buttonDelegate: self.buttonDelegate)
        case .debugWin:
            setup(.gameWin, playableRect: self.playableRect, precedence: self.precedence, level: self.level, completedGoals: 2, buttonDelegate: self.buttonDelegate)
        case .debugLose:
            setup(.gameLose, playableRect: self.playableRect, precedence: self.precedence, level: self.level, completedGoals: 2, buttonDelegate: self.buttonDelegate)
            
        case .backpackCancel:
            InputQueue.append(Input(.play))
 
        default:
            fatalError("These buttons dont appear in game")
        }
    }
}
