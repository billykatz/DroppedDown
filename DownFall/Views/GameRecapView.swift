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
    var showRecapView: SKShapeNode?
    var didWin: Bool = false
    
    init(playableRect: CGRect) {
        containerView = SKSpriteNode(color: .clear, size: playableRect.size)
        
        super.init()
        
        addChild(containerView)
        containerView.position = containerView.position.translateVertically(-10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showGameRecap(win: Bool, killedBy: EntityModel.EntityType?, with statistics: [Statistics]) {
        self.didWin = win
        self.isUserInteractionEnabled = true
        self.zPosition = 900_000_000_000
        
        // create the background view
        let blueBackgroundView = SKShapeNode(rectOf: CGSize(width: 780, height: 1250), cornerRadius: 24.0)
        blueBackgroundView.lineWidth = 10
        blueBackgroundView.strokeColor = .codexItemStrokeBlue
        blueBackgroundView.fillColor = .gameRecapBlue
        blueBackgroundView.zPosition = 10
        containerView.addChild(blueBackgroundView)
        
        // create the background overlay view
        let backgroundOverlay = SKSpriteNode(color: .black, size: CGSize(widthHeight: 5000))
        backgroundOverlay.alpha = 0.75
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
            let killedBySprite: SKSpriteNode
            //TODO: make it show you the boss that killed you
            if killedByTexture == "lavaHorse" {
                let scaleFactor = 1.5
                let width = 280 * scaleFactor
                let height = 112 * scaleFactor
                killedBySprite = SKSpriteNode(texture: SKTexture(imageNamed: "boss-game-recap-sprite"), size: CGSize(width: width, height: height))
            } else {
                killedBySprite = SKSpriteNode(texture: SKTexture(imageNamed: killedByTexture), size: CGSize(widthHeight: 150.0))
            }
            let killedByParagraph = ParagraphNode(text: "You were killed by:", fontSize: .fontLargeSize, fontColor: .white)
            
            killedByParagraph.position = CGPoint.alignHorizontally(killedByParagraph.frame, relativeTo: title.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            killedBySprite.position = CGPoint.alignHorizontally(killedBySprite.frame, relativeTo: killedByParagraph.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            containerView.addChild(killedByParagraph)
            containerView.addChild(killedBySprite)
            
            rectToAlignStats = killedBySprite.frame
        } else if win {
            // show a defeated boss
            let scaleFactor = 1.5
            let width = 280 * scaleFactor
            let height = 112 * scaleFactor
            let bossSprite = SKSpriteNode(texture: SKTexture(imageNamed: "boss-game-recap-sprite"), size: CGSize(width: width, height: height))
            let youDefeatedParagraph = ParagraphNode(text: "You defeated:", fontSize: .fontLargeSize, fontColor: .white)
            
            let spriteSheet = SpriteSheet(textureName: "boss-game-recap-sprite-sheet-12", columns: 12).animationFrames()
            let animate = SKAction.animate(with: spriteSheet, timePerFrame: 0.07)
            let repeatForever = SKAction.repeatForever(animate)
            bossSprite.run(repeatForever)

            youDefeatedParagraph.position = CGPoint.alignHorizontally(youDefeatedParagraph.frame, relativeTo: title.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.more*2, translatedToBounds: true)
            bossSprite.position = CGPoint.alignHorizontally(bossSprite.frame, relativeTo: youDefeatedParagraph.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
            containerView.addChild(youDefeatedParagraph)
            containerView.addChild(bossSprite)

            rectToAlignStats = bossSprite.frame
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
        statTitleAlignNode.position = CGPoint.alignHorizontally(statTitleAlignNode.frame, relativeTo: rectToAlignStats, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: -10, horizontalPadding: statTitleHorizontalPadding, translatedToBounds: true)
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
        let buttonSize = CGSize(width: 300, height: 130)
        let buttonToView = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .gameRecapViewBoard, precedence: .flying, fontColor: .black, backgroundColor: .buttonGray)
        buttonToView.position = CGPoint.position(buttonToView.frame, inside: blueBackgroundView.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: 32.0, translatedToBounds: true)
        showBoardButton = buttonToView
        
        //
        
        let buttonToShowRecapBackground = SKShapeNode(rectOf: CGSize(width: 780, height: 175), cornerRadius: 24.0)
        buttonToShowRecapBackground.lineWidth = 10
        buttonToShowRecapBackground.strokeColor = .codexItemStrokeBlue
        buttonToShowRecapBackground.fillColor = .gameRecapBlue
        buttonToShowRecapBackground.zPosition = 0
        buttonToShowRecapBackground.position = CGPoint.alignHorizontally(buttonToShowRecapBackground.frame, relativeTo: buttonToView.frame, horizontalAnchor: .center, verticalAlign: .center, translatedToBounds: true)
        buttonToShowRecapBackground.alpha = 0.0
        self.showRecapView = buttonToShowRecapBackground
        containerView.addChild(buttonToShowRecapBackground)
        
        let buttonToShowRecap = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .gameRecapShowRecap, precedence: .flying, fontColor: .black, backgroundColor: .buttonGray)
        buttonToShowRecap.zPosition = 10000
        buttonToShowRecapBackground.addChild(buttonToShowRecap)
        showRecapButton = buttonToShowRecap
        
        let buttonToExit = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .mainMenu, precedence: .flying, fontColor: .black, backgroundColor: .buttonGray)
        buttonToExit.position = CGPoint.alignHorizontally(buttonToExit.frame, relativeTo: buttonToView.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.most, translatedToBounds: true)
        
        containerView.addChild(buttonToView)
        containerView.addChild(buttonToExit)
        
        animate(in: true, waitTime: 0.75, duration: 0.75)
        
        
    }
    
    
    func animate(in animateIn: Bool, waitTime: Double, duration: Double) {
        var spriteActions: [SpriteAction] = []
        let waitDuration = waitTime
        let animateDuration = duration
        
        for child in containerView.children {
            if (child == showRecapView) {
                child.alpha = 0.0
            } else {
                child.alpha = animateIn ? 0.0 : 1.0
            }
            let targetAlpha: CGFloat
            let waitAction: SKAction
            if child.name == backgroundOverlayName {
                targetAlpha = animateIn ? 0.75 : 0.0
                waitAction = SKAction.wait(forDuration: 0.0)
            } else {
                targetAlpha = animateIn ? 1.0 : 0.0
                waitAction = SKAction.wait(forDuration: waitDuration)
            }
            
            
            if (child == showRecapView) {
                showRecapButton?.alpha = 1.0
                let recapViewTargetAlpha: CGFloat = animateIn ? 0.0 : 1.0
                let fadeTo = SKAction.fadeAlpha(to: recapViewTargetAlpha, duration: animateDuration)
                let waitAndFadeIn = SKAction.sequence(waitAction, fadeTo, curve: .easeIn)
                spriteActions.append(.init(child, waitAndFadeIn))
            } else {
                let fadeIn = SKAction.fadeAlpha(to: targetAlpha, duration: animateDuration)
                let waitAndFadeIn = SKAction.sequence(waitAction, fadeIn, curve: .easeIn)
                spriteActions.append(.init(child, waitAndFadeIn))
            }
            
        }
        
        Animator().animate(spriteActions, completion: {})
        
    }
    
    func fadeOut(completion: @escaping () -> ()) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        fadeOut.timingMode = .easeOut
        
        var spriteActions: [SpriteAction] = []
        spriteActions.append(SpriteAction(sprite: containerView, action: fadeOut))
        
        Animator().animate(spriteActions, completion: completion)
    }
    
    
    func toggleRecapeView(appear: Bool) {
        animate(in: appear, waitTime: 0.0, duration: 0.25)
    }
    
}

extension GameRecapView: ButtonDelegate {
    func buttonTapped(_ button: ShiftShaft_Button) {
        if button.identifier == .gameRecapViewBoard {
            toggleRecapeView(appear: false)
        }
        else if button.identifier == .gameRecapShowRecap {
            toggleRecapeView(appear: true)
        }
        else if button.identifier == .mainMenu {
            fadeOut {
                InputQueue.append(Input(.playAgain(didWin: self.didWin)))
            }
        }
    }
}
