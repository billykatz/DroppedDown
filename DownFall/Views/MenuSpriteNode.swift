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
    case .pause, .tutorialPause:
        return 750
    case .gameLose, .tutorialWin:
        return 700
    case .gameWin:
        return 550
    case .confirmation, .confirmAbandonTutorial:
        return 750
    case .tutorialConfirmation:
        return 825
    case .detectedSavedGame, .detectedSavedTutorial:
        return 800
    case .options, .tutorialOptions:
        return 1050
        
    default:
        return 300
    }
}

class MenuSpriteNode: SKSpriteNode, ButtonDelegate {
    
    //TODO: Generally, we need to capture all the constants and move them to our Style struct.
    
    var playableRect: CGRect
    var precedence: Precedence
    var level: Level?
    var containerView: SKSpriteNode?
    weak var buttonDelegate: ButtonDelegate?
    
    struct Constants {
        static let soundIconName = "soundSprite"
        static let musicIconName = "musicSprite"
        static let toggleIconName = "toggleSprite"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var containerFrame: CGRect {
        return containerView?.frame ?? .zero
    }
    
    init(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence, level: Level?, buttonDelegate: ButtonDelegate? = nil) {
        
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = menuHeight(type: menuType)
        
        self.playableRect = playableRect
        self.precedence = precedence
        self.level = level
        self.buttonDelegate = buttonDelegate
        
        
        super.init(texture: nil,
                   color: .clear,
                   size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        self.zPosition = 100_000_000
        
        setup(menuType, playableRect: playableRect, precedence: precedence, level: level, buttonDelegate: buttonDelegate)
    }
    
    func setup(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence, level: Level?, completedGoals: Int = 0, buttonDelegate: ButtonDelegate? = nil) {
        
        // the only children are the overlay and the containerView
        removeAllChildren()
        
        // all the text and buttons are in the containver view
        containerView?.removeAllChildren()
        
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = menuHeight(type: menuType)
        containerView = SKSpriteNode(color: .menuPurple, size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        
        // set up the border
        let border = SKShapeNode(rect: containerView?.frame ?? .zero)
        border.strokeColor = UIColor.menuBorderGray
        border.lineWidth = Style.Menu.borderWidth
        containerView?.addChild(border)
        
        // set up the buttons
        setupButtons(menuType, playableRect, precedence: precedence, level: level, completedGoals: completedGoals, buttonDelegate: buttonDelegate)
        
        // add the containver view to the view
        self.addChild(containerView!)
        
        playMenuBounce()
    }
    
    func playMenuBounce() {
        // do a little grow and bounce
        for child in containerView?.children ?? [] {
            child.alpha = 0
        }
        containerView?.alpha = 0
        
        let appear = SKAction.fadeIn(withDuration: 0.15)
        let appearGrowShrink = SKAction.group([appear])
        appearGrowShrink.timingMode = .easeOut
        
        for child in containerView?.children ?? [] {
            child.run(appearGrowShrink)
        }
        
        containerView?.run(appearGrowShrink)
        
    }
    
    func fadeOut(completion: @escaping () -> ()) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        fadeOut.timingMode = .easeOut
        
        var spriteActions: [SpriteAction] = []
        if let container = containerView {
            spriteActions.append(SpriteAction(sprite: container, action: fadeOut))
        }
        Animator().animate(spriteActions, completion: completion)
        
    }

    
    private func setupButtons(_ menuType: MenuType, _ playableRect: CGRect, precedence: Precedence, level: Level?, completedGoals: Int = 0, buttonDelegate: ButtonDelegate? = nil) {
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let buttonSize = CGSize(width: 375, height: 125)
        
        if menuType == .gameWin {
            var titleText = ["Great", "Awesome", "Nice Work", "Woooo"].randomElement()!
            var bodyText = "You beat depth: \(level?.humanReadableDepth ?? "0")"
            
            if (level?.depth ?? 0) == 9 {
                titleText = "Congratulations!"
                bodyText = "You have unofficially beaten Shift Shaft.  In the near future level 10 will be a boss. For now, you can keep playing for as long as you'd like."
            } else if (level?.depth ?? 0) == 14 {
                titleText = "Amazing!"
                bodyText = "Please consider DM'ing on Twitter @shift_shaft with your ideas for how to improve the game."
            } else if (level?.depth ?? 0) == 19 {
                titleText = "Thank you so much!"
                bodyText = "I'm so happy you like Shift Shaft. Please share it with your friends."
            } else if (level?.depth ?? 0) == 24 {
                titleText = "Bravo"
                bodyText = "Please send a screenshot to me and I'll give you a gift. \(UUID())"
            }

            
            
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize)
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.95,
                                                   fontSize: .fontMediumSize, textAlignment: .center)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            bodyNode.zPosition = precedence.rawValue
            
            containerView?.addChild(titleNode)
            containerView?.addChild(bodyNode)
            
            let button = ShiftShaft_Button(size: buttonSize,
                                           delegate: buttonDelegate ?? self,
                                           identifier: menuType.buttonIdentifer,
                                           precedence: precedence,
                                           fontSize: .fontLargeSize,
                                           fontColor: .black,
                                           backgroundColor: .buttonGray)
            button.position = CGPoint.position(button.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            button.zPosition = 1_000_000
            containerView?.addChild(button)
            
        }
        else if menuType == .pause {
            
            let titleText = "Paused"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize, textAlignment: .center)
            
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            
            let bodyText = "Depth level \(level?.humanReadableDepth ?? "0")"
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.95,
                                                   fontSize: .fontMediumSize, textAlignment: .center)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            
            containerView?.addChild(titleNode)
            containerView?.addChild(bodyNode)
            
            let resumeButton = ShiftShaft_Button(size: buttonSize,
                                                 delegate: buttonDelegate ?? self,
                                                 identifier: .resume,
                                                 precedence: precedence,
                                                 fontSize: .fontLargeSize,
                                                 fontColor: .black,
                                                 backgroundColor: .buttonGray)
            resumeButton.position = CGPoint.position(resumeButton.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            containerView?.addChild(resumeButton)
            
            
            let options = ShiftShaft_Button(size: buttonSize,
                                                delegate: buttonDelegate ?? self,
                                                identifier: .gameMenuOptions,
                                                precedence: precedence,
                                                fontSize: .fontLargeSize,
                                                fontColor: .black,
                                                backgroundColor: .buttonGray)
            options.position = CGPoint.alignHorizontally(options.frame, relativeTo: resumeButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more * 2, translatedToBounds: true)
            containerView?.addChild(options)

            
            let mainMenuButton = ShiftShaft_Button(size: buttonSize,
                                                   delegate: buttonDelegate ?? self,
                                                   identifier: .pausedExitToMainMenu,
                                                   precedence: precedence,
                                                   fontSize: .fontLargeSize,
                                                   fontColor: .black,
                                                   backgroundColor: .buttonGray)
            mainMenuButton.position = CGPoint.alignHorizontally(resumeButton.frame, relativeTo: options.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            containerView?.addChild(mainMenuButton)
            
        }
        else if menuType == .tutorialPause {
            
            let titleText = "Paused"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize, textAlignment: .center)
            
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            
            let bodyText = "Tutorial"
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.95,
                                                   fontSize: .fontMediumSize, textAlignment: .center)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            
            containerView?.addChild(titleNode)
            containerView?.addChild(bodyNode)
            
            
            
            let resumeButton = ShiftShaft_Button(size: buttonSize,
                                                 delegate: buttonDelegate ?? self,
                                                 identifier: .resume,
                                                 precedence: precedence,
                                                 fontSize: .fontLargeSize,
                                                 fontColor: .black,
                                                 backgroundColor: .buttonGray)
            resumeButton.position = CGPoint.position(resumeButton.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            containerView?.addChild(resumeButton)
            
            let optionsButton = ShiftShaft_Button(size: buttonSize,
                                                delegate: buttonDelegate ?? self,
                                                identifier: .tutorialMenuOptions,
                                                precedence: precedence,
                                                fontSize: .fontLargeSize,
                                                fontColor: .black,
                                                backgroundColor: .buttonGray)
            optionsButton.position = CGPoint.alignHorizontally(optionsButton.frame, relativeTo: resumeButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more * 2, translatedToBounds: true)
            containerView?.addChild(optionsButton)
            
            let mainMenuButton = ShiftShaft_Button(size: buttonSize,
                                                   delegate: buttonDelegate ?? self,
                                                   identifier: .tutorialPausedExitToMainMenu,
                                                   precedence: precedence,
                                                   fontSize: .fontLargeSize,
                                                   fontColor: .black,
                                                   backgroundColor: .buttonGray)
            mainMenuButton.position = CGPoint.alignHorizontally(mainMenuButton.frame, relativeTo: optionsButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            containerView?.addChild(mainMenuButton)
            
        }
        
        else if menuType == .gameLose {
            let titleText = "You made it to depth level \(level?.humanReadableDepth ?? "0")."
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize, textAlignment: .center)
            
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            let body1Text = "Spend gems at the store."
            let body1Node = ParagraphNode.labelNode(text: body1Text, paragraphWidth: menuSizeWidth * 0.90,
                                                    fontSize: .fontMediumSize, textAlignment: .center)
            
            body1Node.position = CGPoint.alignHorizontally(body1Node.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            
//            let body2Text = "You made it to depth level \(level?.humanReadableDepth ?? "0")."
//            let body2Node = ParagraphNode.labelNode(text: body2Text, paragraphWidth: menuSizeWidth * 0.90,
//                                                    fontSize: .fontMediumSize, textAlignment: .center)
//
//            body2Node.position = CGPoint.alignHorizontally(body2Node.frame, relativeTo: body1Node.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.normal, translatedToBounds: true)
            
            containerView?.addChild(titleNode)
            containerView?.addChild(body1Node)
//            containerView?.addChild(body2Node)
            
            
            let mainMenuButton = ShiftShaft_Button(size: buttonSize,
                                                   delegate: buttonDelegate ?? self,
                                                   identifier: .mainMenu,
                                                   precedence: precedence,
                                                   fontSize: .fontLargeSize,
                                                   fontColor: .black,
                                                   backgroundColor: .buttonGray)
            mainMenuButton.position = CGPoint.position(mainMenuButton.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            containerView?.addChild(mainMenuButton)
            
            if (!FTUEConductor().doNotShowGoDirectlyToStoreButton) {
                let storeButton = ShiftShaft_Button(size: buttonSize,
                                                    delegate: buttonDelegate ?? self,
                                                    identifier: .loseAndGoToStore,
                                                    precedence: precedence,
                                                    fontSize: .fontLargeSize,
                                                    fontColor: .black,
                                                    backgroundColor: .buttonGray)
                storeButton.position = CGPoint.alignHorizontally(storeButton.frame, relativeTo: mainMenuButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
                
                containerView?.addChild(storeButton)
            }
            
            
            
            
        }
        else if menuType == .confirmation {
            let titleText = "Abandon run?"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize, textAlignment: .center)
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            let bodyText = "You will lose all progress but keep any gems you earned."
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.95,
                                                   fontSize: .fontLargeSize, textAlignment: .center)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            bodyNode.zPosition = precedence.rawValue
            
            containerView?.addChild(titleNode)
            containerView?.addChild(bodyNode)
            
            let noResume = ShiftShaft_Button(size: buttonSize,
                                             delegate: buttonDelegate ?? self,
                                             identifier: .doNotAbandonRun,
                                             precedence: precedence,
                                             fontSize: .fontLargeSize,
                                             fontColor: .black,
                                             backgroundColor: .buttonGray)
            noResume.position = CGPoint.position(noResume.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            containerView?.addChild(noResume)
            
            let yesAbandon = ShiftShaft_Button(size: buttonSize,
                                               delegate: buttonDelegate ?? self,
                                               identifier: .yesAbandonRun,
                                               precedence: precedence,
                                               fontSize: .fontLargeSize,
                                               fontColor: .white,
                                               backgroundColor: .buttonDestructiveRed)
            yesAbandon.position = CGPoint.alignHorizontally(yesAbandon.frame, relativeTo: noResume.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            containerView?.addChild(yesAbandon)
            
            
        }
        else if menuType == .confirmAbandonTutorial {
            let titleText = "Skip tutorial?"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize, textAlignment: .center)
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            let bodyText = "You can replay the tutorial from the Settings menu."
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.95,
                                                   fontSize: .fontLargeSize, textAlignment: .center)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            bodyNode.zPosition = precedence.rawValue
            
            containerView?.addChild(titleNode)
            containerView?.addChild(bodyNode)
            
            let noResume = ShiftShaft_Button(size: buttonSize,
                                             delegate: buttonDelegate ?? self,
                                             identifier: .doNotAbandonTutorial,
                                             precedence: precedence,
                                             fontSize: .fontLargeSize,
                                             fontColor: .black,
                                             backgroundColor: .buttonGray)
            noResume.position = CGPoint.position(noResume.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            containerView?.addChild(noResume)
            
            let yesAbandon = ShiftShaft_Button(size: buttonSize,
                                               delegate: buttonDelegate ?? self,
                                               identifier: .yesSkipTutorial,
                                               precedence: precedence,
                                               fontSize: .fontLargeSize,
                                               fontColor: .white,
                                               backgroundColor: .buttonDestructiveRed)
            yesAbandon.position = CGPoint.alignHorizontally(yesAbandon.frame, relativeTo: noResume.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            containerView?.addChild(yesAbandon)
            
            
        }

        else if menuType == .tutorialConfirmation {
            let titleText = "Abandon Tutorial?"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.90,
                                                    fontSize: .fontExtraLargeSize, textAlignment: .center)
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            let bodyText = "You can access the tutorial again from the Stats menu"
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.90,
                                                   fontSize: .fontLargeSize, textAlignment: .center)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            bodyNode.zPosition = precedence.rawValue
            
            let body2Text = "You will lose all progress but keep any gems you earned."
            let body2Node = ParagraphNode.labelNode(text: body2Text, paragraphWidth: menuSizeWidth * 0.90,
                                                   fontSize: .fontMediumSize, textAlignment: .center)
            
            body2Node.position = CGPoint.alignHorizontally(body2Node.frame, relativeTo: bodyNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            body2Node.zPosition = precedence.rawValue

            
            containerView?.addChild(titleNode)
            containerView?.addChild(bodyNode)
            containerView?.addChild(body2Node)
            
            let noResume = ShiftShaft_Button(size: buttonSize,
                                             delegate: buttonDelegate ?? self,
                                             identifier: .doNotAbandonTutorial,
                                             precedence: precedence,
                                             fontSize: .fontLargeSize,
                                             fontColor: .black,
                                             backgroundColor: .buttonGray)
            noResume.position = CGPoint.position(noResume.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            containerView?.addChild(noResume)
            
            let yesAbandon = ShiftShaft_Button(size: buttonSize,
                                               delegate: buttonDelegate ?? self,
                                               identifier: .yesSkipTutorial,
                                               precedence: precedence,
                                               fontSize: .fontLargeSize,
                                               fontColor: .white,
                                               backgroundColor: .buttonDestructiveRed)
            yesAbandon.position = CGPoint.alignHorizontally(yesAbandon.frame, relativeTo: noResume.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            containerView?.addChild(yesAbandon)
            
            
        } else if menuType == .detectedSavedGame {
            
            let titleText = "Saved game"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize, textAlignment: .center)
            
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            
            let bodyText = "Would you like to continue or abandon your game?"
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.80,
                                                   fontSize: .fontLargeSize, textAlignment: .center)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            
            containerView?.addChild(titleNode)
            containerView?.addChild(bodyNode)
            
            let abandonRunButton = ShiftShaft_Button(size: buttonSize,
                                                     delegate: buttonDelegate ?? self,
                                                     identifier: .mainMenuAbandonRun,
                                                     precedence: precedence,
                                                     fontSize: .fontLargeSize,
                                                     fontColor: .white,
                                                     backgroundColor: .buttonDestructiveRed)
            abandonRunButton.position = CGPoint.position(abandonRunButton.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            containerView?.addChild(abandonRunButton)
            
            
            let continueRunButton = ShiftShaft_Button(size: buttonSize,
                                                      delegate: buttonDelegate ?? self,
                                                      identifier: .mainMenuContinueRun,
                                                      precedence: precedence,
                                                      fontSize: .fontLargeSize,
                                                      fontColor: .black,
                                                      backgroundColor: .buttonGray)
            continueRunButton.position = CGPoint.alignHorizontally(continueRunButton.frame, relativeTo: abandonRunButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            containerView?.addChild(continueRunButton)
            
        } else if menuType == .detectedSavedTutorial {
            
            let titleText = "Resume tutorial?"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize, textAlignment: .center)
            
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            
            let bodyText = "Would you like to continue the tutorial?"
            let bodyNode = ParagraphNode.labelNode(text: bodyText, paragraphWidth: menuSizeWidth * 0.90,
                                                   fontSize: .fontLargeSize, textAlignment: .center)
            
            bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            
            
            containerView?.addChild(titleNode)
            containerView?.addChild(bodyNode)
            
            let abandonRunButton = ShiftShaft_Button(size: buttonSize,
                                                     delegate: buttonDelegate ?? self,
                                                     identifier: .mainMenuAbandonTutorial,
                                                     precedence: precedence,
                                                     fontSize: .fontMediumSize,
                                                     fontColor: .white,
                                                     backgroundColor: .buttonDestructiveRed)
            abandonRunButton.position = CGPoint.position(abandonRunButton.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            containerView?.addChild(abandonRunButton)
            
            
            let continueRunButton = ShiftShaft_Button(size: buttonSize,
                                                      delegate: buttonDelegate ?? self,
                                                      identifier: .mainMenuContinueTutorial,
                                                      precedence: precedence,
                                                      fontSize: .fontLargeSize,
                                                      fontColor: .black,
                                                      backgroundColor: .buttonGray)
            continueRunButton.position = CGPoint.alignHorizontally(continueRunButton.frame, relativeTo: abandonRunButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            containerView?.addChild(continueRunButton)
            
        } else if menuType == .options || menuType == .tutorialOptions{
            let titleText = "Options"
            let titleNode = ParagraphNode.labelNode(text: titleText, paragraphWidth: menuSizeWidth * 0.95,
                                                    fontSize: .fontExtraLargeSize, textAlignment: .center)
            
            titleNode.position = CGPoint.position(titleNode.frame, inside: containerFrame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            
            
            containerView?.addChild(titleNode)
            
            ///
            /// Options
            ///
            /// - Show Rock Total
            /// - Adjust Sound Volume
            /// - Adjust Music Volume
            /// - Back
            ///
            let backButtonIdentifier: ButtonIdentifier = menuType == .options ? .soundOptionsBack : .tutorialSoundOptionsBack
            let backButton = ShiftShaft_Button(size: buttonSize,
                                                   delegate: buttonDelegate ?? self,
                                                   identifier: backButtonIdentifier,
                                                   precedence: precedence,
                                                   fontSize: .fontLargeSize,
                                                   fontColor: .black,
                                                   backgroundColor: .buttonGray)
            backButton.position = CGPoint.position(backButton.frame, inside: containerFrame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most * 2)
            containerView?.addChild(backButton)
            
            
            let soundButton = ShiftShaft_Button(size: buttonSize,
                                                delegate: buttonDelegate ?? self,
                                                identifier: .toggleSound,
                                                precedence: precedence,
                                                fontSize: .fontLargeSize,
                                                fontColor: .black,
                                                backgroundColor: .buttonGray)
            soundButton.position = CGPoint.alignHorizontally(soundButton.frame, relativeTo: backButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more * 2, translatedToBounds: true)
            containerView?.addChild(soundButton)
            
            let onOff = UserDefaults.standard.bool(forKey: UserDefaults.muteSoundKey) ? "off" : "on"
            let soundIcon = SKSpriteNode(texture: SKTexture(imageNamed: "sound-\(onOff)"), size: CGSize(width: 75, height: 75))
            soundIcon.name = Constants.soundIconName
            soundIcon.position = CGPoint.alignVertically(soundIcon.frame, relativeTo: soundButton.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most, translatedToBounds: true)
            
            containerView?.addChild(soundIcon)
            
            
            let musicButton = ShiftShaft_Button(size: buttonSize,
                                                delegate: buttonDelegate ?? self,
                                                identifier: .toggleMusic,
                                                precedence: precedence,
                                                fontSize: .fontLargeSize,
                                                fontColor: .black,
                                                backgroundColor: .buttonGray)
            musicButton.position = CGPoint.alignHorizontally(musicButton.frame, relativeTo: soundButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more * 2, translatedToBounds: true)
            containerView?.addChild(musicButton)
            
            let musicOnOff = UserDefaults.standard.bool(forKey: UserDefaults.muteMusicKey) ? "off" : "on"
            let musicIcon = SKSpriteNode(texture: SKTexture(imageNamed: "sound-\(musicOnOff)"), size: CGSize(width: 75, height: 75))
            musicIcon.name = Constants.musicIconName
            musicIcon.position = CGPoint.alignVertically(musicIcon.frame, relativeTo: musicButton.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most, translatedToBounds: true)
            
            containerView?.addChild(musicIcon)

            
            let rockGroupAmountButton = ShiftShaft_Button(size: buttonSize,
                                                delegate: buttonDelegate ?? self,
                                                identifier: .toggleShowGroupNumber,
                                                precedence: precedence,
                                                fontSize: .fontLargeSize,
                                                fontColor: .black,
                                                backgroundColor: .buttonGray)
            rockGroupAmountButton.position = CGPoint.alignHorizontally(rockGroupAmountButton.frame, relativeTo: musicButton.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.more * 2, translatedToBounds: true)
            containerView?.addChild(rockGroupAmountButton)
            
            let rockGroupAmountOnoff = UserDefaults.standard.bool(forKey: UserDefaults.showGroupNumberKey) ? "on" : "off"
            let toggleRockAmountIcon = SKSpriteNode(texture: SKTexture(imageNamed: "toggle-\(rockGroupAmountOnoff)"), size: CGSize(width: 75, height: 50))
            toggleRockAmountIcon.name = Constants.toggleIconName
            toggleRockAmountIcon.position = CGPoint.alignVertically(toggleRockAmountIcon.frame, relativeTo: rockGroupAmountButton.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most, translatedToBounds: true)
            containerView?.addChild(toggleRockAmountIcon)

        }
        
        
        for child in children {
            child.zPosition = 100_000_000_000
        }
        
        // set up the background overlay
        let overlay = SKShapeNode(rect: playableRect)
        overlay.color = .black
        overlay.alpha = 0.50
        overlay.zPosition = -1
        overlay.name = "overlaySpriteName"
        self.addChild(overlay)
    }
    
    func buttonPressBegan(_ button: ShiftShaft_Button) { }
    
    func buttonTapped(_ button: ShiftShaft_Button) {
        guard let identifier = ButtonIdentifier(rawValue: button.name ?? "") else { return }
        
        switch identifier {
        case .resume, .rotate:
            fadeOut {
                InputQueue.append(Input(.play))
            }
        case .playAgain:
            fadeOut {
                InputQueue.append(Input(.playAgain))
            }
            
        case .visitStore:
            fadeOut {
                InputQueue.append(Input(.visitStore))
            }

            
        case .mainMenu:
            fadeOut {
                InputQueue.append(Input(.playAgain))
            }

            
        case .pausedExitToMainMenu:
            setup(.confirmation, playableRect: self.playableRect, precedence: self.precedence, level: self.level, buttonDelegate: self.buttonDelegate)
            
        case .tutorialPausedExitToMainMenu:
            setup(.tutorialConfirmation, playableRect: self.playableRect, precedence: self.precedence, level: self.level, buttonDelegate: self.buttonDelegate)
            
        case .yesAbandonRun, .yesSkipTutorial:
            fadeOut {
                InputQueue.append(Input(.playAgain))
            }

        
        case .doNotAbandonRun:
            fadeOut { [weak self] in
                guard let self = self else { return }
                InputQueue.append(Input(.play))
                
                self.setup(.pause, playableRect: self.playableRect, precedence: self.precedence, level: self.level, buttonDelegate: self.buttonDelegate)
            }
            
        case .doNotAbandonTutorial:
            fadeOut { [weak self] in
                guard let self = self else { return }
                InputQueue.append(Input(.play))
                self.setup(.tutorialPause, playableRect: self.playableRect, precedence: self.precedence, level: self.level, buttonDelegate: self.buttonDelegate)
            }
            
            
        case .gameMenuOptions:
            setup(.options, playableRect: self.playableRect, precedence: self.precedence, level: self.level,  buttonDelegate: self.buttonDelegate)

            
        case .soundOptionsBack:
            setup(.pause, playableRect: self.playableRect, precedence: self.precedence, level: self.level,  buttonDelegate: self.buttonDelegate)
            
        case .tutorialMenuOptions:
            setup(.tutorialOptions, playableRect: self.playableRect, precedence: self.precedence, level: self.level,  buttonDelegate: self.buttonDelegate)
            
        case .tutorialSoundOptionsBack:
            setup(.tutorialPause, playableRect: self.playableRect, precedence: self.precedence, level: self.level,  buttonDelegate: self.buttonDelegate)
            
        case .toggleMusic:
            let muted = UserDefaults.standard.bool(forKey: UserDefaults.muteMusicKey)
            UserDefaults.standard.setValue(!muted, forKey: UserDefaults.muteMusicKey)
            
            guard let musicIcon = containerView?.childNode(withName: Constants.musicIconName) as? SKSpriteNode else { return }
            let onOff = !muted ? "off" : "on"
            let newTexture = SKTexture(imageNamed: "sound-\(onOff)")
            musicIcon.texture = newTexture

        
        case .toggleSound:
            let muted = UserDefaults.standard.bool(forKey: UserDefaults.muteSoundKey)
            UserDefaults.standard.setValue(!muted, forKey: UserDefaults.muteSoundKey)
            
            guard let soundIcon = containerView?.childNode(withName: Constants.soundIconName) as? SKSpriteNode else { return }
            let onOff = !muted ? "off" : "on"
            let newTexture = SKTexture(imageNamed: "sound-\(onOff)")
            soundIcon.texture = newTexture
            
        case .toggleShowGroupNumber:
            let show = UserDefaults.standard.bool(forKey: UserDefaults.showGroupNumberKey)
            UserDefaults.standard.setValue(!show, forKey: UserDefaults.showGroupNumberKey)
            
            guard let toggleIcon = containerView?.childNode(withName: Constants.toggleIconName) as? SKSpriteNode else { return }
            let onOff = !show ? "on" : "off"
            let newTexture = SKTexture(imageNamed: "toggle-\(onOff)")
            toggleIcon.texture = newTexture

            
        // TODO: Remove DEBUG code
        case .debugPause:
            setup(.pause, playableRect: self.playableRect, precedence: self.precedence, level: self.level, buttonDelegate: self.buttonDelegate)
        case .debugWin:
            setup(.gameWin, playableRect: self.playableRect, precedence: self.precedence, level: self.level, buttonDelegate: self.buttonDelegate)
        case .debugLose:
            setup(.gameLose, playableRect: self.playableRect, precedence: self.precedence, level: self.level,  buttonDelegate: self.buttonDelegate)
            
        case .backpackCancel:
            fadeOut {
                InputQueue.append(Input(.play))
            }
            
        case .loseAndGoToStore:
            fadeOut {
                InputQueue.append(Input(.loseAndGoToStore))
            }

            
        default:
            fatalError("These buttons dont appear in game")
        }
    }
}
