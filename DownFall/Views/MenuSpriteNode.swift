//
//  Menu.swift
//  DownFall
//
//  Created by William Katz on 3/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class MenuSpriteNode: SKSpriteNode {
    
    let rotateClockwise = SpriteSheet(texture: SKTexture(imageNamed: "rotateClockwise"), rows: 1, columns: 12)

    
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
                return 0.9
            default:
                return 0.33
            }
        }
    }
    
    init(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence) {
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = playableRect.size.height * menuType.heightCoefficient
        
        
        super.init(texture: SKTexture(imageNamed: "menu"),
                   color: .black,
                   size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        
        setupButtons(menuType, playableRect, precedence: precedence)
        zPosition = precedence.rawValue
        
    }
    
    func setupButtons(_ menuType: MenuType, _ playableRect: CGRect, precedence: Precedence) {
        let menuSizeWidth = playableRect.size.width * menuType.widthCoefficient
        let menuSizeHeight = playableRect.size.height * menuType.heightCoefficient
        let buttonSize = CGSize(width: menuSizeWidth * 0.4, height: 80)
        let button = Button(size: buttonSize,
                            delegate: self,
                            identifier: menuType.buttonIdentifer,
                            precedence: precedence)
        button.position = CGPoint(x: 0, y: -buttonSize.height - 175)
        addChild(button)
        
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
            
            for startStop in startStopTarget {
                let fingerSprite = SKSpriteNode(texture: SKTexture(imageNamed: "finger"))
                fingerSprite.size = CGSize(width: 80, height: 80)
                
                let start = startStop.0
                let stop = startStop.1
                
                //initial position
                fingerSprite.position = start
                
                //actions
                let swipeAction = SKAction.move(to: stop, duration: 1.25)
                swipeAction.timingMode = .easeOut
                let resetAction = SKAction.move(to: start, duration: 0.0)
                let instructAction = SKAction.sequence([swipeAction, resetAction])
                
                //adding to scene
                fingerSprite.zPosition = precedence.rawValue
                addChild(fingerSprite)
                fingerSprite.run(SKAction.repeatForever(instructAction))
            }

            
            let paragraphNode = ParagraphNode.labelNode(text: "Swipe like this to rotate the board counter clockwise", paragraphWidth: playableRect.width)
            paragraphNode.position = .zero
            paragraphNode.zPosition = precedence.rawValue
            
            addChild(paragraphNode)
            
        } else {
            let button2 = Button(size: buttonSize,
                                 delegate: self,
                                 identifier: .selectLevel,
                                 precedence: precedence)
            button2.position = CGPoint(x: 0, y: buttonSize.height/2 + 15)
            addChild(button2)
        }
    }
    
    func showRotate(_ frames: [SKTexture]) {
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
        case .resume:
            InputQueue.append(Input(.play))
        case .playAgain:
            InputQueue.append(Input(.playAgain))
        case .selectLevel:
            InputQueue.append(Input(.selectLevel))
        case .rotate:
            //TODO: use the input queue for this?
            self.removeFromParent()
        case .leaveStore, .storeItem:
            fatalError("These buttons dont appear in game")
        }
    }
}
