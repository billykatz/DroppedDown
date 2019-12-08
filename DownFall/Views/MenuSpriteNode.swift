//
//  Menu.swift
//  DownFall
//
//  Created by William Katz on 3/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class MenuSpriteNode: SKSpriteNode {

    
    struct Constants {
        static let resume = "Resume"
        static let win = "You Won!!"
        static let playAgain = "Play Again?"
    }
    
    enum MenuType {
        case pause
        case gameWin
        case rotate
        
        var buttonText: String {
            switch self {
            case .pause:
                return Constants.resume
            case .gameWin:
                return Constants.playAgain
            case .rotate:
                return ""
            }
        }
        
        var buttonIdentifer: ButtonIdentifier {
            switch self {
            case .pause:
                return ButtonIdentifier.resume
            case .gameWin:
                return ButtonIdentifier.playAgain
            case .rotate:
                return ButtonIdentifier.rotate
            }
            
        }
        
        var widthCoefficient: CGFloat {
            switch self {
            case .rotate:
                return 0.9
            default:
                return 0.7
            }
        }
        
        var heightCoefficient: CGFloat {
            switch self {
            case .rotate:
                return 0.65
            default:
                return 0.33
            }
        }
    }
    
    init(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence) {
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = playableRect.size.height * menuType.heightCoefficient
        
        
        
        super.init(texture: nil,
                   color: .menuPurple,
                   size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        
        removeAllChildren()
        
        let border = SKShapeNode(rect: self.frame)
        border.strokeColor = UIColor.darkGray
        border.lineWidth = 10.0
        addChild(border)
        
        zPosition = precedence.rawValue
        setupButtons(menuType, playableRect, precedence: precedence)
        
    }
    
    private func setupButtons(_ menuType: MenuType, _ playableRect: CGRect, precedence: Precedence) {
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = playableRect.size.height * menuType.heightCoefficient
        let buttonSize = CGSize(width: menuSizeWidth * 0.4, height: 120)
        
        var addDefaultButton = true
        
        if menuType == .rotate {
            
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
            
            let paragraphNode = ParagraphNode.labelNode(text: "Swipe like this to rotate the board counter-clockwise", paragraphWidth: playableRect.width * 0.70)
            paragraphNode.position = .zero
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
            
        } else if menuType == .gameWin && GameScope.shared.difficulty == .tutorial1 {
            // In this case, we want to inform the player about how smart they are
            // and encourage them to continue to tutorial.  There should only be one button
            // and it should say "Continue"
            let paragraphNode = ParagraphNode.labelNode(text:
                """
                    Awesome job.
                    That gem is very valuable, always try to collect gems if you have a chance.
                    Let's head to the store and spend our gems.
                """
                ,paragraphWidth: playableRect.width * 0.70)
            paragraphNode.position = .zero
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
            
            // turn off default button for .gameWin and create our own
            addDefaultButton = false
            
            let button = Button(size: buttonSize,
                                delegate: self,
                                identifier: .visitStore,
                                precedence: precedence,
                                fontSize: 80,
                                fontColor: .black)
            button.position = CGPoint(x: 0, y: -buttonSize.height - 175)
            addChild(button)
            

        }
        
        
        else {
            let button2 = Button(size: buttonSize,
                                 delegate: self,
                                 identifier: .selectLevel,
                                 precedence: precedence,
                                 fontSize: UIFont.largeSize,
                                 fontColor: .black)
            button2.position = CGPoint(x: 0, y: buttonSize.height/2 + 15)
            addChild(button2)
        }
        
        if (addDefaultButton) {
            // This button is added no matter what
            let button = Button(size: buttonSize,
                                delegate: self,
                                identifier: menuType.buttonIdentifer,
                                precedence: precedence,
                                fontSize: 80,
                                fontColor: .black)
            button.position = CGPoint(x: 0, y: -buttonSize.height - 175)
            addChild(button)
        }
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
}

//MARK:- ButtonDelegate

extension MenuSpriteNode: ButtonDelegate {
    func buttonPressBegan(_ button: Button) { }
    
    func buttonPressed(_ button: Button) {
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
        case .leaveStore, .storeItem, .wallet, .infoPopup:
            fatalError("These buttons dont appear in game")
        }
    }
}
