//
//  RuneAnimator.swift
//  DownFall
//
//  Created by Billy on 2/25/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit


extension Animator {
    
    func animateRune(_ rune: Rune,
                     transformations: [Transformation],
                     affectedTiles: [TileCoord],
                     sprites: [[DFTileSpriteNode]],
                     spriteForeground: SKNode,
                     delayBefore: TimeInterval = 0.0,
                     completion: @escaping () -> Void) {
        let runeAnimation = SpriteSheet(texture: rune.animationTexture, rows: 1, columns: rune.animationColumns)
        guard let endTiles = transformations.first?.endTiles else {
            completion()
            return
        }
        
        guard let tileTransformation = transformations.first?.tileTransformation else {
            completion()
            return
        }
        
        
        switch rune.type {
            
        case .getSwifty, .teleportation, .debugTeleport:
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
            
            animate(spriteActions) { completion() }
            
        case .rainEmbers:
            var spriteActions: [SpriteAction] = []
            guard let pp = getTilePosition(.player(.playerZero), tiles: endTiles) else {
                completion()
                return
            }
            
            let actions = createRuneWithFireballAnimation(delayBefore: delayBefore, sprites: sprites, tileCoords: tileTransformation.map { $0.initial }, playerPosition: pp, spriteForeground: spriteForeground, runeAnimationSpriteSheet: runeAnimation)
            
            spriteActions.append(contentsOf: actions)
            
            animate(spriteActions) { completion() }
            
        case .fireball:
            
            var spriteActions: [SpriteAction] = []
            guard let pp = getTilePosition(.player(.playerZero), tiles: endTiles) else {
                completion()
                return
            }
            
            let actions = createRuneWithFireballAnimation(delayBefore: delayBefore, sprites: sprites, tileCoords: affectedTiles, playerPosition: pp, spriteForeground: spriteForeground, runeAnimationSpriteSheet: runeAnimation)
            
            spriteActions.append(contentsOf: actions)
            
            animate(spriteActions) { completion() }
            
        case .transformRock:
            var spriteActions: [SpriteAction] = []
            for tileTrans in tileTransformation {
                let start = tileTrans.initial
                let runeAnimationAction = SKAction.animate(with: runeAnimation.animationFrames(), timePerFrame: 0.07)
                
                let spriteAction = SpriteAction(sprite: sprites[start.row][start.column], action: runeAnimationAction)
                spriteActions.append(spriteAction)
            }
            animate(spriteActions) { completion() }
            
        case .bubbleUp:
            var spriteActions: [SpriteAction] = []
            
            let bubbleSprite = SKSpriteNode(imageNamed: "bubble")
            
            guard let originalPlayerPosition = affectedTiles.first else {
                completion()
                return
            }
            let playerSprite = sprites[originalPlayerPosition]
            
            // player is taller than wide, so use the player's height as width and height of bubble
            bubbleSprite.size = CGSize(width: playerSprite.size.height, height: playerSprite.size.height)
            bubbleSprite.alpha  = 0.25
            playerSprite.addChild(bubbleSprite)
            playerSprite.zPosition = 1000
            
            // grab the player's tile position from the end tiles
            var playerFloatDuration = 0.0
            if let targetPlayerCoord = getTilePosition(.player(.playerZero), tiles: transformations.first!.endTiles!) {
                let speed: CGFloat = 600
                let position = sprites[targetPlayerCoord].position
                let distance = position - playerSprite.position
                playerFloatDuration = distance.length / speed
                let floatUpAction = SKAction.move(to: position, duration: playerFloatDuration)
                floatUpAction.timingMode = .easeInEaseOut
                                
                spriteActions.append(SpriteAction(sprite: playerSprite, action: floatUpAction))
                
            }
            
            var delayBefore: Double = 0.0
            let duration = playerFloatDuration / Double(max(1, tileTransformation.count - 1))
            for tileTrans in tileTransformation {
                if tileTrans.initial != originalPlayerPosition {
                    let targetPosition = sprites[tileTrans.end].position
                    let moveTo = SKAction.move(to: targetPosition, duration: duration)
                    moveTo.timingMode = .easeInEaseOut
                    let delayBefore = SKAction.wait(forDuration: delayBefore)
                    let seq = SKAction.sequence(delayBefore, moveTo)
                    
                    spriteActions.append(.init(sprites[tileTrans.initial], seq))
                    
                }
                delayBefore += duration
            }
            
            animate(spriteActions) { completion() }
            
        case .flameWall, .flameColumn:
            guard let trans = transformations.first else {
                completion()
                return
            }
            
            animateFlameLine(spriteForeground: spriteForeground, sprites: sprites, transformation: trans, runeSpriteSheet: runeAnimation, completion: completion)
                        
        case .vortex:
            var spriteActions: [SpriteAction] = []
            for tileCoord in affectedTiles {
                let runeAnimationAction = SKAction.animate(with: runeAnimation.animationFrames(), timePerFrame: 0.07)
                
                let spriteAction = SpriteAction(sprite: sprites[tileCoord], action: runeAnimationAction)
                spriteActions.append(spriteAction)
            }
            animate(spriteActions) { completion() }
            
        case .drillDown:
            // this is a special case for remove and replace so we just complete here and then computer board is called.
            guard let trans = transformations.first else {
                completion()
                return
            }
            
            animateDrillDownRuneUsed(spriteForeground: spriteForeground, sprites: sprites, transformation: trans, completion: completion)
            
        case .fieryRage:
            guard let trans = transformations.first else {
                completion()
                return
            }
            animateFieryRage(spriteForeground: spriteForeground, sprites: sprites, transformation: trans, runeAnimation: runeAnimation, completion: completion)
            
        case .moveEarth:
            guard let trans = transformations.first,
                  let tileTrans = trans.tileTransformation else {
                completion()
                return
            }
            
            animateMoveEarth(sprites: sprites, tileTransformation: tileTrans, completion: completion)
            
            return
            
        case .monsterCrush:
            guard let trans = transformations.first
            else {
                completion()
                return
            }
            animateMonsterCrush(sprites: sprites, transformation: trans, runeSpriteSheet: runeAnimation, completion: completion)
            
        case .liquifyMonsters:
            guard let trans = transformations.first,
                  let targetTileTypes = trans.tileTransformation?.compactMap({ TargetTileType(target: $0.initial, type: sprites[$0.initial].type) }),
                  let spriteActions = createLiquifyMonstersAnimation(delayBefore: delayBefore, sprites: sprites, targetTileTypes: targetTileTypes)
            else {
                completion()
                return
            }
                animate(spriteActions, completion: completion)
            
            
        default: break
        }
    }
    
    func createRuneWithFireballAnimation(delayBefore: TimeInterval, sprites: [[DFTileSpriteNode]], tileCoords: [TileCoord], playerPosition: TileCoord, spriteForeground: SKNode, runeAnimationSpriteSheet: SpriteSheet) -> [SpriteAction] {
        var spriteActions: [SpriteAction] = []
        
        var delay = 0.0
        for tileCoord in tileCoords {
            let (fireballDuration, fireballAnimation) = createFireballAnimation(sprites: sprites, from: playerPosition, to: tileCoord, delayBeforeShoot: delay, spriteForeground: spriteForeground, runeAnimation: runeAnimationSpriteSheet)
            
            if let screenShake = shakeScreen(duration: 0.25, ampX: 15, ampY: 15, delayBefore: fireballDuration) {
                spriteActions.append(screenShake)
            }
            
            if case TileType.monster = sprites[tileCoord].type {
                let spriteAction = createMonsterDyingAnimation(sprite: sprites[tileCoord], durationWaitBefore: fireballDuration)
                spriteActions.append(spriteAction)
            }
            
            spriteActions.append(fireballAnimation)
            delay += 0.5
        }
        
        return spriteActions
    }
    
    func createFlashAnimation(delayBefore: TimeInterval, spriteToFlash: SKSpriteNode, numberOfFlash: Int, lengthOfFlash: TimeInterval, lengthBetweenFlash: TimeInterval, removeFromParent: Bool) -> [SpriteAction] {
        var spriteActions: [SpriteAction] = []
        
        let flashOff = SKAction.fadeOut(withDuration: 0.1)
        let flashOn = SKAction.fadeIn(withDuration: 0.1)
        let waitWhileOff = SKAction.wait(forDuration: lengthBetweenFlash)
        let waitWhileOn = SKAction.wait(forDuration: lengthOfFlash)
        let fullCycleDuration: TimeInterval = 0.1 + 0.1 + lengthBetweenFlash + lengthOfFlash
        
        for idx in 0..<numberOfFlash {
            let doubleIdx = Double(idx)
            let seq = SKAction.sequence(flashOff, waitWhileOff, flashOn, waitWhileOn).waitBefore(delay: doubleIdx * fullCycleDuration)
            let spriteAction = SpriteAction(spriteToFlash, seq)
            spriteActions.append(spriteAction)
        }
        
        spriteActions = reverseAndDelayActions(actions: spriteActions, reversed: false, delay: delayBefore)
        if removeFromParent {
            spriteActions.append(.init(spriteToFlash, .removeFromParent()).waitBefore(delay: fullCycleDuration * Double(numberOfFlash)))
        }
        return spriteActions
        
    }
    
    func createLiquifyMonstersAnimation(delayBefore: TimeInterval, sprites: [[DFTileSpriteNode]], targetTileTypes: [TargetTileType]) -> [SpriteAction]? {
        guard let _ = foreground, let tileSize = tileSize else { return nil }
        var spriteActions: [SpriteAction] = []
        let cgTileSize = CGSize(widthHeight: tileSize)
        var waitBefore = delayBefore
        
        // animation contants
        let waitBeforeCollapsingInDuration = 0.33
        
        for targetTileType in targetTileTypes {
            waitBefore = delayBefore
            let monsterSprite = sprites[targetTileType.target]
            
            /// show green reticles flashing 3 times
            let greenReticle = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.Sprite.greenReticle), size: cgTileSize)
            monsterSprite.addChild(greenReticle)
            let flashReticle = createFlashAnimation(delayBefore: waitBefore, spriteToFlash: greenReticle, numberOfFlash: 2, lengthOfFlash: 0.2, lengthBetweenFlash: 0.2, removeFromParent: true)
            spriteActions.append(contentsOf: flashReticle)
            
            // allow reticles to flash
            waitBefore += 1.0
            
            var gemMoveDuration: TimeInterval = 0.0
            /// show 10 gems of random colors exploding in a circle
            for idx in 1..<11 {
                let angle: CGFloat = 360 * (Double(idx)/10)
                let randomGem = Item(type: .gem, amount: 1, color: ShiftShaft_Color.randomCrystalColor)
                let gemSprite = SKSpriteNode(texture: SKTexture(imageNamed: randomGem.textureName), size: cgTileSize.scale(by: 0.33))
                let waitToAdd = SKAction.run {
                    monsterSprite.addChild(gemSprite)
                }.waitBefore(delay: waitBefore)
                spriteActions.append(.init(monsterSprite, waitToAdd))
                gemSprite.zPosition = 10_000_000

                let moveSpeed: CGFloat = 500
                let circleRadius: CGFloat = 100
                let moveDuration = circleRadius / moveSpeed
                let moveToX = circleRadius * cos(angle)
                let moveToY = circleRadius * sin(angle)
                let moveToPoint = CGPoint(x: moveToX, y: moveToY)

                let moveAction = SKAction.move(to: moveToPoint, duration: moveDuration)
                let reverseMoveAction = SKAction.move(to: .zero, duration: moveDuration)
                moveAction.timingMode = .easeOut
                reverseMoveAction.timingMode = .easeIn

                let gemWaitAction = SKAction.wait(forDuration: waitBeforeCollapsingInDuration)

                let finalGemSeq = SKAction.sequence(moveAction, gemWaitAction, reverseMoveAction, .removeFromParent())
                spriteActions.append(.init(gemSprite, finalGemSeq))

                gemMoveDuration = moveDuration*2
            }

            // wait until gems come back inbefore poofing
            waitBefore += waitBeforeCollapsingInDuration + gemMoveDuration


            /// get each monster sprite and show it poofing
            let smokeAnimation = smokeAnimation
            let poofSeq = SKAction.sequence(smokeAnimation).waitBefore(delay: waitBefore)
            let spriteToRunAction = monsterSprite

            spriteActions.append(.init(spriteToRunAction, poofSeq))

            if let shakeScreen = shakeScreen(duration: 0.2, amp: 30, delayBefore: waitBefore) {
                spriteActions.append(shakeScreen)
            }
        }
        
        return spriteActions
    }
    
    func animateFlameLine(spriteForeground: SKNode, sprites: [[DFTileSpriteNode]], transformation: Transformation, runeSpriteSheet: SpriteSheet, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        let monstersDies: [MonsterDies] = transformation.monstersDies ?? []
        let affectedTiles: [TileCoord] = transformation.tileTransformation?.map( { $0.initial }) ?? []
        for coord in affectedTiles {
            let tileSprite = sprites[coord]
            
            let emptySprite = SKSpriteNode(imageNamed: "empty")
            emptySprite.size = tileSprite.size
            emptySprite.position = tileSprite.position
            emptySprite.zPosition = tileSprite.zPosition + 1
            
            /// add the sprite to the scene
            spriteForeground.addChild(emptySprite)
            
            /// do the animation
            let runeAnimationFrames = runeSpriteSheet.animationFrames()
            let duration = Double(runeAnimationFrames.count) * timePerFrame()
            let runeAnimationAction = SKAction.animate(with: runeAnimationFrames, timePerFrame: timePerFrame())
            
            // add the dying animtion if the rune killed a monster
            if monstersDies.contains(where: { $0.tileCoord == coord }) {
                let dyingAnimation = createMonsterDyingAnimation(sprite: tileSprite, durationWaitBefore: duration * 1.75)
                spriteActions.append(dyingAnimation)
                
            }
            // remove the sprite from the scene
            let removeAction = SKAction.removeFromParent()
            let sequence: SKAction =  SKAction.sequence([runeAnimationAction, runeAnimationAction.reversed(), removeAction])
            
            let spriteAction = SpriteAction(sprite: emptySprite, action: sequence)
            spriteActions.append(spriteAction)
        }
        animate(spriteActions) { completion() }

    
    
    }
    
    func animateMonsterCrush(sprites: [[DFTileSpriteNode]], transformation: Transformation, runeSpriteSheet: SpriteSheet, completion: @escaping () -> Void) {
        guard let monsterCoords = transformation.monstersDies?.map({ $0.tileCoord }) else {
            completion()
            return
        }
        
        var spriteActions: [SpriteAction] = []
        let fadeDuration = 0.2
        let waitBeforeKill = 0.2
        let scaleBy: CGFloat = 1.5
        let fadeTo: CGFloat = 0.9
        
        for coord in monsterCoords {
            let sprite = sprites[coord]
            
            let emptySprite = SKSpriteNode(texture: SKTexture(imageNamed:Constants.monsterCrushSpriteName), size: tileCGSize)
            let addTo = SKAction.run {
                emptySprite.zPosition = 100
                emptySprite.alpha = 0.5
                sprite.addChild(emptySprite)
            }
            
            let waitAction = SKAction.wait(forDuration: waitBeforeKill)
            let fadeIn = SKAction.fadeAlpha(to: fadeTo, duration: fadeDuration)
            let scale = SKAction.scale(by: scaleBy, duration: fadeDuration)
            let fadeAndScale = SKAction.group(fadeIn, scale, curve: .easeIn)
            let playAnimation = SKAction.animate(with: runeSpriteSheet.animationFrames(), timePerFrame: timePerFrame())
            let emptyAllAction = SKAction.sequence(fadeAndScale, waitAction, playAnimation, waitAction, .removeFromParent())
            
            // add the sprite to the monster sprite
            
            spriteActions.append(.init(sprite, addTo))
            // play the animation for the monster crush
            
            spriteActions.append(.init(emptySprite, emptyAllAction))
            // append the dying animation if needed
            if let dyingAnimation = sprite.dyingAnimation(durationWaitBefore: waitBeforeKill + fadeDuration) {
                spriteActions.append(dyingAnimation)
            }
            
        }
        
        animate(spriteActions, completion: completion)
        
    }
    
    func animateMoveEarth(sprites: [[DFTileSpriteNode]], tileTransformation: [TileTransformation], completion: @escaping () -> Void) {
        
        var spriteActions: [SpriteAction] = []
        
        let liftUpDuration = 0.25
        let moveAwayDuration = 0.33
        let pausedBetweenActions = 0.25
        
        let scaleUpBy: CGFloat = 1.33
        let scaleDownBy: CGFloat = 1/scaleUpBy
        let smokeScaleBy: CGFloat = 2.0
        
        let shakeDuration = 0.1
        let shakeAmp = 100
        
        // calculate wait duration before screen shake and smoke
        let timeBeforeFirstScreenShake = liftUpDuration + pausedBetweenActions + moveAwayDuration + pausedBetweenActions + liftUpDuration - shakeDuration
        let timeBeforeSecondScreenShake = liftUpDuration + pausedBetweenActions + moveAwayDuration + pausedBetweenActions + liftUpDuration + moveAwayDuration + pausedBetweenActions + liftUpDuration - shakeDuration
        
        let timeBeforeFirstSmoke = liftUpDuration + pausedBetweenActions + moveAwayDuration + pausedBetweenActions + liftUpDuration - shakeDuration*2
        let timeBeforeSecondSmoke = liftUpDuration + pausedBetweenActions + moveAwayDuration + pausedBetweenActions + liftUpDuration + moveAwayDuration + pausedBetweenActions + liftUpDuration - shakeDuration*2
        
        var positionDictionary: [TileCoord: CGPoint] = [:]
        let maxRow: Int = tileTransformation.max(by: {
            $0.initial.row < $1.initial.row
        })?.initial.row ?? 0
        
        // lift up both rows
        for tileTransformation in tileTransformation {
            let liftUp = SKAction.scale(by: scaleUpBy, duration: liftUpDuration)
            liftUp.timingMode = .easeOut
            
            
            let sprite = sprites[tileTransformation.initial]
            
            spriteActions.append(.init(sprite, liftUp))
            
            // save this position for later
            positionDictionary[tileTransformation.initial] = sprite.position
        }
        
        // move them away from eachother to make space
        for tileTransformation in tileTransformation {
            var actions: [SKAction] = []
            
            var moveToPoint: CGPoint = .zero
            if tileTransformation.initial.row == maxRow {
                // move up and away from the row
                let position = positionDictionary[tileTransformation.initial]
                moveToPoint = CGPoint(x: position?.x ?? 0, y: (position?.y ?? 0) + 300.0)
            } else {
                // move to the point
                let position = positionDictionary[tileTransformation.end]
                moveToPoint = CGPoint(x: position?.x ?? 0, y: position?.y ?? 0)
            }
            
            let waitDuration = liftUpDuration + pausedBetweenActions
            let waitAction = SKAction.wait(forDuration: waitDuration)
            let moveAway = SKAction.move(to: moveToPoint, duration: moveAwayDuration)
            moveAway.timingMode = .easeOut
            
            actions.append(waitAction)
            actions.append(moveAway)
            
            
            // grab this sprite so we can add the smoke animation
            let sprite = sprites[tileTransformation.initial]
            
            // move one down into the space (then shake screen)
            // move the other down into the space (then shake screen)
            let smokeAction: [SpriteAction]
            if tileTransformation.initial.row == maxRow {
                // move down to where it should be
                let position = positionDictionary[tileTransformation.end]
                let moveTo = CGPoint(x: position?.x ?? 0, y: position?.y ?? 0)
                
                let additionalWaitAction = SKAction.wait(forDuration: 2*pausedBetweenActions)
                let pauseBetweenMoveAndScale = SKAction.wait(forDuration: pausedBetweenActions)
                let moveAction = SKAction.move(to: moveTo, duration: moveAwayDuration)
                moveAction.timingMode = .easeOut
                let scaleDown = SKAction.scale(by: scaleDownBy, duration: liftUpDuration)
                scaleDown.timingMode = .easeOut
                
                actions.append(contentsOf: [additionalWaitAction, moveAction, pauseBetweenMoveAndScale, scaleDown])
                
                
                smokeAction = smokeAnimation(addToSprite: sprite, scaleBy: smokeScaleBy, durationBefore: timeBeforeSecondSmoke)
                
            } else {
                // move down into the board
                let additionalWaitAction = SKAction.wait(forDuration: pausedBetweenActions)
                let scaleDown = SKAction.scale(by: scaleDownBy, duration: liftUpDuration)
                scaleDown.timingMode = .easeOut
                
                actions.append(contentsOf: [additionalWaitAction, scaleDown])
                
                smokeAction = smokeAnimation(addToSprite: sprite, scaleBy: smokeScaleBy, durationBefore: timeBeforeFirstSmoke)
                
            }
            spriteActions.append(.init(sprite, SKAction.sequence(actions)))
            spriteActions.append(contentsOf: smokeAction)
        }
        
        
        // time before the first screen shake
        if let firstShake = shakeScreen(duration: shakeDuration, amp: shakeAmp, delayBefore: timeBeforeFirstScreenShake, timingMode: .linear) {
            spriteActions.append(firstShake)
            
        }
        
        // time before second
        if let secondShake = shakeScreen(duration: shakeDuration, amp: shakeAmp, delayBefore: timeBeforeSecondScreenShake, timingMode: .linear) {
            spriteActions.append(secondShake)
        }
        
        // shake the entire board
//        for sprite in sprites.flatMap({ $0 }) {
//            let shake = shakeNode(node: sprite, duration: timeBeforeSecondScreenShake, ampX: 5, ampY: 5, delayBefore: 0.0, timingMode: .linear)
//            spriteActions.append(shake)
//        }
        
        animate(spriteActions, completion: completion)
    }
    
    func createFireballAnimation(sprites: [[DFTileSpriteNode]], from startcoord: TileCoord, to targetCoord: TileCoord, delayBeforeShoot: Double, spriteForeground: SKNode, runeAnimation: SpriteSheet) -> (animationDuration: Double, spriteAction: SpriteAction) {
        let flyingSpeed = 0.1
        let startSprite = sprites[startcoord]
        let targetSprite = sprites[targetCoord]
        
        // get the distance the fireball needs to travel
        let horizontalDistane = startcoord.distance(to: targetCoord, along: .horizontal)
        let verticalDistane = startcoord.distance(to: targetCoord, along: .vertical)
        let distance = CGFloat.hypotenuseDistance(sideALength: CGFloat(horizontalDistane), sideBLength: CGFloat(verticalDistane))
        
        // the time the fireball actually flies
        let duration = Double(distance * flyingSpeed)
            
        // determine where to rotate the sprite
        // this xDistance and yDistance can be negative
        let xDistance = CGFloat(startcoord.totalDistance(to: targetCoord, along: .horizontal))
        let yDistance = CGFloat(startcoord.totalDistance(to: targetCoord, along: .vertical))
        // this is the angle we want to get to
        let angle = CGFloat.angle(sideALength: CGFloat(horizontalDistane),
                                  sideBLength: CGFloat(verticalDistane))
        // this detemines how much we actually need to rotate by
        let rotateAngle = CGFloat.rotateAngle(startAngle: .pi*3/2, targetAngle: angle, xDistance: xDistance, yDistance: yDistance)
        let rotateAction = SKAction.rotate(byAngle: rotateAngle, duration: 0)
        
        
        let frames = Double(runeAnimation.animationFrames().count)
        
        let waitBeforeShoot = SKAction.wait(forDuration: delayBeforeShoot)
        let fireballAction = SKAction.repeat(SKAction.animate(with: runeAnimation.animationFrames(), timePerFrame: timePerFrame()), count: Int(duration * 0.07 * frames))
        let moveAction = SKAction.move(to: targetSprite.position, duration: duration)
        moveAction.timingMode = .easeIn
        let combinedAction = SKAction.group([fireballAction, moveAction])
        let removeAction = SKAction.removeFromParent()
        
            
        let sequencedActions = SKAction.sequence([
            rotateAction,
            waitBeforeShoot,
            combinedAction,
            smokeAnimation,
            removeAction
        ])
        
        
        let fireballSpriteContainer = SKSpriteNode(color: .clear,
                                                   size: tileCGSize.scale(by: 2))
            
            
        //start the fireball from the player
        fireballSpriteContainer.position = startSprite.position
        fireballSpriteContainer.zPosition = Precedence.flying.rawValue
        spriteForeground.addChild(fireballSpriteContainer)
        return (animationDuration: duration + delayBeforeShoot + 0.14, spriteAction: SpriteAction(sprite: fireballSpriteContainer, action: sequencedActions)) // a lil extra time for the smoke animation

    }
    
    func animateFieryRage(spriteForeground: SKNode, sprites: [[DFTileSpriteNode]], transformation: Transformation, runeAnimation: SpriteSheet, completion: @escaping () -> Void) {
        // determine how many monsters actually die by using the tile transformations
        // shoot a fireball in the 4 orthogonal directions
        // some of the fireballs should end at a monster
        // if the fireball doesnt kill a monster then it should end on the side of the board
        // take time between firing each fireball
        
        guard let tileTrans = transformation.tileTransformation,
              let playerCoord = playerCoord(sprites) else {
            completion()
            return
        }
        
        var spriteActions: [SpriteAction] = []
        
        var delayBeforeShoot = 0.25
        for tileTran in tileTrans {
            let targetCoord = tileTran.initial
            
            // lets create some trailing ghost
            var fireballDuration: Double = 0.0

            
            var zPosition = Precedence.flying.rawValue
            var alpha = 1.0
            var innerDelayBeforeShoot = 0.0
            for _ in 0..<5 {
                
                let (innerFireballDuration, fireballAnimation) = createFireballAnimation(sprites: sprites, from: playerCoord, to: targetCoord, delayBeforeShoot: delayBeforeShoot + innerDelayBeforeShoot, spriteForeground: spriteForeground, runeAnimation: runeAnimation)

                fireballAnimation.sprite.alpha = alpha
                fireballAnimation.sprite.zPosition = zPosition
                spriteActions.append(fireballAnimation)
                
                zPosition -= 50
                alpha -= 0.15
                innerDelayBeforeShoot += 0.02
                
                fireballDuration = innerFireballDuration
                
            }
            
            if let screenShake = shakeScreen(duration: 0.25, ampX: 15, ampY: 15, delayBefore: fireballDuration) {
                spriteActions.append(screenShake)
            }
            
            if case TileType.monster = sprites[targetCoord].type {
                let monsterSpriteAction = createMonsterDyingAnimation(sprite: sprites[targetCoord], durationWaitBefore: fireballDuration)
                spriteActions.append(monsterSpriteAction)
            }
            
            
            delayBeforeShoot += 0.5
                        
        }
        
        
        animate(spriteActions, completion: completion)
    }
    
    func animateDrillDownRuneUsed(spriteForeground: SKNode, sprites: [[DFTileSpriteNode]], transformation: Transformation, completion: @escaping () -> Void) {
        guard let playerTileTrans = transformation.tileTransformation?.first else {
            completion()
            return
        }
        var spriteActions: [SpriteAction] = []
        // the player will fall 1 tile every 0.21 seconds
        let fallSpeed = 0.21
        let inBetweenTime = 0.05
        let initialWait = 1.0
        var totalDuration = initialWait
        var waitDuration = initialWait
        
        // get the player tile trans
        let playerSprite = sprites[playerTileTrans.initial]
        
        // fall to each tile we destroy and pause a moment before destroying the next tile
        for destroyedTile in playerTileTrans.coordsBelowStartIncludingEnd {
            // get the target position
            let targetPlayerPosition = sprites[destroyedTile].position
            
            // wait before falling
            let waitAction = SKAction.wait(forDuration: waitDuration)
            let fallAction = SKAction.move(to: targetPlayerPosition, duration: fallSpeed)
            fallAction.timingMode = .easeInEaseOut
            let seq = SKAction.sequence([waitAction, fallAction])
            
            spriteActions.append(.init(playerSprite, seq))
            
            let destroyedSprite = sprites[destroyedTile]
            // show the thing dying or exploding
            switch destroyedSprite.type {
            case .monster:
                let dying = createMonsterDyingAnimation(sprite: destroyedSprite, durationWaitBefore: waitDuration)
                spriteActions.append(dying)
            case .rock:
                if let crumble = destroyedSprite.crumble(true, delayBefore: waitDuration) {
                    spriteActions.append(crumble)
                }
            default:
                break
            }
            waitDuration += (fallSpeed + inBetweenTime)
            totalDuration += fallSpeed + inBetweenTime
        }
        
        // add the drill and animation on top of it
        let drillAnimatingSprite = SKSpriteNode(texture: SKTexture(imageNamed: "rune-drill-down-frame-1"), size: tileCGSize.scale(by: 2))
        drillAnimatingSprite.alpha = 0.75
        drillAnimatingSprite.zPosition = 1000
        playerSprite.addChild(drillAnimatingSprite)
        
        // calculate how many times to animate the loop
        let loops: Int = Int(ceil((totalDuration / CGFloat(4.0*timePerFrame()))))
        let loopDrillAnimation = SKAction.repeat(drillDownAnimation, count: loops)
        let drillSeq = SKAction.sequence([loopDrillAnimation, .removeFromParent()])
        spriteActions.append(.init(drillAnimatingSprite, drillSeq))
        
        // shake the fricking screen
        if let screenShake = shakeScreen(duration: totalDuration, ampX: 10, ampY: 10, delayBefore: 0.0) {
            spriteActions.append(screenShake)
        }
        
        animate(spriteActions, completion: completion)
    }
    
}
