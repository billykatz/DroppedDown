//
//  Menu.swift
//  DownFall
//
//  Created by William Katz on 3/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

fileprivate func menuHeight(type: MenuType) -> CGFloat {
    switch type {
    case .pause:
        return 825
    case .gameLose:
        return 700
    case .gameWin:
        return 500
    default:
        return 300
    }
}

class MenuSpriteNode: SKSpriteNode, ButtonDelegate {
    
    //TODO: Generally, we need to capture all the constants and move them to our Style struct.
    
    var playableRect: CGRect
    var precedence: Precedence
    var level: Level
    weak var buttonDelegate: ButtonDelegate?
    
    struct Constants {
        static let soundIconName = "soundSprite"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence, level: Level, buttonDelegate: ButtonDelegate? = nil) {
        
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = menuHeight(type: menuType)
        
        self.playableRect = playableRect
        self.precedence = precedence
        self.level = level
        self.buttonDelegate = buttonDelegate
        
        
        super.init(texture: nil,
                   color: .menuPurple,
                   size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        self.zPosition = precedence.rawValue
        
        setup(menuType, playableRect: playableRect, precedence: precedence, level: level, buttonDelegate: buttonDelegate)
    }
    
    func setup(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence, level: Level, completedGoals: Int = 0, buttonDelegate: ButtonDelegate? = nil) {
        removeAllChildren()
        
        
        // set up the border
        let border = SKShapeNode(rect: self.frame)
        border.strokeColor = UIColor.menuBorderGray
        border.lineWidth = Style.Menu.borderWidth
        addChild(border)
        
        // set up the buttons
        setupButtons(menuType, playableRect, precedence: precedence, level, completedGoals: completedGoals, buttonDelegate: buttonDelegate)

    }
    
    private func setupButtons(_ menuType: MenuType, _ playableRect: CGRect, precedence: Precedence, _ level: Level, completedGoals: Int = 0, buttonDelegate: ButtonDelegate? = nil) {
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let buttonSize = CGSize(width: 330, height: 125)
        
        if menuType == .gameWin {
            
            let titleText = ["Great", "Awesome", "Nice Work"].randomElement()!
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize)
            titleNode.position = CGPoint.position(titleNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)

            
            let bodyText = "You beat depth: \(level.humanReadableDepth)"
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.95,
                                                        fontSize: .fontMediumSize)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)

            bodyNode.zPosition = precedence.rawValue
            
            addChild(titleNode)
            addChild(bodyNode)
            
            let button = ShiftShaft_Button(size: buttonSize,
                                delegate: buttonDelegate ?? self,
                                identifier: menuType.buttonIdentifer,
                                precedence: precedence,
                                fontSize: .fontLargeSize,
                                fontColor: .black,
                                backgroundColor: .buttonGray)
            button.position = CGPoint.position(button.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            button.zPosition = 1_000_000
            addChild(button)
            
        }
        else if menuType == .pause {
            
            let titleText = "Paused"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize)
            
            titleNode.position = CGPoint.position(titleNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)

            
            
            let bodyText = "Depth level \(level.humanReadableDepth)"
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.95,
                                                        fontSize: .fontMediumSize)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            
            addChild(titleNode)
            addChild(bodyNode)
            
            let mainMenuButton = ShiftShaft_Button(size: buttonSize,
                                        delegate: buttonDelegate ?? self,
                                        identifier: .mainMenu,
                                        precedence: precedence,
                                        fontSize: .fontLargeSize,
                                        fontColor: .black,
                                        backgroundColor: .buttonGray)
            mainMenuButton.position = CGPoint.position(mainMenuButton.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            addChild(mainMenuButton)
            
            
            let soundButton = ShiftShaft_Button(size: buttonSize,
                                     delegate: buttonDelegate ?? self,
                                     identifier: .toggleSound,
                                     precedence: precedence,
                                     fontSize: .fontLargeSize,
                                     fontColor: .black,
                                     backgroundColor: .buttonGray)
            soundButton.position = CGPoint.alignHorizontally(soundButton.frame, relativeTo: mainMenuButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more * 2, translatedToBounds: true)
            addChild(soundButton)
            
            let onOff = UserDefaults.standard.bool(forKey: "muteSound") ? "off" : "on"
            let soundIcon = SKSpriteNode(texture: SKTexture(imageNamed: "sound-\(onOff)"), size: CGSize(width: 75, height: 75))
            soundIcon.name = Constants.soundIconName
            soundIcon.position = CGPoint.alignVertically(soundIcon.frame, relativeTo: soundButton.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most, translatedToBounds: true)
            addChild(soundIcon)
            
            
            let resumeButton = ShiftShaft_Button(size: buttonSize,
                                delegate: buttonDelegate ?? self,
                                identifier: .resume,
                                precedence: precedence,
                                fontSize: .fontLargeSize,
                                fontColor: .black,
                                backgroundColor: .buttonGray)
            resumeButton.position = CGPoint.alignHorizontally(resumeButton.frame, relativeTo: soundButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            addChild(resumeButton)
            
        }
        else if menuType == .gameLose {
            let titleText = "Game Over"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize)
            
            titleNode.position = CGPoint.position(titleNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            let body1Text = "Spend gems at the store."
            let body1Node = ParagraphNode.labelNode(text: body1Text, paragraphWidth: menuSizeWidth * 0.95,
                                                        fontSize: .fontMediumSize)
            
            body1Node.position = CGPoint.alignHorizontally(body1Node.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)

            
            let body2Text = "You made it to depth level \(level.humanReadableDepth)."
            let body2Node = ParagraphNode.labelNode(text: body2Text, paragraphWidth: menuSizeWidth * 0.95,
                                                        fontSize: .fontMediumSize)
            
            body2Node.position = CGPoint.alignHorizontally(body2Node.frame, relativeTo: body1Node.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.normal, translatedToBounds: true)
            
            addChild(titleNode)
            addChild(body1Node)
            addChild(body2Node)
            
            
            let mainMenuButton = ShiftShaft_Button(size: buttonSize,
                                        delegate: buttonDelegate ?? self,
                                        identifier: .mainMenu,
                                        precedence: precedence,
                                        fontSize: .fontLargeSize,
                                        fontColor: .black,
                                        backgroundColor: .buttonGray)
            mainMenuButton.position = CGPoint.position(mainMenuButton.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            addChild(mainMenuButton)
            
            let storeButton = ShiftShaft_Button(size: buttonSize,
                                                delegate: buttonDelegate ?? self,
                                                identifier: .loseAndGoToStore,
                                                precedence: precedence,
                                                fontSize: .fontLargeSize,
                                                fontColor: .black,
                                                backgroundColor: .buttonGray)
            storeButton.position = CGPoint.alignHorizontally(storeButton.frame, relativeTo: mainMenuButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            addChild(storeButton)
            

        }
        else if menuType == .confirmation {
            let text =
                """
                You have unredeemed offers.

                Are you sure you want to leave the store?
            """
            let paragraphNode = ParagraphNode.labelNode(text: text, paragraphWidth: menuSizeWidth * 0.95, fontSize: .fontMediumSize)
            
            paragraphNode.position = CGPoint.position(paragraphNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
            
            if let secondaryButtonIdentifier = menuType.secondaryButtonIdentifier {
                let secondaryButton = ShiftShaft_Button(size: buttonSize, delegate: buttonDelegate ?? self, identifier: secondaryButtonIdentifier, precedence: precedence, fontSize: .fontMediumSize, fontColor: .black)
                secondaryButton.position = CGPoint.position(secondaryButton.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: Style.Padding.most, yOffset: Style.Padding.most)
                addChild(secondaryButton)
                
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

        
        for child in children {
            child.zPosition = 1_000_000
        }
        
        // set up the background overlay
        let overlay = SKShapeNode(rect: playableRect)
        overlay.color = .black
        overlay.alpha = 0.50
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
            
            guard let soundIcon = self.childNode(withName: Constants.soundIconName) as? SKSpriteNode else { return }
            let onOff = !muted ? "off" : "on"
            let newTexture = SKTexture(imageNamed: "sound-\(onOff)")
            soundIcon.texture = newTexture

            
        // TODO: Remove DEBUG code
        case .debugPause:
            setup(.pause, playableRect: self.playableRect, precedence: self.precedence, level: self.level, buttonDelegate: self.buttonDelegate)
        case .debugWin:
            setup(.gameWin, playableRect: self.playableRect, precedence: self.precedence, level: self.level, buttonDelegate: self.buttonDelegate)
        case .debugLose:
            setup(.gameLose, playableRect: self.playableRect, precedence: self.precedence, level: self.level,  buttonDelegate: self.buttonDelegate)
            
        case .backpackCancel:
            InputQueue.append(Input(.play))
            
        case .loseAndGoToStore:
            InputQueue.append(Input(.loseAndGoToStore))
 
        default:
            fatalError("These buttons dont appear in game")
        }
    }
}
