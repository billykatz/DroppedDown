//
//  GameRecapView.swift
//  DownFall
//
//  Created by Billy on 11/22/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class GameRecapView: SKNode {
    
    let containerView: SKSpriteNode
    let backgroundOverlayName = "backgroundOverlayName"
    var showBoardButton: ShiftShaft_Button?
    var showRecapButton: ShiftShaft_Button?
    
    init(playableRect: CGRect) {
        containerView = SKSpriteNode(color: .clear, size: playableRect.size)
        
        super.init()
        
        addChild(containerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showGameRecap(win: Bool, killedBy: EntityModel.EntityType?, with statistics: [Statistics]) {
        
        self.isUserInteractionEnabled = true
        self.zPosition = 900_000_000_000
        
        // create the background view
        let blueBackgroundView = SKShapeNode(rectOf: CGSize(width: 780, height: 1100), cornerRadius: 24.0)
        blueBackgroundView.lineWidth = 10
        blueBackgroundView.strokeColor = .codexItemStrokeBlue
        blueBackgroundView.fillColor = .gameRecapBlue
        blueBackgroundView.zPosition = 10
        containerView.addChild(blueBackgroundView)
        
        // create the background overlay view
        let backgroundOverlay = SKSpriteNode(color: .black, size: CGSize(widthHeight: 5000))
        backgroundOverlay.alpha = 0.25
        backgroundOverlay.zPosition = -100000
        backgroundOverlay.name = backgroundOverlayName
        containerView.addChild(backgroundOverlay)
        
        // create the title "Game Over" or "You frikkin did it!"
        let titleString = win ? "You Won" : "Game Over"
        let title = ParagraphNode(text: titleString, fontColor: .white)
        title.position = CGPoint.position(title.frame, inside: blueBackgroundView.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most*2)
        containerView.addChild(title)
        
        // create the you were killed by + icon
        var rectToAlignStats: CGRect = title.frame
        if let killedByTexture = killedBy?.textureString {
            let killedBySprite = SKSpriteNode(texture: SKTexture(imageNamed: killedByTexture), size: CGSize(widthHeight: 150.0))
            let killedByParagraph = ParagraphNode(text: "You were killed by:", fontSize: .fontLargeSize, fontColor: .white)
            
            killedByParagraph.position = CGPoint.alignHorizontally(killedByParagraph.frame, relativeTo: title.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            killedBySprite.position = CGPoint.alignHorizontally(killedBySprite.frame, relativeTo: killedByParagraph.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.normal, translatedToBounds: true)
            containerView.addChild(killedByParagraph)
            containerView.addChild(killedBySprite)
            
            rectToAlignStats = killedBySprite.frame
        }
        
        func createStat(title: String, amount: Int) -> (ParagraphNode, ParagraphNode) {
            let fontSize: CGFloat = 65.0
            let titleNode = ParagraphNode(text: title, fontSize: fontSize, fontColor: .white)
            let amountNode = ParagraphNode(text: "\(amount)", fontSize: fontSize, fontColor: .white)
            return (titleNode, amountNode)
        }
        
        // create the statistics view
        var statNodes: [(ParagraphNode, ParagraphNode)] = []
        for stat in statistics {
            switch stat.statType {
            case .totalRocksDestroyed:
                statNodes.append(createStat(title: "Rocks Mined:", amount: stat.amount))
            case .largestRockGroupDestroyed:
                statNodes.append(createStat(title: "Largest Rock Group:", amount: stat.amount))
            case .totalGemsCollected:
                statNodes.append(createStat(title: "Gems Collected:", amount: stat.amount))
            case .totalRuneUses:
                statNodes.append(createStat(title: "Rune Uses:", amount: stat.amount))
            case .totalMonstersKilled:
                statNodes.append(createStat(title: "Monsters Killed:", amount: stat.amount))
            case .damageTaken:
                statNodes.append(createStat(title: "Damage Taken:", amount: stat.amount))
            case .healthHealed:
                statNodes.append(createStat(title: "Health Healed:", amount: stat.amount))
            default: break
            }
        }
        
        let statTitleHorizontalPadding = CGFloat(75)
        let statAmountHorizontalPadding = CGFloat(125)
        var statTitleAlignNode = SKSpriteNode(color: .clear, size: .fifty)
        statTitleAlignNode.position = CGPoint.alignHorizontally(statTitleAlignNode.frame, relativeTo: rectToAlignStats, horizontalAnchor: .center, verticalAlign: .bottom, horizontalPadding: statTitleHorizontalPadding, translatedToBounds: true)
        var statAmountAlignNode = SKSpriteNode(color: .clear, size: .fifty)
        statAmountAlignNode.position = CGPoint.alignVertically(statAmountAlignNode.frame, relativeTo: statTitleAlignNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: statAmountHorizontalPadding, translatedToBounds: true)
        
        for statNode in statNodes {
            let (title, amount) = statNode
            let verticalPadding = CGFloat(8.0)
            title.position = CGPoint.alignHorizontally(title.frame,
                                                       relativeTo: statTitleAlignNode.frame,
                                                       horizontalAnchor: .right,
                                                       verticalAlign: .bottom,
                                                       verticalPadding: verticalPadding,
                                                       translatedToBounds: true)
            
            amount.position = CGPoint.alignHorizontally(amount.frame,
                                                        relativeTo: statAmountAlignNode.frame,
                                                        horizontalAnchor: .left,
                                                        verticalAlign: .bottom,
                                                        verticalPadding: verticalPadding,
                                                        translatedToBounds:  true)
            
            containerView.addChild(title)
            containerView.addChild(amount)
            
            statTitleAlignNode = title
            statAmountAlignNode = amount
            
        }
        
        // create a button that allows the player to view the board
        let buttonSize = CGSize(width: 300, height: 150)
        let buttonToView = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .gameRecapViewBoard, precedence: .flying, fontColor: .black, backgroundColor: .buttonGray)
        buttonToView.position = CGPoint.alignHorizontally(buttonToView.frame, relativeTo: blueBackgroundView.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: 150)
        showBoardButton = buttonToView
        
        //
        let buttonToShowRecap = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .gameRecapShowRecap, precedence: .flying, fontColor: .black, backgroundColor: .buttonGray)
        buttonToShowRecap.position = CGPoint.alignHorizontally(buttonToView.frame, relativeTo: buttonToView.frame, horizontalAnchor: .center, verticalAlign: .center, translatedToBounds: true)
        buttonToShowRecap.alpha = 0.0
        showRecapButton = buttonToShowRecap
        
        let buttonToExit = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .mainMenu, precedence: .flying, fontColor: .black, backgroundColor: .buttonGray)
        buttonToExit.position = CGPoint.alignHorizontally(buttonToExit.frame, relativeTo: blueBackgroundView.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: -200)
        
        containerView.addChild(buttonToView)
        containerView.addChild(buttonToShowRecap)
        containerView.addChild(buttonToExit)
        
        
    }
    
//    func animateIn() {
//        for child in containerView.children {
//            child.alpha = 0
//        }
//        containerView.alpha = 0
//
//        let appear = SKAction.fadeIn(withDuration: 0.15)
//        let appearGrowShrink = SKAction.group([appear])
//        appearGrowShrink.timingMode = .easeOut
//
//        for child in containerView.children {
//            child.run(appearGrowShrink)
//        }
//
//
//        containerView.run(appearGrowShrink)
//
//        showRecapButton?.alpha = 0
//
//    }
    
    func fadeOut(completion: @escaping () -> ()) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        fadeOut.timingMode = .easeOut
        
        var spriteActions: [SpriteAction] = []
        spriteActions.append(SpriteAction(sprite: containerView, action: fadeOut))
        
        Animator().animate(spriteActions, completion: completion)
    }
        
    
    func toggleBoard(appear: Bool) {
        if appear {
            showBoardButton?.alpha = 0
            showRecapButton?.alpha = 1
        } else {
            showBoardButton?.alpha = 1
            showRecapButton?.alpha = 0
        }
        
        let action: SKAction
        if appear {
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            action = fadeOut
        } else {
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            action = fadeIn
        }
        action.timingMode = .easeOut
        
        var spriteActions: [SpriteAction] = []
        for child in containerView.children {
//            if let child = child as? SKSpriteNode {
            
                if (child == showRecapButton || child == showBoardButton) { continue }
                
                if child.name == backgroundOverlayName {
                    child.alpha = appear ? 0 : 0.25
                    continue
                }
                
                spriteActions.append(.init(child, action))
//            }
        }
        
        Animator().animate(spriteActions, completion: {})
    }
    
}

extension GameRecapView: ButtonDelegate {
    func buttonTapped(_ button: ShiftShaft_Button) {
        if button.identifier == .gameRecapViewBoard {
            toggleBoard(appear: true)
        } else if button.identifier == .mainMenu {
            fadeOut {
                InputQueue.append(Input(.playAgain))
            }
        }  else if button.identifier == .gameRecapShowRecap {
            toggleBoard(appear: false)
        }
    }
}
