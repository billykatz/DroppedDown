//
//  Menu.swift
//  DownFall
//
//  Created by William Katz on 3/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class MenuSpriteNode: SKSpriteNode {

    //TODO: Generally, we need to capture all the constants and move them to our Style struct.
    
    init(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence, level: Level) {
        
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = playableRect.size.height * menuType.heightCoefficient
        
        
        super.init(texture: nil,
                   color: .menuPurple,
                   size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        
        removeAllChildren()
        
        let border = SKShapeNode(rect: self.frame)
        border.strokeColor = UIColor.darkGray
        border.lineWidth = Style.Menu.borderWidth
        addChild(border)
        
        zPosition = precedence.rawValue
        setupButtons(menuType, playableRect, precedence: precedence, level)
        
    }
    
    private func setupButtons(_ menuType: MenuType, _ playableRect: CGRect, precedence: Precedence, _ level: Level) {
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let buttonSize = CGSize(width: menuSizeWidth * 0.4, height: 120)
        
        if menuType == .gameWin {
            
            let text =
            """
            You passed \(level.humanReadableDepth) depth.
            
            Your personal best is: _
            """
            let paragraphNode = ParagraphNode.labelNode(text: text, paragraphWidth: menuSizeWidth * 0.95,
                fontSize: UIFont.largeSize)

            paragraphNode.position = CGPoint.position(paragraphNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
        } else if menuType == .pause {
            
            let text =
            """
            Paused

            This is the \(level.humanReadableDepth) depth
            """
            let paragraphNode = ParagraphNode.labelNode(text: text, paragraphWidth: menuSizeWidth * 0.95,
                fontSize: UIFont.largeSize)

            paragraphNode.position = CGPoint.position(paragraphNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
            
            
            let mainMenuButton = Button(size: buttonSize,
                                delegate: self,
                                identifier: .mainMenu,
                                precedence: precedence,
                                fontSize: UIFont.largeSize,
                                fontColor: .clayRed,
                                backgroundColor: .eggshellWhite)
            mainMenuButton.position = CGPoint.position(this: mainMenuButton.frame, centeredInBottomOf: self.frame, verticalPadding: Style.Padding.most*2 + buttonSize.height)
            addChild(mainMenuButton)

        } else if menuType == .gameLose {
            let text =
                """
                    You ran of of health.
                            😞

                    Thanks for playing!!
                """
            let paragraphNode = ParagraphNode.labelNode(text: text, paragraphWidth: menuSizeWidth * 0.95,
                fontSize: UIFont.largeSize)

            paragraphNode.position = CGPoint.position(paragraphNode.frame, inside: self.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
            

        }
        
        // Add the default button
        // This button is added no matter what
        let button = Button(size: buttonSize,
                            delegate: self,
                            identifier: menuType.buttonIdentifer,
                            precedence: precedence,
                            fontSize: UIFont.largeSize,
                            fontColor: .black,
                            backgroundColor: .clayRed)
        button.position = CGPoint.position(this: button.frame, centeredInBottomOf: self.frame, verticalPadding: Style.Padding.most)
        addChild(button)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addFingerSprite(_ menuType: MenuType, _ playableRect: CGRect, _ precedence: Precedence) {
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = playableRect.size.height * menuType.heightCoefficient
        
        // Heights and widths
        let topHeight: CGFloat = menuSizeHeight/3 - 56
        let bottomHeight: CGFloat = -menuSizeHeight/3 + 56
        
        let rightWidth: CGFloat = menuSizeWidth/2 - 56
        let leftWidth: CGFloat = -menuSizeWidth/2 + 56
        
        // Points
        let topRight = CGPoint(x: rightWidth, y: topHeight)
        let topLeft = CGPoint(x: leftWidth, y: topHeight)
        
        let bottomRight = CGPoint(x: rightWidth, y: bottomHeight)
        let bottomLeft = CGPoint(x: leftWidth, y: bottomHeight)
        
        let startStopTarget: [(CGPoint, CGPoint)] = [
            (topRight, topLeft),
            (topLeft, bottomLeft),
            (bottomLeft, bottomRight),
            (bottomRight, topRight)
        ]
        
        var actions: [SKAction] = []
        
        let fingerSprite = SKSpriteNode(texture: SKTexture(imageNamed: "finger"))
        fingerSprite.size = CGSize(width: 80, height: 80)
        
        // initial positions
        fingerSprite.position = topRight
        fingerSprite.zPosition = precedence.rawValue
        
        // add to scene
        addChild(fingerSprite)
        
        for startStop in startStopTarget {
            let stop = startStop.1
            
            //actions
            let swipeAction = SKAction.move(to: stop, duration: 1.25)
            swipeAction.timingMode = .easeOut
            
            actions.append(swipeAction)
        }
        
        fingerSprite.run(SKAction.repeatForever(SKAction.sequence(actions)))
    }
    
    func addRotateParagraph(_ menuType: MenuType, _ playableRect: CGRect, _ precedence: Precedence) {
        
        let paragraphNode = ParagraphNode.labelNode(text: "Swipe like this to rotate the board counter-clockwise", paragraphWidth: playableRect.width * 0.70)
        paragraphNode.position = .zero
        paragraphNode.zPosition = precedence.rawValue
        
        addChild(paragraphNode)
    }
}

//MARK:- ButtonDelegate

extension MenuSpriteNode: ButtonDelegate {
    func buttonPressBegan(_ button: Button) { }
    
    func buttonTapped(_ button: Button) {
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
        default:
            fatalError("These buttons dont appear in game")
        }
    }
}
