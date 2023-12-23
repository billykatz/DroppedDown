//
//  ConfirmShuffleView.swift
//  DownFall
//
//  Created by Billy on 11/25/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class ConfirmShuffleView: SKNode {
    
    let containerView: SKSpriteNode
    let canPayTwoHearts: Bool
    let playersGemAmount: Int
    let sprites: [[DFTileSpriteNode]]
    let spriteForeground: SKNode
    let tileSize: CGFloat
    var buttons: [ShiftShaft_Button] = []
    
    init(playableRect: CGRect, canPayTwoHearts: Bool, playersGemAmount: Int, sprites: [[DFTileSpriteNode]], spriteForeground: SKNode, tileSize: CGFloat) {
        containerView = SKSpriteNode(color: .clear, size: playableRect.size)
        self.canPayTwoHearts = canPayTwoHearts
        self.playersGemAmount = playersGemAmount
        self.sprites = sprites
        self.spriteForeground = spriteForeground
        self.tileSize = tileSize
        super.init()
        
        addChild(containerView)
        
        showShuffleConfirmation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showShuffleConfirmation() {
        
        self.isUserInteractionEnabled = true
        self.zPosition = 900_000_000_000
        
        // create the background view
        let blueBackgroundView = SKShapeNode(rectOf: CGSize(width: 780, height: 500), cornerRadius: 24.0)
        blueBackgroundView.lineWidth = 20
        blueBackgroundView.strokeColor = .codexItemStrokeBlue
        blueBackgroundView.fillColor = .menuPurple
        blueBackgroundView.zPosition = -10
        blueBackgroundView.position = CGPoint.position(blueBackgroundView.frame, inside: containerView.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: 40, translatedToBounds: true)
        containerView.addChild(blueBackgroundView)
        
        // create the title "Game Over" or "You frikkin did it!"
        let titleString = "No more moves"
        let title = ParagraphNode(text: titleString, fontColor: .white)
        title.position = CGPoint.position(title.frame, inside: blueBackgroundView.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most, translatedToBounds: true)
        containerView.addChild(title)
        
        let subTitleString = "The Mineral Spirits are offering their services to shuffle the board."
        let subTitleParagraph = ParagraphNode(text: subTitleString, paragraphWidth: blueBackgroundView.frame.width * 0.9, fontSize: 65.0, fontColor: .white, textAlignment: .center)
        subTitleParagraph.position = CGPoint.alignHorizontally(subTitleParagraph.frame, relativeTo: title.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        containerView.addChild(subTitleParagraph)
        
        // create a button that allows the player to view the board
        let buttonSize = CGSize(width: 400, height: 100)
        
        let buttonPayTwoHearts = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .confirmShufflePay2Hearts, precedence: .flying, fontSize: 65.0, fontColor: .black, backgroundColor: .buttonGray)
        buttonPayTwoHearts.zPosition = 10000
        buttonPayTwoHearts.position = CGPoint.alignHorizontally(buttonPayTwoHearts.frame, relativeTo: subTitleParagraph.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.more*4, translatedToBounds: true)
        buttonPayTwoHearts.enable(canPayTwoHearts)
        containerView.addChild(buttonPayTwoHearts)
        
        let buttonPay25PercentGem = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .confirmShufflePay25Percent, precedence: .flying, fontSize: 65.0, fontColor: .black, backgroundColor: .buttonGray)
        buttonPay25PercentGem.zPosition = 10000
        buttonPay25PercentGem.position = CGPoint.alignHorizontally(buttonPay25PercentGem.frame, relativeTo: buttonPayTwoHearts.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        containerView.addChild(buttonPay25PercentGem)
        buttons.append(buttonPayTwoHearts)
        buttons.append(buttonPay25PercentGem)
        
        animate(in: true, waitTime: 0.5, duration: 0.5)
        
    }
    
    
    func animate(in animateIn: Bool, waitTime: Double, duration: Double) {
        var spriteActions: [SpriteAction] = []
        let waitDuration = waitTime
        let animateDuration = duration
        
        for child in containerView.children {
            child.alpha = animateIn ? 0.0 : 1.0
            let targetAlpha: CGFloat = animateIn ? 1.0 : 0.0
            let waitAction = SKAction.wait(forDuration: waitDuration)
            let fadeIn = SKAction.fadeAlpha(to: targetAlpha, duration: animateDuration)
            let waitAndFadeIn = SKAction.sequence(waitAction, fadeIn, curve: .easeIn)
            spriteActions.append(.init(child, waitAndFadeIn))
        }
        
        for sprite in sprites.flatMap({ $0 }) {
            let shake = Animator().shakeNode(node: sprite, duration: 5, ampX: 5, ampY: 5, delayBefore: 0.0, timingMode: .linear)
            let loop = SKAction.repeatForever(shake.action)
            spriteActions.append(.init(sprite, loop))
            
        }
        
        Animator().animate(spriteActions, completion: {})
        
    }
    
    func fadeOut(paidTwoHearts: Bool, paidAmount: Int, completion: @escaping () -> ()) {
        var spriteActions: [SpriteAction] = []
        
        
        if let playerSprite = sprites
            .reduce([], +)
            .filter({ sprite in
                if case TileType.player = sprite.type  {
                    return true
                } else {
                    return false
                }
            }).first {
            
            Animator(foreground: nil, tileSize: tileSize).animatePlayerPayingForBoardShuffle(playerSprite: playerSprite, paidTwoHearts: paidTwoHearts, paidAmount: paidAmount, spriteForeground: spriteForeground) { [containerView] in
                
                let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                fadeOut.timingMode = .easeOut
                
                spriteActions.append(SpriteAction(sprite: containerView, action: fadeOut))
                
                Animator().animate(spriteActions, completion: completion)
            }
            
        } else {
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            fadeOut.timingMode = .easeOut
            
            spriteActions.append(SpriteAction(sprite: containerView, action: fadeOut))
            
            Animator().animate(spriteActions, completion: completion)
        }
        
    }
}

extension ConfirmShuffleView: ButtonDelegate {
    func buttonTapped(_ button: ShiftShaft_Button) {
        for button in buttons {
            button.enable(false)
        }
        var paidTwoHearts: Bool = false
        var paidAmount: Int = 0
        if button.identifier == .confirmShufflePay25Percent {
            paidTwoHearts = false
            paidAmount = Int(Double(playersGemAmount) * 0.25)
        }
        else if button.identifier == .confirmShufflePay2Hearts {
            paidTwoHearts = true
            paidAmount = 2
        }
        
        fadeOut(paidTwoHearts: paidTwoHearts, paidAmount: paidAmount) { [weak self] in
            if button.identifier == .confirmShufflePay25Percent {
                InputQueue.append(Input(.noMoreMovesConfirm(payTwoHearts: false, pay25Percent: true)))
            }
            else if button.identifier == .confirmShufflePay2Hearts {
                InputQueue.append(Input(.noMoreMovesConfirm(payTwoHearts: true, pay25Percent: false)))
            }
            self?.removeFromParent()
        }
    }
}
