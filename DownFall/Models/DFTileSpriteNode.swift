//
//  DFTileSpriteNode.swift
//  DownFall
//
//  Created by Katz, Billy-CW on 12/20/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit
import Foundation

class DFTileSpriteNode: SKSpriteNode {
    var type: TileType
    init(type: TileType, height: CGFloat, width: CGFloat) {
        self.type = type
        switch type {
        case .exit(let blocked):
            if blocked {
                super.init(texture: SKTexture(imageNamed: type.textureString()),
                           color: .clear,
                           size: CGSize(width: width, height: height))
            } else {
                let mineshaft = SKTexture(imageNamed: "mineshaft")
                let tracks = SKTexture(imageNamed: "tracks")
                let minecart = SKTexture(imageNamed: "minecart")
                
                let size = CGSize(width: width, height: height)
                let minecartSize = CGSize(width: width*Style.DFTileSpriteNode.Exit.minecartSizeCoefficient,
                                          height: height*Style.DFTileSpriteNode.Exit.minecartSizeCoefficient)
                super.init(texture: mineshaft,
                           color: .clear,
                           size: size)
                
                let minecartSprite = SKSpriteNode(texture: minecart, size: minecartSize)
                minecartSprite.zPosition = Precedence.foreground.rawValue
                minecartSprite.position = CGPoint.position(this: minecartSprite.frame, centeredInBottomOf: self.frame, verticalPadding: Style.Padding.less)
                minecartSprite.name = "minecart"
                addChild(minecartSprite)
                
                let trackSprite = SKSpriteNode(texture: tracks, size: size)
                trackSprite.zPosition = Precedence.background.rawValue
                addChild(trackSprite)
            }
        case .offer(let offer):
            if offer.hasSpriteSheet, let columns = offer.spriteSheetColumns {
                let spriteSheet = SpriteSheet(texture: SKTexture(imageNamed: offer.textureName), rows: 1, columns: columns)
                
                let firstTexture = spriteSheet.firstTexture()
                
                let animation = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: 0.1)
                let repeatAction = SKAction.repeatForever(animation)
                
                super.init(texture: firstTexture,
                           color: .clear,
                           size: CGSize(width: width*0.75, height: height*0.75))
                
                self.run(repeatAction)
            } else {
                super.init(texture: SKTexture(imageNamed: type.textureString()),
                           color: .clear,
                           size: CGSize(width: width*0.75, height: height*0.75))
            }
        default:
            super.init(texture: SKTexture(imageNamed: type.textureString()),
                       color: .clear,
                       size: CGSize(width: width, height: height))
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("DFTileSpriteNode init?(coder:) is not implemented") }
    
    var isPlayerSprite: Bool {
        return type == .player(.zero)
    }
    
    func removeMinecart() {
        guard case TileType.exit = self.type else { return }
        for child in children {
            if child.name == "minecart" {
                child.removeFromParent()
            }
        }
    }
    
    func showFuseTiming(_ fuseAmount: Int) {
        self.removeChild(with: "dynamiteBackground")
        self.removeChild(with: "dynamiteAmountLabel")
        
        let fontSize: CGFloat = 50
        let amount = fuseAmount
        let fontColor: UIColor = amount <= 1 ? .red : .black
        let background = SKShapeNode(ellipseOf: CGSize(width: self.size.width/2, height: self.size.height/2))
        background.color = .white
        background.zPosition = 100
        
        let xAmountLabel = ParagraphNode(text: "\(amount)", fontSize: fontSize, fontColor: fontColor)
        xAmountLabel.zPosition = 101
        
        background.position = CGPoint.position(background.frame, inside: self.frame, verticalAlign: .center, horizontalAnchor: .center)
        
        xAmountLabel.position = CGPoint.position(xAmountLabel.frame, inside: background.frame, verticalAlign: .center, horizontalAnchor: .center, translatedToBounds: true)
        
        background.name = "dynamiteBackground"
        xAmountLabel.name = "dynamiteAmountLabel"
        self.addChild(background)
        self.addChild(xAmountLabel)
    }
    
    let targetToEatIndicatorName = "TargetToEatIndicator"
    func indicateSpriteWillBeEaten() {
        let indicatorSprite = SKSpriteNode(texture: SKTexture(imageNamed: "target-eat"), size: self.size)
        indicatorSprite.zPosition = Precedence.background.rawValue
        indicatorSprite.alpha = 0.5
        indicatorSprite.name = targetToEatIndicatorName
        self.addChild(indicatorSprite)
    }
    
    func removeTargetToEatIndicator() {
        self.childNode(withName: targetToEatIndicatorName)?.removeFromParent()
    }
    
    /**
     Indicates that attack timing of a sprite
     
     - Parameter frequency:  The frequency of an attack
     - Parameter turns:  The turns until the next attack
     
     */
    
    func showAttackTiming(_ frequency: Int,
                          _ turns: Int) {
        
        let size = CGSize(width: self.frame.width * 0.1, height: frame.height * 0.1)
        
        var previousCircle: SKShapeNode?
        
        var color = UIColor.clear
        if turns == 0 {
            color = .green
        } else if turns == 1 {
            color = .yellow
        } else {
            color = .red
        }
        previousCircle = SKShapeNode(circleOfRadius: size.width)
        previousCircle?.fillColor = color
        previousCircle?.strokeColor = color
        previousCircle?.position = CGPoint.position(previousCircle?.frame, inside: frame, verticalAlign: .bottom, horizontalAnchor: .right)
        previousCircle?.zPosition = Precedence.foreground.rawValue
        addOptionalChild(previousCircle)
        
    }
    
    func showAmount() {
        guard case TileType.item(let item) = self.type else  { return }
        let amount = item.amount

        let fontSize: CGFloat
        let width: CGFloat
        if amount < 10 {
            fontSize = 50
            width = self.size.width*0.45
        } else if amount < 100 {
            fontSize = 48
            width = self.size.width*0.52
        } else {
            fontSize = 46
            width = self.size.width*0.60
        }
        
        let background = SKShapeNode(rectOf: CGSize(width: width, height: self.size.height*0.35), cornerRadius: 16.0)
        background.color = .buttonGray
        background.zPosition = 100
        
        let xAmountLabel = ParagraphNode(text: "x\(amount)", fontSize: fontSize, fontColor: .black)
        xAmountLabel.zPosition = 101
        
        background.position = CGPoint.position(background.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .right)
        
        xAmountLabel.position = CGPoint.position(xAmountLabel.frame, inside: background.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: 4, translatedToBounds: true)
        
        self.addChild(background)
        self.addChild(xAmountLabel)
        
    }
    
    func showOfferTier(_ offer: StoreOffer) {
        let sprite = SKSpriteNode(imageNamed: "Reward\(offer.tier)Border")
        sprite.position = .zero
        sprite.size = self.size.scale(by: 1.33)
//        sprite.alpha = 0.5
        sprite.zPosition = -10
        
        addChild(sprite)
    }
    
    func showFinger() {
        let finger = SKSpriteNode(imageNamed: "finger")
        finger.position = CGPoint.position(this: finger.frame,
                                           centeredInBottomOf: self.frame,
                                           verticalPadding: -Style.Padding.most)
        finger.size = Style.TutorialHighlight.fingerSize
        
        let moveDownVector = CGVector.init(dx: 0.0, dy: -20.0)
        let moveUpVector = CGVector.init(dx: 0.0, dy: 20.0)
        let moveDownAnimation = SKAction.move(by: moveDownVector, duration: Style.TutorialHighlight.fingerTimeInterval)
        let moveUpAnimation = SKAction.move(by: moveUpVector, duration: Style.TutorialHighlight.fingerTimeInterval)
        
        let indicateAnimation = SKAction.repeatForever(SKAction.sequence([moveDownAnimation, moveUpAnimation]))
        finger.run(indicateAnimation)
        finger.zPosition = Precedence.menu.rawValue
        
        self.addChild(finger)
    }
    
    func glow() -> (SKSpriteNode, SKAction)? {
        guard type == TileType.item(.gem)  else { return nil }
        let gemGlow = SKSpriteNode(texture: SKTexture(imageNamed: "crystalGlow"), color: .clear, size: self.size)
        gemGlow.zPosition = Precedence.underground.rawValue
        
        return nil
    }
    
    func poof(_ removeFromParent: Bool = true) -> (SpriteAction)? {
        
        let smokeAnimation = Animator().smokeAnimation
        let remove = SKAction.removeFromParent()
        let sequencedActions: [SKAction] = [smokeAnimation, remove]
        let sequence = SKAction.sequence(sequencedActions)
        
        return SpriteAction(sprite: self, action: sequence)
    }
    
    func pillarCrumble(_ removeFromParent: Bool = true, delayBefore: Double = 0.0) -> (SpriteAction)? {
        var animationFrames: [SKTexture] = []
        switch self.type {
        case .pillar(let data):
            let health = data.health
            switch data.color {
            case .blue, .purple, .red:
                let textureName = "\(data.color.humanReadable.lowercased())Pillar\(health)HealthTakeDamage8"
                animationFrames = SpriteSheet(textureName: textureName, columns: 8).animationFrames()
                
            default:
                return nil
            }
        default:
            return nil
        }

        let animateCrumble = SKAction.animate(with: animationFrames, timePerFrame: 0.07)
        let remove = SKAction.removeFromParent()
        let wait = SKAction.wait(forDuration: delayBefore)
        let sequencedActions: [SKAction] = removeFromParent ? [wait, animateCrumble, remove] : [wait, animateCrumble]
        let sequence = SKAction.sequence(sequencedActions)
        
        return SpriteAction(sprite: self, action: sequence)
    
    }

    
    func crumble(_ removeFromParent: Bool = true, delayBefore: Double = 0.0) -> (SpriteAction)? {
        var animationFrames: [SKTexture] = []
        switch self.type {
        case .rock(.brown, _, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.brownRockCrumble), rows: 1, columns: 4).animationFrames()
        case .rock(.red, _, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.redRockCrumble), rows: 1, columns: 4).animationFrames()
        case .rock(.blue, _, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.blueRockCrumble), rows: 1, columns: 4).animationFrames()
        case .rock(.purple, _, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.purpleRockCrumble), rows: 1, columns: 4).animationFrames()
        default:
            return nil
        }
        
        let animateCrumble = SKAction.animate(with: animationFrames, timePerFrame: 0.08)
        let remove = SKAction.removeFromParent()
        let wait = SKAction.wait(forDuration: delayBefore)
        let sequencedActions: [SKAction] = removeFromParent ? [wait, animateCrumble, remove] : [wait, animateCrumble]
        let sequence = SKAction.sequence(sequencedActions)
        
        return SpriteAction(sprite: self, action: sequence)
    }
    
    func sparkle() -> SKAction? {
        
        var animationFrames: [SKTexture] = []
        switch self.type {
        case .rock(.red, _, _), .rock(.blue, _, _), .rock(.purple, _, _):
            guard let spriteSheet = self.type.sparkleSheetName else { return nil }
            animationFrames = spriteSheet.animationFrames()
        default:
            return nil
        }
        
        let amount = self.type.amountInGroup
        
        /// Wait for a random amount of time
        let waitAction = SKAction.wait(forDuration: TimeInterval(Int.random(lower: 2, upper: 10)),
                                       withRange: TimeInterval(Int.random(lower: 2, upper: 10)))
        
        /// Animate the sparkle
        let animateAction = SKAction.animate(with: animationFrames, timePerFrame: 0.08)
        
        let sequence = SKAction.sequence([waitAction, animateAction])
        
        /// Repeat forever
        let repeatForever = SKAction.repeatForever(sequence)
        
        
        //debug
        if amount > 0 && UserDefaults.standard.bool(forKey: UserDefaults.showGroupNumberKey) {
            let fontSize: CGFloat
            let width: CGFloat
            if amount < 10 {
                fontSize = 50
                width = self.size.width*0.40
            } else if amount < 100 {
                fontSize = 48
                width = self.size.width*0.50
            } else {
                fontSize = 46
                width = self.size.width*0.56
            }

            let background = SKShapeNode(rectOf: CGSize(width: width, height: self.size.height*0.35), cornerRadius: 16.0)
            background.color = .buttonGray
            background.zPosition = 100

            let xAmountLabel = ParagraphNode(text: "\(amount)", fontSize: fontSize, fontColor: .black)
            xAmountLabel.zPosition = 101

            background.position = CGPoint.position(background.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .right)

            xAmountLabel.position = CGPoint.position(xAmountLabel.frame, inside: background.frame, verticalAlign: .center, horizontalAnchor: .center, xOffset: 4, translatedToBounds: true)

            self.addChild(background)
            self.addChild(xAmountLabel)
        }

        return repeatForever
    }
    
    func dyingAnimation(durationWaitBefore: Double = 0.0) -> SpriteAction? {
        switch self.type {
        case .monster(let monsterData):
            switch monsterData.type {
            case .rat, .alamo, .bat, .dragon:
                let animationModel = monsterData.animations.first { $0.animationType == .dying }
                let animationFrames = animationModel?.animationTextures ?? []
                let waitBefore = SKAction.wait(forDuration: durationWaitBefore)
                let animation = SKAction.animate(with: animationFrames, timePerFrame: 0.07)
                var spriteAction: SpriteAction = .init(self, SKAction.sequence([waitBefore, animation]))
                spriteAction.duration = Double(animationFrames.count) * 0.07
                return spriteAction
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}

