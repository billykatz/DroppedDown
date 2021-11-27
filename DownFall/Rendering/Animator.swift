//
//  Animator.swift
//  DownFall
//
//  Created by William Katz on 9/15/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

struct NumberTextures {
    let number: Int
    let color: ShiftShaft_Color
    let texture: SKTexture
}

struct Animator {
    
    struct Constants {
        static let poisonDropSpriteName = "poison-drop"
        static let poisonDropSpriteSheetName = "poison-drop-sprite-sheet-8"
    }
    
    lazy var numberTextures: [NumberTextures] = {
        var array: [NumberTextures] = []
        for number in [1, 2, 3] {
            for color in [ShiftShaft_Color.red, .blue, .purple] {
                let entry = NumberTextures(number: number, color: color, texture: SKTexture(imageNamed: "number-\(number)-\(color.humanReadable.lowercased())"))
                array.append(entry)
            }
        }
        return array
    }()
    
    let foreground: SKNode?
    
    init(foreground: SKNode? = nil) {
        self.foreground = foreground
    }
    
    func shakeScreen(duration: CGFloat = 0.5, ampX: Int = 10, ampY: Int = 10, delayBefore: Double = 0) -> SpriteAction? {
        guard let foreground = foreground else { return nil }
        let action = SKAction.shake(duration: duration, amplitudeX: ampX, amplitudeY: ampY)
        let delay = SKAction.wait(forDuration: delayBefore)
        
        return .init(foreground, .sequence(delay, action, curve: .easeIn))
    }
    
    func shakeNode(node: SKNode, duration: CGFloat = 0.5, ampX: Int = 10, ampY: Int = 10, delayBefore: Double = 0, timingMode: SKActionTimingMode = .easeIn) -> SpriteAction {
        let action = SKAction.shake(duration: duration, amplitudeX: ampX, amplitudeY: ampY)
        let delay = SKAction.wait(forDuration: delayBefore)
        
        return .init(node, .sequence(delay, action, curve: timingMode))
    }

    
    
    public func animateRune(_ rune: Rune,
                            transformations: [Transformation],
                            affectedTiles: [TileCoord],
                            sprites: [[DFTileSpriteNode]],
                            spriteForeground: SKNode,
                            completion: (() -> ())? = nil) {
        let runeAnimation = SpriteSheet(texture: rune.animationTexture, rows: 1, columns: rune.animationColumns)
        guard let endTiles = transformations.first?.endTiles else {
            completion?()
            return
        }
        
        guard let tileTransformation = transformations.first?.tileTransformation else {
            completion?()
            return
        }

        
        switch rune.type {
        case .getSwifty:
            var spriteActions: [SpriteAction] = []
            for tileTrans in tileTransformation {
                let start = tileTrans.initial
                let end = tileTrans.end
                let endPosition = sprites[end.row][end.column].position
                let runeAnimationAction = SKAction.animate(with: runeAnimation.animationFrames(), timePerFrame: 0.07)
                let moveAction = SKAction.move(to: endPosition, duration: 0.07)
                
                let runeAndMoveAnimation = SKAction.group([runeAnimationAction, moveAction])
                let spriteAction = SpriteAction(sprite: sprites[start.row][start.column], action: runeAndMoveAnimation)
                spriteActions.append(spriteAction)
            }
        animate(spriteActions) { completion?() }
        
 
            
        case .rainEmbers, .fireball:
                       
            var spriteActions: [SpriteAction] = []
            guard let pp = getTilePosition(.player(.playerZero), tiles: endTiles) else {
                completion?()
                return
            }
            
            for target in affectedTiles {
                let horizontalDistane = pp.distance(to: target, along: .horizontal)
                let verticalDistane = pp.distance(to: target, along: .vertical)
                let distance = CGFloat.hypotenuseDistance(sideALength: CGFloat(horizontalDistane), sideBLength: CGFloat(verticalDistane))
                
                let duration = Double(distance * 0.1)
                let angle = CGFloat.angle(sideALength: CGFloat(horizontalDistane),
                                          sideBLength: CGFloat(verticalDistane))
                
                let fireballAction = SKAction.repeat(SKAction.animate(with: runeAnimation.animationFrames(), timePerFrame: 0.07), count: Int(duration * 0.07))
                
                let xDistance = CGFloat(pp.totalDistance(to: target, along: .horizontal))
                let yDistance = CGFloat(pp.totalDistance(to: target, along: .vertical))
                
                let rotateAngle = CGFloat.rotateAngle(startAngle: .pi*3/2, targetAngle: angle, xDistance: xDistance, yDistance: yDistance)
                
                
                let moveAction = SKAction.move(to:sprites[target.row][target.column].position, duration: duration)
                let rotateAction = SKAction.rotate(byAngle: rotateAngle, duration: 0)
                let combinedAction = SKAction.group([fireballAction, moveAction])
                let removeAction = SKAction.removeFromParent()
                
                let sequencedActions = SKAction.sequence([
                    rotateAction,
                                                          combinedAction,
                                                          smokeAnimation(),
                                                          removeAction])
                
                let fireballSpriteContainer = SKSpriteNode(color: .clear,
                                                           size: sprites[target.row][target.column].size)
                
                
                //start the fireball from the player
                fireballSpriteContainer.position = sprites[pp.row][pp.column].position
                fireballSpriteContainer.zPosition = Precedence.flying.rawValue
                spriteForeground.addChild(fireballSpriteContainer)
                spriteActions.append(SpriteAction(sprite: fireballSpriteContainer, action: sequencedActions))
                
            }
            
            animate(spriteActions) { completion?() }

        case .transformRock:
            var spriteActions: [SpriteAction] = []
            for tileTrans in tileTransformation {
                let start = tileTrans.initial
                let runeAnimationAction = SKAction.animate(with: runeAnimation.animationFrames(), timePerFrame: 0.07)
                
                let spriteAction = SpriteAction(sprite: sprites[start.row][start.column], action: runeAnimationAction)
                spriteActions.append(spriteAction)
            }
            animate(spriteActions) { completion?() }

        case .bubbleUp:
            var spriteActions: [SpriteAction] = []
            
            let bubbleSprite = SKSpriteNode(imageNamed: "bubble")
            
            guard let originalPlayerPosition = affectedTiles.first else {
                completion?()
                return
            }
            let playerSprite = sprites[originalPlayerPosition]
            
            // player is taller than wide, so use the player's height as width and height of bubble
            bubbleSprite.size = CGSize(width: playerSprite.size.height, height: playerSprite.size.height)
            bubbleSprite.alpha  = 0.25
            playerSprite.addChild(bubbleSprite)
            

            if let targetPlayerCoord = getTilePosition(.player(.playerZero), tiles: transformations.first!.endTiles!) {
                let position = sprites[targetPlayerCoord].position
                let floatUpAction = SKAction.move(to: position, duration: 1.0)
                floatUpAction.timingMode = .easeInEaseOut
                
                spriteActions.append(SpriteAction(sprite: playerSprite, action: floatUpAction))
                
            }
            
            animate(spriteActions) { completion?() }
        case .flameWall, .flameColumn:
            var spriteActions: [SpriteAction] = []
            for coord in affectedTiles {
                let tileSprite = sprites[coord]
                
                let emptySprite = SKSpriteNode(imageNamed: "empty")
                emptySprite.size = tileSprite.size
                emptySprite.position = tileSprite.position
                emptySprite.zPosition = tileSprite.zPosition + 1
                
                /// add the sprite to the scene
                spriteForeground.addChild(emptySprite)
                
                /// do the animation
                let runeAnimationAction = SKAction.animate(with: runeAnimation.animationFrames(), timePerFrame: 0.07)
                
                // remove the sprite from the scene
                let removeAction = SKAction.removeFromParent()
                let sequence = SKAction.sequence([runeAnimationAction, runeAnimationAction.reversed(), removeAction])
                
                let spriteAction = SpriteAction(sprite: emptySprite, action: sequence)
                spriteActions.append(spriteAction)
            }
            animate(spriteActions) { completion?() }
        case .vortex:
            var spriteActions: [SpriteAction] = []
            for tileCoord in affectedTiles {
                let runeAnimationAction = SKAction.animate(with: runeAnimation.animationFrames(), timePerFrame: 0.07)
                
                let spriteAction = SpriteAction(sprite: sprites[tileCoord], action: runeAnimationAction)
                spriteActions.append(spriteAction)
            }
            animate(spriteActions) { completion?() }

        default: break
        }
    }
    
    public var poisonDropAnimation: SKAction {
        let posionTexture = SpriteSheet(texture: SKTexture(imageNamed: Constants.poisonDropSpriteSheetName), rows: 1, columns: 8).animationFrames()
        let poisonAnimation = SKAction.animate(with: posionTexture, timePerFrame: 0.07)
        return poisonAnimation
    }

    
    
    public func smokeAnimation() -> SKAction {
        let smokeTexture = SpriteSheet(texture: SKTexture(imageNamed: "smokeAnimation"), rows: 1, columns: 6).animationFrames()
        let smokeAnimation = SKAction.animate(with: smokeTexture, timePerFrame: 0.07)
        return smokeAnimation
    }
    
    public func explodeAnimation(size: CGSize) -> SKAction {
        let explodeTexture = SpriteSheet(texture: SKTexture(imageNamed: "explodeAnimation"), rows: 1, columns: 4).animationFrames()
        let explodeAnimation = SKAction.animate(with: explodeTexture, timePerFrame: 0.07)
        let scaleToSize = SKAction.scale(to: size, duration: 0.0)
        return SKAction.group([scaleToSize, explodeAnimation])
    }
    
    func timePerFrame() -> Double {
        return 0.07
    }
    
    func projectileTimePerFrame(for monsterType: EntityModel.EntityType) -> Double {
        switch monsterType {
        case .alamo:
            return 0.03
        case .dragon:
            return 0.1
        default:
            return 0.07
        }
    }
    
    func projectileKeyFrame(for entity: EntityModel, index: Int) -> Double {
        switch entity.type {
        case .dragon:
            var duration: Double = 0
            if index >= 0 {
                if let keyframes = entity.keyframe(of: .attack) {
                    duration += Double(keyframes)
                }
            }
            if index >= 1 {
                if let keyframes = entity.keyframe(of: .projectileStart) {
                    duration += Double(keyframes)
                }
            }
            if index >= 2 {
                if let midKeyFrame = entity.keyframe(of: .projectileMid) {
                    duration += Double(midKeyFrame*index)
                }
            }
            return duration
        case .alamo:
            var duration: Double = 0
            if index >= 0, let keyframes = entity.keyframe(of: .attack) {
                duration += Double(keyframes)
            }
            if index >= 1, let keyframe = entity.keyframe(of: .projectileStart) {
                duration += Double(keyframe * index)
            }
            return duration
        default:
            return 0
        }
        
    }
    
    func gameWin(transformation: Transformation?,
                 sprites: [[DFTileSpriteNode]],
                 completion: (() -> Void)? = nil) {
        guard let transformation = transformation,
            let playerWinTransformation = transformation.tileTransformation?.first else {
                completion?()
                return
        }
        
        let exitSprite = sprites[playerWinTransformation.end]
        exitSprite.removeMinecart()
        let playerSprite = sprites[playerWinTransformation.initial]
        playerSprite.removeFromParent()
        
        let minecart = SKSpriteNode(imageNamed: "minecart")
        minecart.size = exitSprite.size.scale(by: Style.DFTileSpriteNode.Exit.minecartSizeCoefficient)
        minecart.zPosition = Precedence.foreground.rawValue
        minecart.position = CGPoint.position(minecart.frame, inside: exitSprite.frame, verticalAnchor: .center, horizontalAnchor: .center)
        
        let playerWin = SKSpriteNode(imageNamed: "playerWin")
        playerWin.size = exitSprite.size.scale(by: Style.DFTileSpriteNode.Exit.minecartSizeCoefficient)
        playerWin.zPosition = Precedence.foreground.rawValue
        playerWin.position = .zero
        
        minecart.addChild(playerWin)
        
        exitSprite.addChild(minecart)
        
        let shrinkAnimation = SKAction.scale(to: AnimationSettings.WinSprite.shrinkCoefficient, duration: 1.0)
        let moveVector = AnimationSettings.WinSprite.moveVector
        let moveAnimation = SKAction.move(by: moveVector, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        
        
        minecart.run(SKAction.sequence([SKAction.group([shrinkAnimation, moveAnimation]), removeAction])) {
            completion?()
        }
    }
    
    func animateCollectRune(runeSprite: SKSpriteNode, targetPosition: CGPoint, completion: @escaping () -> Void) {
        
        
        runeSprite.zPosition = 10_000_000
        
        let moveToAction = SKAction.move(to: targetPosition, duration: AnimationSettings.Board.runeGainSpeed)
        let scaleAction = SKAction.scale(to: Style.Board.runeGainSizeEnd, duration: AnimationSettings.Board.runeGainSpeed)
        let scaleUp = SKAction.scale(by: 1.25, duration: 0.25)
        let moveToAndScale = SKAction.group([moveToAction, scaleAction])
        let moveAwayMoveToScale = SKAction.sequence([scaleUp, moveToAndScale])
        
        moveAwayMoveToScale.timingMode = .easeOut
        
        let finalizedAction = SKAction.sequence([moveAwayMoveToScale, .removeFromParent()])
        
        animate([SpriteAction(sprite: runeSprite, action: finalizedAction)], completion: completion)
    }

    
    func animateCollectOffer(offerType: StoreOfferType,  offerSprite: SKSpriteNode, targetPosition: CGPoint, to hud: HUD, updatedPlayerData: EntityModel, completion: @escaping () -> Void) {
        
        let moveToAction = SKAction.move(to: targetPosition, duration: AnimationSettings.Board.goldGainSpeedEnd)
        let scaleAction = SKAction.scale(to: Style.Board.goldGainSizeEnd, duration: AnimationSettings.Board.goldGainSpeedEnd)
        let scaleUp = SKAction.scale(by: 1.25, duration: 0.25)
        let moveToAndScale = SKAction.group([moveToAction, scaleAction])
        let moveAwayMoveToScale = SKAction.sequence([scaleUp, moveToAndScale])
        
        moveAwayMoveToScale.timingMode = .easeOut
        
        let hudAction = SKAction.run {
            hud.incrementStat(offer: offerType, updatedPlayerData: updatedPlayerData)
        }
        
        let hudActionRemoveFromparent = SKAction.group([hudAction, .removeFromParent()])
        
        let finalizedAction = SKAction.sequence([moveAwayMoveToScale, hudActionRemoveFromparent])
        
        animate([SpriteAction(sprite: offerSprite, action: finalizedAction)], completion: completion)
    }
    
    func animateGold(goldSprites: [SKSpriteNode], gained: Int, from startPosition: CGPoint, to targetPosition: CGPoint, in hud: HUD, completion: @escaping () -> Void) {
        var index = 0
        
        var moveToSpeedGain = 0.001
        var goldSpeedGain = 0.0001
        
        let animations: [SpriteAction] = goldSprites.map { sprite in
            let waitDuration = max(0.01, (Double(index) * (AnimationSettings.Board.goldWaitTime - goldSpeedGain)))
            let wait = SKAction.wait(forDuration: waitDuration)
            let toPosition = sprite.frame.center.translate(xOffset: CGFloat.random(in: AnimationSettings.Gem.randomXOffsetRange), yOffset: CGFloat.random(in: AnimationSettings.Gem.randomYOffsetRange))
            
            let moveAwayAction = SKAction.move(to: toPosition, duration: 0.5)
            
            let totalMoveAndScaleDuration = max(0.1, AnimationSettings.Board.goldGainSpeedEnd - moveToSpeedGain)
            let moveToAction = SKAction.move(to: targetPosition, duration: totalMoveAndScaleDuration)
            let scaleAction = SKAction.scale(to: Style.Board.goldGainSizeEnd, duration: totalMoveAndScaleDuration)
            
            let moveToAndScale = SKAction.group([moveToAction, scaleAction])
            let moveAwayMoveToScale = SKAction.sequence([moveAwayAction, moveToAndScale])
            
            moveAwayMoveToScale.timingMode = .easeOut
            
            let tickUpHudCounter = SKAction.run { [index] in
                hud.incrementCurrencyCountByOne()
                 
                if index == goldSprites.count/2 {
                    hud.showTotalGemGain(goldSprites.count)
                }
            }
            
            moveToSpeedGain += 0.001
            goldSpeedGain += 0.001
            index += 1
            
            return SpriteAction(sprite: sprite, action: SKAction.sequence([wait, moveAwayMoveToScale, tickUpHudCounter, SKAction.removeFromParent()]))
        }
        
        animate(animations, completion: completion)
    }
    
    func animateCannotMineRock(sprites: [SKSpriteNode], completion: @escaping () -> Void) {
        
        var actions: [SpriteAction] = []
        for sprite in sprites {
            let rotateCounterClockwise = SKAction.rotate(toAngle: -1/4 * .pi, duration: AnimationSettings.wiggleSpeed)
            let rotateClockwise = SKAction.rotate(toAngle: 1/4 * .pi, duration: AnimationSettings.wiggleSpeed)
            
            let wiggle = SKAction.sequence([rotateCounterClockwise, rotateClockwise])
            let wiggleFourTimes = SKAction.repeat(wiggle, count: 3)
            
            actions.append(SpriteAction(sprite: sprite, action: wiggleFourTimes))
        }
        
        animate(actions, completion: completion)
    }
    
    func animateMoveGrowShrinkExplode(sprite: SKSpriteNode, to target: CGPoint, tileSize: CGFloat, completion: @escaping () -> Void) {
        
        let moveAction = SKAction.move(to: target, duration: 1.0)
        
        /// grow animation
        let growAction = SKAction.scale(by: 4, duration: 0.5)
        let shrinkAction = SKAction.scale(by: 0.25, duration: 0.5)
        let growSkrinkSequence = SKAction.sequence([growAction, shrinkAction])
        
        let moveGrowShrink = SKAction.group([moveAction, growSkrinkSequence])
        
        /// smoke animation
        let increaseSize = SKAction.scale(to: CGSize(width: tileSize, height: tileSize), duration: 0)
        let smokeAnimation = smokeAnimation()
        let increaseSmoke = SKAction.sequence([increaseSize, smokeAnimation])
        
        /// remove it
        let removeAnimation = SKAction.removeFromParent()
        
        // run it in sequence
        let sequence = SKAction.sequence([moveGrowShrink, increaseSmoke, removeAnimation])
        
        animate([SpriteAction(sprite: sprite, action: sequence)], completion: completion)
    }
    
    func createAnimationCompletingGoals(sprite: SKSpriteNode, to targetPosition: CGPoint) -> SpriteAction {
        let scaleUp = CGFloat.random(in: 1.2...1.5)
        let scaleDownRange = CGFloat.random(in: 0.2...0.4)
        
        let scaleUpAction = SKAction.scale(by: scaleUp, duration: AnimationSettings.Board.workingTowardsGoal/4)
        scaleUpAction.timingMode = .easeIn
        let scaleDown = SKAction.scale(by: scaleDownRange, duration: AnimationSettings.Board.workingTowardsGoal/4*3)
        scaleDown.timingMode = .easeIn
        
        let moveToAction = SKAction.move(to: targetPosition, duration: Double.random(in: AnimationSettings.Board.workingTowardsGoal-0.15...AnimationSettings.Board.workingTowardsGoal+0.15))
        moveToAction.timingMode = .easeIn
        
        let changeZPosition = SKAction.run {
            sprite.zPosition = -100_000
        }
        
        let moveToAndScale = SKAction.group([moveToAction, scaleDown])
        let sequence = SKAction.sequence([scaleUpAction, moveToAndScale, changeZPosition])
        
        return SpriteAction(sprite: sprite, action: sequence)

    }
    
    mutating func createAnimationForMiningGems(from coords: [TileCoord], tilesWithGems: [TileCoord], color: ShiftShaft_Color, spriteForeground: SKNode, amountPerRock: Int, tileSize: CGFloat, positionConverter: (TileCoord) -> CGPoint) -> [SpriteAction] {
        guard !tilesWithGems.isEmpty else { return  [] }
        var spriteActions: [SpriteAction] = []
        let numberFontSize: CGFloat = 85.0
        var whiteOutGemBaseSize = CGSize(width: tileSize, height: tileSize)
        
        let waitTimeDurationPerRock = 0.1
        var waitTimeSubtractEachLoop = 0.01
        let minWaitTime = 0.01
        
        let numberOfGemsPerRock = numberOfGemsPerRockForGroup(size: coords.count)

        
        for tileWithGemCoord in tilesWithGems {
            
            // adds a white out version of the gem to create the formation effect
            let whiteOutGem = SKSpriteNode(texture: SKTexture(imageNamed: "\(color.humanReadable.lowercased())-gem-whiteout"), size: CGSize(width: tileSize, height: tileSize))
            
            whiteOutGem.position = positionConverter(tileWithGemCoord)
            whiteOutGem.zPosition = 100_000_000
            spriteForeground.addChild(whiteOutGem)
            
            let numberOnGem = ParagraphNode(text: "", fontSize: numberFontSize, fontColor: .black)
            let numberOnGemName = "\(tileWithGemCoord.x)-\(tileWithGemCoord.y)"
            numberOnGem.name = numberOnGemName
            numberOnGem.zPosition = 100_000_001
            numberOnGem.position = numberOnGem.position.translateVertically(5)
            whiteOutGem.addChild(numberOnGem)
            
            // we need to add the gem to the board or else shit is weird
            let sprite = DFTileSpriteNode(type: .item(Item(type: .gem, amount: 0, color: color)), height: 100, width: 100)
            let targetPosition = positionConverter(tileWithGemCoord)
            sprite.position = targetPosition
            
            var total = 0
            var waitTime = 0.0
            
            for (index, coord) in coords.enumerated() {
                // update total before be do anything else
                total += numberOfGemsPerRock
                
                
                // create the empty sprite
                let texture = numberTextures.first(where: { $0.number == amountPerRock && $0.color == color })!.texture
                let numberSprite = SKSpriteNode(texture: texture, size: CGSize(width: 16, height: 16))
                
                // start position
                let startPosition = positionConverter(coord)
                
                // setup empty sprite
                numberSprite.position = startPosition
                numberSprite.zPosition = 100_000
                spriteForeground.addChild(numberSprite)
                
                // wait the right amount of time
                let initialWait = SKAction.wait(forDuration: waitTime)
                
                // move up and grow
                let moveAndScaleSpeed = 0.3
                let moveUp = SKAction.moveBy(x: 0, y: 150.0, duration: moveAndScaleSpeed)
                let grow = SKAction.scale(to: CGSize(width: 125, height: 125), duration: moveAndScaleSpeed)
                let growAndMove = SKAction.group([grow, moveUp])
                
                let pauseDuration = 0.6
                let pauseToAnimate = SKAction.wait(forDuration: pauseDuration)
                
                
                // more to and shrink
                let moveAndShrinkSpeed = 0.1
                let moveTo = SKAction.move(to: targetPosition, duration: moveAndShrinkSpeed)
                let shrinkIt = SKAction.scale(to: .zero, duration: moveAndShrinkSpeed)
                let moveAndShirnk = SKAction.group([moveTo, shrinkIt])
                
                
                // increase the number on gem node
                let increaseAction = SKAction.run { [total] in
                    guard let oldNumberOnGemLabel = whiteOutGem.childNode(withName: numberOnGemName) else { return }
                    
                    let newNode = ParagraphNode(text: "\(total)", fontSize: numberFontSize, fontColor: .black)
                    newNode.position = oldNumberOnGemLabel.position
                    newNode.name = oldNumberOnGemLabel.name
                    newNode.zPosition = oldNumberOnGemLabel.zPosition
                    oldNumberOnGemLabel.removeFromParent()
                    whiteOutGem.addChild(newNode)
                    
                }
                

                
                let movementAndScaling = SKAction.sequence([growAndMove, initialWait, pauseToAnimate, moveAndShirnk, increaseAction])
                movementAndScaling.timingMode = .easeIn
                
                let animateWhileMovingAndScaling = SKAction.group([movementAndScaling])
                
                spriteActions.append(SpriteAction(sprite: numberSprite, action: animateWhileMovingAndScaling))
                
                // max out at 400 by 400
                whiteOutGemBaseSize = min(CGSize(width: 400, height: 400), whiteOutGemBaseSize.scale(by: 1 + (CGFloat(index+1) * 0.005)))
                let growTheWhiteOutGem = SKAction.scale(to: whiteOutGemBaseSize.scale(by: 1.1), duration: 0.1)
                let shrinkTheWhiteOutGem = SKAction.scale(to: whiteOutGemBaseSize.scale(by:5/6), duration: 0.1)
                let makewhiteOutGemOriginalSize = SKAction.scale(to: whiteOutGemBaseSize, duration: 0.05)
                // initialWait + moveAndScaleSpeed + pauseToAnimate + moveAndShirnkSpeed
                // we need to make space at the end of the period to give the gem time to animate
                // thus we subtract 1x the waitTimeduratio
                let waitUntilNumberTicksUpDuration = waitTime + moveAndScaleSpeed + pauseDuration + moveAndShrinkSpeed - waitTimeDurationPerRock
                let whiteOutGemWait = SKAction.wait(forDuration: waitUntilNumberTicksUpDuration)
                let whiteOutGemAction = SKAction.sequence([whiteOutGemWait, growTheWhiteOutGem, shrinkTheWhiteOutGem, makewhiteOutGemOriginalSize])
                
                spriteActions.append(SpriteAction(sprite: whiteOutGem, action: whiteOutGemAction))
                
                
                /// make sure we dont go negative
                waitTime += max(minWaitTime, waitTimeDurationPerRock - waitTimeSubtractEachLoop)
                waitTimeSubtractEachLoop += 0.005
            }
            
            
            // wait before doing these actions
            let wait = SKAction.wait(forDuration: waitTime + 0.9)
            
            // scale up one more time
            let scaleOut = SKAction.scale(to: whiteOutGemBaseSize.scale(by: 1.5), duration: 0.45)
            
            // wiggle with it
            let rotateCounterClockwise = SKAction.rotate(toAngle: -1/32 * .pi, duration: 0.05)
            let rotateClockwise = SKAction.rotate(toAngle: 1/32 * .pi, duration: 0.05)
            let rotateBack = SKAction.rotate(toAngle: 0, duration: 0.05)
            
            let wiggle = SKAction.sequence([rotateCounterClockwise, rotateClockwise])
            let wiggleFourTimes = SKAction.repeat(wiggle, count: 3)
            let wiggleThenBack = SKAction.sequence([wiggleFourTimes, rotateBack])
            
            let scaleUpAndWiggle = SKAction.group([scaleOut, wiggleThenBack])
            
            // reset the base size
            whiteOutGemBaseSize = CGSize(width: tileSize, height: tileSize)

            // scale the whole thing down
            let scaleNumberAction = SKAction.scale(to: CGSize(width: tileSize*0.4, height: tileSize*0.4), duration: 0.33)
            
            // target and move the gem sprite to the bottom right
            let background = SKShapeNode(rectOf: CGSize(width: tileSize*0.5, height: tileSize*0.40), cornerRadius: 16.0)
            let numberTargetPosition = CGPoint.position(background.frame, inside: whiteOutGem.frame, verticalAlign: .bottom, horizontalAnchor: .right, translatedToBounds: true)
            let moveNumberAction = SKAction.move(to: numberTargetPosition, duration: 0.33)
            
            // group the scale and move together
            // this makes it look like the whiteout gem and label become the label on the gem
            let scaleAndMove = SKAction.group([scaleNumberAction, moveNumberAction])
            
            // create the sequence
            let sequence = SKAction.sequence([wait, scaleUpAndWiggle, scaleAndMove])
            sequence.timingMode = .easeInEaseOut
            
            spriteActions.append(SpriteAction(sprite: whiteOutGem, action: sequence))
            
        }
        
        
        
        return spriteActions
    }

    
    func animate(_ spriteActions: [SpriteAction], completion: @escaping () -> Void) {
        if spriteActions.count == 0 { completion() }
        var numActions = spriteActions.count
        // tell each child to run it's action
        for spriteAction in spriteActions {
            spriteAction.sprite.run(spriteAction.action) {
                numActions -= 1
//                print(numActions)
                if numActions == 0 {
                    completion()
                }
            }
        }
    }
    
    // Recursively animates the sprite actions array from the start of the array at index 0/
    // Returns when there are no more sprites to animate.
    func animateSequentially(_ spriteActions: [SpriteAction], completion: @escaping () -> Void) {
        if spriteActions.count == 0 { completion() }
        // tell each child to run it's action
        guard let firstAction = spriteActions.first else { completion(); return }
        firstAction.sprite.run(firstAction.action) {
            animateSequentially(Array(spriteActions.dropFirst()), completion: completion)
        }
    }
    
    func animate(_ transformation: [TileTransformation]?,
                 boardSize: CGFloat,
                 bottomLeft: CGPoint,
                 spriteForeground: SKNode,
                 tileSize: CGFloat,
                 _ completion: (() -> Void)? = nil) {
        guard let transformation = transformation else {
            completion?()
            return
        }
        
        var childActionDict : [SKNode : SKAction] = [:]
        
        // create each animation action
        for transIdx in 0..<transformation.count {
            let trans = transformation[transIdx]
            //calculate a point that is out of bounds of the foreground
            let outOfBounds: CGFloat = CGFloat(trans.initial.x) >= boardSize ? tileSize * boardSize : 0
            
            // Translate the TileTransformation initial to a tile on screen
            let point = CGPoint.init(x: tileSize * CGFloat(trans.initial.tuple.1) + bottomLeft.x,
                                     y: outOfBounds + tileSize * CGFloat(trans.initial.x) + bottomLeft.y)
            
            // Find that tile and add that animation
            for child in spriteForeground.children {
                if child.contains(point) {
                    let endPoint = CGPoint.init(x: tileSize * CGFloat(trans.end.y) + bottomLeft.x,
                                                y: tileSize * CGFloat(trans.end.x) + bottomLeft.y)
                    let animation = SKAction.move(to: endPoint, duration: AnimationSettings.fallSpeed)
                    childActionDict[child] = animation
                    
                    break
                }
            }
            
        }
        
        // tell each child to run it's action
        for (child, action) in childActionDict {
            child.run(action) {
                completion?()
            }
        }
    }
    
    // MARK: - Shuffle Board Animations
    func animateBoardShuffle(tileTransformations: [TileTransformation], sprites: [[DFTileSpriteNode]], positionInForeground: (TileCoord) -> CGPoint,  completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        var maxDuration = 0.0
        // move each tile to it's destination
        for tileTransforamtion in tileTransformations {
            
            let startCoord = tileTransforamtion.initial
            let targetCoord = tileTransforamtion.end
            let waitDuration = Double.random(in: 0.2...0.6)
            let animationDuration = Double.random(in: 0.4..<0.6)
            
            // grab the max duration so we know for how long to wiggle
            maxDuration = max(maxDuration, waitDuration + animationDuration)
            
            // grab the sprite
            let sprite = sprites[startCoord]
            
            // wait a bit
            let waitBeforeMoving = SKAction.wait(forDuration: waitDuration)
            
            /// move it to the new
            let targetPosition = positionInForeground(targetCoord)
            let moveTo = SKAction.move(to: targetPosition, duration: animationDuration)
            moveTo.timingMode = .easeInEaseOut
            
            let allAction = SKAction.sequence([waitBeforeMoving, moveTo])
            
            spriteActions.append(.init(sprite, allAction))
        }
        
        
        // wiggle all tiles for the duration of the animation
        for sprite in sprites.reduce([], +) {
            let wiggle = shakeNode(node: sprite, duration: maxDuration+0.5, ampX: 10, ampY: 10, delayBefore: 0.0)
            spriteActions.append(wiggle)
        }
        
        animate(spriteActions, completion: completion)
    }
    
    let mineralSpiritsAttackSpriteSheet = SpriteSheet(texture: SKTexture(imageNamed: "mineralSpiritsAttackSpriteSheet"), rows: 1, columns: 5)
    let mineralSpiritsTexture = SKTexture(imageNamed: "mineralSprits")
    
    func animateMineralSpirits(targetTileCoords: [TileCoord], playableRect: CGRect, spriteForeground: SKNode, tileSize: CGFloat, positionInForeground: (TileCoord) -> CGPoint) -> (waitDuration: Double, [SpriteAction]) {
        var spriteActions: [SpriteAction] = []
        let tileSize = CGSize(widthHeight: tileSize)
        
        // duration for movement
        let durationForMovement = 2.5
        
        var waitBeforeAdditionalTargets = 0.0
        
        for coord in targetTileCoords {
            let emptySprite = SKSpriteNode.init(color: .clear, size: tileSize)
            emptySprite.zRotation = CGFloat.random(in: (0.0)...(.pi*2))
            emptySprite.zPosition = 1000
            emptySprite.position = positionInForeground(coord)
            spriteForeground.addChild(emptySprite)
            
            // choose a distance away to start the mineral sprite
            let distanceFromTarget = CGFloat(1500)
            
            
            // choose where to start
            let startingX = 0.0 - distanceFromTarget
            let startingY = 0.0 - distanceFromTarget
            let waitBefore = SKAction.wait(forDuration: waitBeforeAdditionalTargets)
            
            // MARK: First
            // choose the startingLocation
            let firstStartingPosition = CGPoint(x: startingX, y: 0.0)
            let firstEndingPosition = firstStartingPosition.translate(xOffset: distanceFromTarget * 2, yOffset: 0.0)
            let secondStartingPosition = CGPoint(x: 0.0, y: startingY)
            let secondEndPosition = secondStartingPosition.translate(xOffset: 0.0, yOffset: distanceFromTarget * 2)
            
            let firstMineralSpirit = SKSpriteNode(texture: mineralSpiritsTexture, size: tileSize)
            firstMineralSpirit.position = firstStartingPosition
            emptySprite.addChild(firstMineralSpirit)
            
            // Actions for the first mineral sprite
            let rotate = SKAction.rotate(byAngle: -.pi/2, duration: 0.0)
            let animateMovement = SKAction.animate(with: mineralSpiritsAttackSpriteSheet.animationFrames(), timePerFrame: timePerFrame())
            let moveAcrossTheScreen = SKAction.move(to: firstEndingPosition, duration: durationForMovement)
//            moveAcrossTheScreen.timingMode = .easeIn
            
            let grouped = SKAction.group(animateMovement, moveAcrossTheScreen)
            let allAction = SKAction.sequence([rotate, waitBefore, grouped])
            
            spriteActions.append(.init(firstMineralSpirit, allAction))
            
            
            // MARK: Second
            let secondMineralSpirit = SKSpriteNode(texture: mineralSpiritsTexture, size: tileSize)
            secondMineralSpirit.position = secondStartingPosition
            emptySprite.addChild(secondMineralSpirit)
            // Actions for the second animations
            let secondAnimateMovement = SKAction.animate(with: mineralSpiritsAttackSpriteSheet.animationFrames(), timePerFrame: timePerFrame())
            let secondMoveAcrossTheScreen = SKAction.move(to: secondEndPosition, duration: durationForMovement)
//            secondMoveAcrossTheScreen.timingMode = .easeIn
            
            // group and secquence actions
            let secondGrouped = SKAction.group(secondAnimateMovement, secondMoveAcrossTheScreen)
            let secondAllAction = SKAction.sequence([waitBefore, secondGrouped])

            spriteActions.append(.init(secondMineralSpirit, secondAllAction))
            

            
            waitBeforeAdditionalTargets += 0.75
        }
        
        waitBeforeAdditionalTargets += durationForMovement
        
        
        return (waitDuration: waitBeforeAdditionalTargets, spriteActions)
    }
    
    /// We also want to create an aniamtion for when the mineral spritis kill a monster during the shuffle board (we will want to resuse this animation for other things as well)
    /// Lets take a the mineral spritis sprite sheet and animate  sprite moving across the sceen at an angle
    /// Lets do that twice and make it so that the two sprites cross at the excat point over the monster they are kill
    /// While it animates across the screen, leave behind a trail of white that fades away as the time passes
    /// When the two paths cross the monster should player it's "take damage" animation
    /// When the two paths leave screen then the monsters should die and play their death animation
    
    
    // MARK: - Boss Animations
    
    func animateBossSingleTargetAttack(foreground: SKNode, tileTypes: [TileType], tileSize: CGFloat, startingPosition: CGPoint, targetPositions: [CGPoint], targetSprites: [DFTileSpriteNode], completion: @escaping () -> Void) {
        
        var spriteActions: [SpriteAction] = []
        // create a dynamite stick for each dynamiate
        var bossAttackSprites: [DFTileSpriteNode] = []
        for tileType in tileTypes {
            let attackSprite = DFTileSpriteNode(type: tileType, height: tileSize, width: tileSize)
            if let fuseTiming = tileType.fuseTiming {
                attackSprite.showFuseTiming(fuseTiming)
            }
            bossAttackSprites.append(attackSprite)
        }
        
        
        // add them to the foreground
        for sprite in bossAttackSprites {
            sprite.position = startingPosition
            sprite.zPosition = 100_000
            foreground.addChild(sprite)
        }
        
        // make it appear as if they are being thrown onto the screen
        var actions: [SKAction] = []
        //stagger the initial throw of each dynamite
        var waitTime = 0.0
        for (idx, target) in targetPositions.enumerated() {
            let distance = target - startingPosition
            let speed: Double = 750
            
            // determine the duration based on the distance to the target
            let duration = waitTime + (Double(distance.length) / speed)
            waitTime += Double.random(in: 0.25...0.35)
            
            let moveAction = SKAction.move(to: target, duration: duration)
            
            /// grow and shrink animation
            let scaleBy: CGFloat = 2
            let growAction = SKAction.scale(by: scaleBy, duration: duration/2)
            let shrinkAction = SKAction.scale(by: 1/scaleBy, duration: duration/2)
            let growSkrinkSequence = SKAction.sequence([growAction, shrinkAction])
            growSkrinkSequence.timingMode = .easeInEaseOut
            
            // "throw" it
            let moveGrowShrink = SKAction.group([moveAction, growSkrinkSequence])
            
            // run it in sequence
            let sequence = SKAction.sequence([moveGrowShrink])
            
            // crumble the rock that gets "hit"
            let spriteToRemoveOnLanding = targetSprites[idx]
            if let crumble = spriteToRemoveOnLanding.crumble() {
                let waitBeforeCrumble = SKAction.wait(forDuration: duration)
                let crumbleAction = crumble.action
                let sequence = SKAction.sequence([waitBeforeCrumble, crumbleAction])
                sequence.timingMode = .easeIn
                spriteActions.append(.init(spriteToRemoveOnLanding, sequence))
            }
            
            actions.append(sequence)

        }
        
        guard bossAttackSprites.count == actions.count else {
            completion();
            return
        }
        
        for idx in 0..<bossAttackSprites.count {
            spriteActions.append(.init(bossAttackSprites[idx], actions[idx]))
        }
        
        
        animate(spriteActions, completion: completion)
    }
    
    func animateDynamiteExplosion(dynamiteSprites: [DFTileSpriteNode], dynamiteCoords: [TileCoord], foreground: SKNode, boardSize: Int, sprites: [[DFTileSpriteNode]], positionInForeground: (TileCoord) -> CGPoint, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        
        var waitBetweenDynamiteExplosionDuration = 0.0
        
        for (idx, dynamite) in dynamiteSprites.enumerated() {
            // when there are multiple dynamites to blowup, let's stagger them so the player can follow the action
            let waitBeforeStarting = SKAction.wait(forDuration: waitBetweenDynamiteExplosionDuration)
            
            // shake the screen
            if let shake = shakeScreen(duration: 0.15, ampX: 30, ampY: 30, delayBefore: waitBetweenDynamiteExplosionDuration) {
                spriteActions.append(shake)
            }
            
            waitBetweenDynamiteExplosionDuration += 0.5
            
            // create and add an empty sprite to hold all the exploding animations
            let dynamiteEmptySprite = SKSpriteNode(color: .clear, size: dynamite.size)
            dynamiteEmptySprite.position = dynamite.position
            foreground.addChild(dynamiteEmptySprite)
            
            /// create an aniamtion that shows the fuse timer hit 0 and then explodes
            let showFuseTime = SKAction.run {
                dynamite.showFuseTiming(0)
            }
            let dynamiteWaitDuration = 0.1
            let waitForABit = SKAction.wait(forDuration: dynamiteWaitDuration)
            let dynamiteExplode = explodeAnimation(size: dynamite.size.scale(by: 2.0))
            
            // smoke
            let smoke = smokeAnimation()
            let fade = SKAction.fadeAlpha(to: 0.1, duration: 0.25)
            let smokeAndFade = SKAction.group([smoke, fade])
            smoke.timingMode = .easeOut
            
            
            // sequence all
            let dynamiteAllAction = SKAction.sequence([showFuseTime, waitBeforeStarting, waitForABit, dynamiteExplode, smokeAndFade, .removeFromParent()])
            spriteActions.append(.init(dynamite, dynamiteAllAction))
            
            /// create a bunch of explosions
            let neighbors = dynamiteCoords[idx].orthogonalNeighbors.filter { isWithinBounds($0, within: boardSize) }
            
            for neighbor in neighbors {
                guard isWithinBounds(neighbor, within: boardSize) else { continue }
                // create and randomly position sprite
                let emptySprite = SKSpriteNode(color: .clear, size: dynamite.size)
                emptySprite.position = positionInForeground(neighbor)
                emptySprite.zPosition = 1_000
                foreground.addChild(emptySprite)
                
                // create the animation
                let explosionAnimation = explodeAnimation(size: emptySprite.size.scale(by: 1.5))
                let scaleUp = CGFloat.random(in: 3.0...5.0)
                let scaleDown = 1/scaleUp
                let randomScale = SKAction.scale(by: scaleUp, duration: 0.20)
                let scaleBackDown = SKAction.scale(by: scaleDown, duration: 0.08)
                let scaleAction = SKAction.sequence([randomScale, scaleBackDown])
                let explodeAndScale = SKAction.group([explosionAnimation, scaleAction])
                explodeAndScale.timingMode = .easeIn
                
                
                let neighbor = sprites[neighbor]
                let hideNeighbor = SKAction.run { [neighbor] in
                    if neighbor.crumble() != nil {
                        neighbor.alpha = 0
                    }
                }
                
                let allAction = SKAction.sequence([waitBeforeStarting, explodeAndScale, hideNeighbor, smokeAndFade, .removeFromParent()])
                
                spriteActions.append(SpriteAction(emptySprite, allAction))
                
            }
        }
        
        animate(spriteActions, completion: completion)
        
    }
    
    func animateBossPoisonAttack(_ spriteForeground: SKNode, targetedColumns: [Int], targetedTiles: [TileTransformation], sprites: [[DFTileSpriteNode]], tileSize: CGFloat, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        for column in targetedColumns {
            
            // create 1 poison sprite for each column attack
            let poisonSprite = SKSpriteNode(texture: SKTexture(imageNamed: Constants.poisonDropSpriteName), size: CGSize(width: tileSize, height: tileSize))
            
            // position it at the top and center of the attacked column
            let boardSize = sprites.count
            let topSpriteInColumn = sprites[boardSize-1][column]
            let poisonSpritePosition = CGPoint.alignHorizontally(poisonSprite.frame, relativeTo: topSpriteInColumn.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.normal, translatedToBounds: true)
            poisonSprite.position = poisonSpritePosition
            poisonSprite.zPosition = 1_000
            
            // add to the sprite foreground which will auto remove it after animations are finishied
            spriteForeground.addChild(poisonSprite)
            
            // animate it dripping down the column
            // grab the bottom row in the atttacked column
            if let finalRowAttacked = targetedTiles.filter({ $0.initial.column == column }).sorted(by: { $0.initial.row < $1.initial.row }).first?.initial {
                
                // calculate the target sprite
                let targetSprite = sprites[finalRowAttacked]
                let targetPosition = CGPoint.alignVertically(poisonSprite.frame, relativeTo: targetSprite.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
                
                
                let distance = targetPosition - poisonSprite.position
                let speed: Double = 1000
                
                // the poison should move at the same speed regardless of the distance to the target
                let duration = Double(distance.length) / speed
                
                let moveAction = SKAction.move(to: targetPosition, duration: duration)
                
                // after passing the final tile, then you in the splash zone
                let splashAnimation = self.poisonDropAnimation
                let sequence = SKAction.sequence([moveAction, splashAnimation, .removeFromParent()])
                
                spriteActions.append(.init(poisonSprite, sequence))
            } else {
                // after passing the final tile, then you in the splash zone
                let splashAnimation = self.poisonDropAnimation
                let sequence = SKAction.sequence([splashAnimation, .removeFromParent()])
                
                spriteActions.append(.init(poisonSprite, sequence))
            }
        }
        
        animate(spriteActions, completion: completion)
    }
    
    func showPillarsGrowing(sprites: [[DFTileSpriteNode]], spriteForeground: SKNode, bossTileAttacks: [BossTileAttack], tileSize: CGFloat, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        for bossTileAttack in bossTileAttacks {
            let coord = bossTileAttack .tileCoord
            let targetSprite = sprites[coord]
            let emptySprite = SKSpriteNode(color: .clear, size: CGSize(widthHeight: tileSize))
            emptySprite.position = targetSprite.position
            spriteForeground.addChild(emptySprite)
            
            // crumble the thing that is there if possible.  Otherwise ignore it
            if let crumble = targetSprite.crumble() {
                spriteActions.append(crumble)
            }

            let newTileSprite = DFTileSpriteNode(type: bossTileAttack.tileType, height: 1, width: 1)
            newTileSprite.zPosition = 100
            emptySprite.addChild(newTileSprite)
            
            let scaleAction = SKAction.scale(to: CGSize(width: tileSize, height: tileSize), duration: 2.5)
            let sequence = SKAction.sequence([scaleAction])
            sequence.timingMode = .easeIn
            
            spriteActions.append(.init(newTileSprite, sequence))
            
        }
        
        animate(spriteActions, completion: completion)
    }
    
    // MARK: - Goal Completion
    
    func animateCompletedGoals(_ goals: [GoalTracking],
                               transformation: Transformation,
                               unlockExitTransformation: Transformation?,
                               sprites: [[DFTileSpriteNode]],
                               foreground: SKNode,
                               levelGoalOrigin: CGPoint,
                               completion: @escaping () -> Void) {
        guard !goals.isEmpty, !sprites.isEmpty else { completion(); return }
        
        var spriteActions: [SpriteAction] = []
        
        // rock explode animation
        for idx in 0..<(transformation.tileTransformation?.count ?? 0) {
            guard let rockCoord = transformation.tileTransformation?[idx], let crumble = sprites[rockCoord.end].crumble(false) else { completion(); return }
            let sprite = sprites[rockCoord.end]
            
            // smoke animation
            let smoke = self.smokeAnimation()
            
            // create the crumble smoke sequence
            spriteActions.append(SpriteAction(sprite: sprite, action: SKAction.sequence([crumble.action, smoke])))
            
            // put the item there
            if let newItem = transformation.endTiles?[rockCoord.end] {
                let startPosition = levelGoalOrigin
                let endPosition = sprite.position
                let itemSprite = DFTileSpriteNode(type: newItem.type, height: sprite.size.height, width: sprite.size.width)
                itemSprite.position = startPosition
                itemSprite.setScale(0.5)
                foreground.addChild(itemSprite)
                
                let movement = SKAction.move(to: endPosition, duration: 1.0)
                let scale = SKAction.scale(to: 1.0, duration: 1.0)

                spriteActions.append(SpriteAction(sprite: itemSprite, action: SKAction.group([movement, scale])))
            }
        }
        
        
        
        /// animate the sprite actions and call out completion
        animate(spriteActions) {
            /// show the exit unlocking if all goals are completed
            if let unlockTrans = unlockExitTransformation,
               let exitCoord = unlockTrans.tileTransformation?.first?.initial {
                // smoke animation
                let smoke = self.smokeAnimation()
                
                let sprite = sprites[exitCoord.row][exitCoord.column]
                
                let spriteActions = [SpriteAction(sprite: sprite, action: smoke)]
                animate(spriteActions, completion: completion)
            } else {
                completion()
            }
        }
        
        
    }
    
    // MARK: - Combat
    
    func animate(attackInputType: InputType,
                 foreground: SKNode,
                 tiles: [[Tile]],
                 sprites: [[DFTileSpriteNode]],
                 positions: ([TileCoord]) -> [CGPoint],
                 completion: (() -> Void)?) {
        guard case InputType.attack(_,
                                    let attackerPosition,
                                    let defenderPosition,
                                    let affectedTiles,
                                    let defenderDodged,
                                    _
            ) = attackInputType else { return }
        
        /*
         Attack animations involve a few things depending on the attack.
         
         There is the animation of the attacker.
         The animation of the defender.
         The sprite/animation of the projectile
         
         However, there is not always a projectile involved.  For example, a player hitting a rat with their pick axe. Or a rat attacking a player
         
         The basic sequence of attacks are:
         - animate the attacker
         - if there are projectiles, animate those
         
         When we are all said and finished, we call animations finished to move on
         
         */
        
        // group up the actions so we can run them sequentially
        var groupedActions: [SKAction] = []
        
        // CAREFUL: Synchronizing on main thread
        let dispatchGroup = DispatchGroup()
        
        
        // attacker animation
        if let attackAnimation = animation(for: .attack, fromPosition: attackerPosition, toPosition: defenderPosition, in: tiles, sprites: sprites, dispatchGroup: dispatchGroup) {
            groupedActions.append(attackAnimation)
        }
        
        let attackAnimationFrames = animationFrames(for: .attack, fromPosition: attackerPosition, toPosition: defenderPosition, in: tiles)
        
        // projectile
        if let projectileGroup = projectileAnimations(from: attackerPosition, in: tiles, with: sprites, affectedTilesPosition: positions(affectedTiles), foreground: foreground, dispatchGroup: dispatchGroup, attackPosition: attackerPosition, defenderPosition: defenderPosition, attackAnimationFrameCount: attackAnimationFrames),
            projectileGroup.count > 0 {
            groupedActions.append(SKAction.group(projectileGroup))
        }
        
        // defender animation
        if !defenderDodged,
            let defend = animation(for: .hurt, fromPosition: defenderPosition, toPosition: nil, in: tiles, sprites: sprites, dispatchGroup: dispatchGroup) {
            groupedActions.append(defend)
        } else if defenderDodged {
            let dodgedText = ParagraphNode(text: "Dodged!", paragraphWidth: 800.0, fontSize: .fontGiantSize, fontColor: .yellow)
            dodgedText.zPosition = Precedence.flying.rawValue
            let scaleAction = SKAction.run {
                let action = SKAction.scale(by: 1.75, duration: 0.75)
                let rotateAction = SKAction.rotate(byAngle: .pi/16, duration: 0.30)
                let antiRotateAction = SKAction.rotate(byAngle: -.pi/8, duration: 0.45)
                
                dodgedText.run(SKAction.group([action, SKAction.sequence([rotateAction, antiRotateAction])]))
            }
            
            let addToSceneAction = SKAction.run {
                foreground.addChild(dodgedText)
            }
            let removeAction = SKAction.run {
                dodgedText.removeFromParent()
            }
            let addMoveUpAndScaleAction = SKAction.group([addToSceneAction, SKAction.wait(forDuration: 0.75),  scaleAction])
            let sequence = SKAction.sequence([addMoveUpAndScaleAction, removeAction])
            
            
            
            groupedActions.append(sequence)
        }
        
        
        foreground.run(SKAction.sequence(groupedActions))
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
        
    }
    
    private func projectileAnimations(from position: TileCoord?, in tiles: [[Tile]], with sprites: [[DFTileSpriteNode]], affectedTilesPosition: [CGPoint], foreground: SKNode, dispatchGroup: DispatchGroup, attackPosition: TileCoord, defenderPosition: TileCoord?, attackAnimationFrameCount: Int) -> [SKAction]? {
        
        guard let entityPosition = position else { return nil }
        
        /// get the projectile animations depending on the tile type
        
        var projectileStartAnimationFrames: [SKTexture]?
        var projectileMidAnimationFrames: [SKTexture]?
        var projectileEndAnimationFrames: [SKTexture]?
        
        // get the projectile animation
        var projectileRetracts = false
        var isProjectileSequenced = false
        var showSmokeAfter = false
        var projectileTilePerFrame = 0.03
        var flipSpriteHorizontally = false
        if case let TileType.monster(monsterData) = tiles[entityPosition].type {
            
            // set the projectil speed
            projectileTilePerFrame = projectileTimePerFrame(for: monsterData.type)
            
            /// set some variables based on the monster type
            switch monsterData.type {
            case .alamo:
                projectileRetracts = true
                isProjectileSequenced = true
            case .sally:
                projectileRetracts = true
                isProjectileSequenced = true
                projectileTilePerFrame = 0.03
                if let defenderPos = defenderPosition {
                    flipSpriteHorizontally = attackPosition.direction(relative: defenderPos) == .east
                }
            case .dragon:
                isProjectileSequenced = true
                showSmokeAfter = true
            default:
                ()
            }
            
            // grab the start tile animation
            if let projectileAnimation = monsterData.animation(of: .projectileStart) {
                projectileStartAnimationFrames = projectileAnimation
            }
            // grab the mid tile animation
            if let projectileAnimation = monsterData.animation(of: .projectileMid) {
                projectileMidAnimationFrames = projectileAnimation
            }
            
            // grab the end tile animations
            if let projectileAnimation = monsterData.animation(of: .projectileEnd) {
                projectileEndAnimationFrames = projectileAnimation
            }
        }
        
        // projectile
        var projectileGroup: [SKAction] = []
        
        /// certain projectiles like Alamo's attack have two distinct phases.  There is the initial movement across the tile.  These frames are `projectileStart`. The next phase could be a few things.  In Alamo's case, the frames for `projectileMid` are repeated. In Dragon's case, every tile after the first only does `projectileMid`.  In the bat's case, there is no `projectileMid
        
        
        /// Every projectile has start frames.  We can safely return in the case that we do not have any projectileStartFrames
        guard let startFrames = projectileStartAnimationFrames, startFrames.count > 0 else { return nil }
        let affectedTileCount = affectedTilesPosition.count
        
        /// the TileCoords where projectiles should appear
        for (idx, position) in affectedTilesPosition.enumerated() {
            
            /// the initial projectile animation
            var projectileAnimations: [SKAction] = [SKAction.animate(with: startFrames, timePerFrame: projectileTilePerFrame)]
            
            /// Create a sprite where to run the animations
            /// This will get added and removed from the foreground node
            let sprite = SKSpriteNode(color: .clear, size: sprites[0][0].size)
            sprite.position = position
            sprite.zPosition = Precedence.menu.rawValue
            
            /// The following actions are sequenced.
            var sequencedActions: [SKAction] = []
            
            /// For some monster attacks, the projectile goes out and comes back.
            /// We need to animate an `idle` animation and a reverse of the original projectile aniamtion to create this effect
            if projectileRetracts, let midFrames = projectileMidAnimationFrames {
                projectileAnimations = [retractableAnimation(startFrames: startFrames, midFrames: midFrames, endFrames: projectileEndAnimationFrames, currentIndex: idx, totalAfectedTiles: affectedTileCount, projectileAnimationSpeed: projectileTilePerFrame, attackAnimationCount: attackAnimationFrameCount)]
            }
            /// If the attack does not retract then we want to show the midFrames in all the tiles between 1..<n, where n is the length of the attack. Unless there is an projectileEnd aniamtion.  Then we want to only show the midFrames for the middle tiles, where the idx is in 1..<n-1.
            else if idx > 0, let midFrames = projectileMidAnimationFrames {
                let midFrameAnimation = SKAction.animate(with: midFrames, timePerFrame: projectileTilePerFrame)
                projectileAnimations = [midFrameAnimation]
            }
            
            /// sequence the projectile
            if !projectileRetracts,
                isProjectileSequenced,
                case let TileType.monster(monsterData) = tiles[entityPosition].type {
                let duration = projectileKeyFrame(for: monsterData, index: idx)
                let waitAction = SKAction.wait(forDuration: duration * projectileTilePerFrame)
                sequencedActions.append(waitAction)
            }
            
            /// Show smoke as an after effect if needed
            if showSmokeAfter {
                projectileAnimations.append(smokeAnimation())
            }
            
            /// Flip the sprites along y-axis to face the correct direction
            if flipSpriteHorizontally {
                sprite.xScale *= -1
            }
            
            /// The action that animates the actual projectile
            let projectileAction =
                SKAction.run {
                    foreground.addChild(sprite)
                    sprite.run (SKAction.sequence(projectileAnimations)) {
                        sprite.removeFromParent()
                    }
            }
            
            sequencedActions.append(projectileAction)
            let sequence = SKAction.sequence(sequencedActions)
            
            /// All these projectile actions assume the same start time
            projectileGroup.append(sequence)
            
        }
        
        return projectileGroup
    }
    
    private func retractableAnimation(startFrames: [SKTexture], midFrames: [SKTexture], endFrames: [SKTexture]?, currentIndex: Int, totalAfectedTiles: Int, projectileAnimationSpeed: Double, attackAnimationCount: Int = 0) -> SKAction {
        
        let waitFrames = currentIndex * startFrames.count
        let waitDuration = Double(waitFrames + attackAnimationCount) * projectileAnimationSpeed
        let waitAction = SKAction.wait(forDuration: waitDuration)
        
        // start
        let startAnimation: SKAction
        //save the start frames to reverse later
        let actualStartFrames: [SKTexture]
        if currentIndex == totalAfectedTiles - 1, let endFrames = endFrames {
            startAnimation = SKAction.animate(with: endFrames, timePerFrame: projectileAnimationSpeed)
            actualStartFrames = endFrames
        } else {
            startAnimation = SKAction.animate(with: startFrames, timePerFrame: projectileAnimationSpeed)
            actualStartFrames = startFrames
        }
        
        // mid frames
        /// calculate the number of non-terminal tiles after my current index
        let framesAfterMeMinusLastFrame = totalAfectedTiles - currentIndex - 2
        
        /// a constant representing that a projectile goes out and back
        let outAndBackConstant = 2
        
        /// the specific amount of time to wait on the terminal tile.  It differs depending on the animation
        let lastTileWait = (2 * (endFrames?.count ?? startFrames.count))
        
        /// the total frames we need to wait for
        let totalFrames: Int
        
        /// this is the case for the terminal tile
        if framesAfterMeMinusLastFrame == -1 {
            totalFrames = 0
        }
        /// The penultimate tile
        else if framesAfterMeMinusLastFrame == 0 {
            totalFrames = lastTileWait
        }
        /// Any other tile
        else {
            totalFrames = framesAfterMeMinusLastFrame * startFrames.count * outAndBackConstant + lastTileWait
        }
        
        /// Determine the number of repititions.
        let totalCycles = totalFrames / midFrames.count
        
        /// The single animation
        let singleMidFrameAnimation = SKAction.animate(with: midFrames, timePerFrame: projectileAnimationSpeed)
        
        /// The repeated animation
        let repeatedMidAnimation = SKAction.repeat(singleMidFrameAnimation, count: totalCycles)
        
        /// The start animation reverse, animated after the wait animation
        let reverseStartAnimation = SKAction.animate(with: actualStartFrames.reversed(), timePerFrame: projectileAnimationSpeed)
        
        
        /// From the top
        /// Wait your turn to animate
        /// Animate the start
        /// Repeat an idle animation in projectileMidFrames
        /// Reverse the start
        /// Done
        return SKAction.sequence([waitAction, startAnimation, repeatedMidAnimation, reverseStartAnimation])
    }
    
    private func animationFrames(for animationType: AnimationType,
                                 fromPosition position: TileCoord?,
                                 toPosition defenderPosition: TileCoord?,
                                 in tiles: [[Tile]]) -> Int {
        if let position = position {
            if case let TileType.monster(monsterData) = tiles[position].type,
                let attackAnimation = monsterData.animation(of: animationType) {
                return attackAnimation.count
            } else if case let TileType.player(playerData) = tiles[position].type,
                let attackAnimation = playerData.animation(of: animationType) {
                return attackAnimation.count
            }
        }
        return 0
    }
    
    private func animation(for animationType: AnimationType,
                           fromPosition position: TileCoord?,
                           toPosition defenderPosition: TileCoord?,
                           in tiles: [[Tile]],
                           sprites: [[DFTileSpriteNode]],
                           dispatchGroup: DispatchGroup,
                           reverse: Bool = false) -> SKAction? {
        
        var animationFrames: [SKTexture]?
        // get the animation for the animation type
        if let position = position {
            if case let TileType.monster(monsterData) = tiles[position].type,
                let animation = monsterData.animation(of: animationType) {
                animationFrames = animation
            } else if case let TileType.player(playerData) = tiles[position].type,
                let animation = playerData.animation(of: animationType) {
                animationFrames = animation
            }
        }
        
        var flipHorizontally = false
        if let defendPos = defenderPosition, position?.direction(relative: defendPos) == .east {
            flipHorizontally = true
        }
        
        // animate!
        if let position = position,
            var frames = animationFrames {
            if reverse { frames.reverse() }
            let animation: SKAction
                
            if flipHorizontally {
                let flipAnimation = SKAction.scaleX(to: -1, duration: 0.01)
                animation = SKAction.sequence([flipAnimation, SKAction.animate(with: frames, timePerFrame: self.timePerFrame())])
            } else {
                animation = SKAction.animate(with: frames, timePerFrame: self.timePerFrame())
            }
            
            dispatchGroup.enter()
            return
                SKAction.run {
                    sprites[position].run(animation) {
                        dispatchGroup.leave()
                    }
            }
        }
        return nil
    }
}
