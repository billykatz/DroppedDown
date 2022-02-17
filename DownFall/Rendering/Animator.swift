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
        static let runeDrillDownSpriteSheetName4 = "rune-drilldown-spriteSheet4"
        static let monsterCrushSpriteName = "rune-monsterCrush-frame-1"
    }

    let foreground: SKNode?
    let tileSize: CGFloat?
    let bossSprite: BossSprite?
    let typeAdvancesLevelGoal: ((TileType) -> CGPoint?)?
    let playableRect: CGRect?
    
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
    
    var tileCGSize: CGSize {
        return CGSize(widthHeight: tileSize ?? .zero)
    }
    
    var poisonDropAnimation: SKAction {
        let posionTexture = SpriteSheet(texture: SKTexture(imageNamed: Constants.poisonDropSpriteSheetName), rows: 1, columns: 8).animationFrames()
        let poisonAnimation = SKAction.animate(with: posionTexture, timePerFrame: 0.07)
        return poisonAnimation
    }

    var smokeAnimation: SKAction {
        let smokeTexture = SpriteSheet(texture: SKTexture(imageNamed: "smokeAnimation"), rows: 1, columns: 6).animationFrames()
        let smokeAnimation = SKAction.animate(with: smokeTexture, timePerFrame: 0.07)
        smokeAnimation.duration = 6 * 0.07
        return smokeAnimation
    }
    
    var drillDownAnimation: SKAction {
        let drillTextures = SpriteSheet(textureName: Constants.runeDrillDownSpriteSheetName4, columns: 4).animationFrames()
        let drillAnimation = SKAction.animate(with: drillTextures, timePerFrame: timePerFrame())
        return drillAnimation
    }
    
    init(foreground: SKNode? = nil,
         tileSize: CGFloat? = nil,
         bossSprite: BossSprite? = nil,
         playableRect: CGRect? = nil,
         tileTypeAdvancesLevelGoal: ((TileType) -> CGPoint?)? = nil
    ) {
        self.foreground = foreground
        self.tileSize = tileSize
        self.bossSprite = bossSprite
        self.playableRect = playableRect
        self.typeAdvancesLevelGoal = tileTypeAdvancesLevelGoal
    }
    
    func smokeAnimation(addToSprite: SKSpriteNode, scaleBy: CGFloat, durationBefore: Double) -> [SpriteAction] {
        let emptySprite = SKSpriteNode(color: .clear, size: tileCGSize)
        let smokeAnimation = smokeAnimation
        let scale = SKAction.scale(by: scaleBy, duration: 0.0)
        let wait = SKAction.wait(forDuration: durationBefore)
        
        let addTo = SKAction.run {
            emptySprite.zPosition = -10
            addToSprite.addChild(emptySprite)
        }
        
        let remove = SKAction.run {
            emptySprite.removeFromParent()
        }
        
        let mainSpriteAction = SKAction.sequence(wait, addTo)
        let emptySpriteAction = SKAction.sequence(scale, smokeAnimation, remove)
        return [.init(addToSprite, mainSpriteAction),
                .init(emptySprite, emptySpriteAction)]
        
    }
    
    func createMonsterDyingAnimation(sprite: DFTileSpriteNode, durationWaitBefore: Double, skipDyingAnimation: Bool = false) -> SpriteAction {
        var actions: [SKAction] = [SKAction.wait(forDuration: 0.0)]
        var durationOfAnimation = 0.0
        if !skipDyingAnimation,
            let dying = sprite.dyingAnimation(durationWaitBefore: durationWaitBefore) {
            actions.append(dying.action)
            durationOfAnimation += dying.duration
        }
        
        if let targetPoint = typeAdvancesLevelGoal?(sprite.type) {
            let animation = createAnimationCompletingGoals(sprite: sprite, to: targetPoint)
            actions.append(animation.action)
        }
        
        
        actions.append(.wait(forDuration: 0.1))
        
        let seq = SKAction.sequence(actions)
        var spriteAction = SpriteAction.init(sprite, seq)
        
        // does not inclue the tiem it takes to fly to the goal
        spriteAction.duration = durationWaitBefore + durationOfAnimation
        
        return spriteAction
    }
    
    func playerCoord(_ sprites: [[DFTileSpriteNode]]) -> TileCoord? {
        return tileCoords(for: sprites, of: .player(.playerZero)).first
    }
    
    func shakeScreen(duration: CGFloat = 0.5, amp: Int = 10, delayBefore: Double = 0, timingMode: SKActionTimingMode = .easeIn) -> SpriteAction? {
        return shakeScreen(duration: duration, ampX: amp, ampY: amp, delayBefore: delayBefore, timingMode: timingMode)
    }
    
    func shakeScreen(duration: CGFloat = 0.5, ampX: Int = 10, ampY: Int = 10, delayBefore: Double = 0, timingMode: SKActionTimingMode = .easeIn) -> SpriteAction? {
        guard let foreground = foreground else { return nil }
        let action = SKAction.shake(duration: duration, amplitudeX: ampX, amplitudeY: ampY)
        let delay = SKAction.wait(forDuration: delayBefore)
        
        return .init(foreground, .sequence(delay, action, curve: timingMode))
    }
    
    
    func shakeNode(node: SKNode, duration: CGFloat = 0.5, amp: Int = 10, delayBefore: Double = 0, timingMode: SKActionTimingMode = .easeIn) -> SpriteAction {
        return self.shakeNode(node: node, duration: duration, ampX: amp, ampY: amp, delayBefore: delayBefore, timingMode: timingMode)
    }
    func shakeNode(node: SKNode, duration: CGFloat = 0.5, ampX: Int = 10, ampY: Int = 10, delayBefore: Double = 0, timingMode: SKActionTimingMode = .easeIn) -> SpriteAction {
        let action = SKAction.shake(duration: duration, amplitudeX: ampX, amplitudeY: ampY)
        let delay = SKAction.wait(forDuration: delayBefore)
        
        return .init(node, .sequence(delay, action, curve: timingMode))
    }
    
    func blinkNode(node: SKNode, delayBefore: Double = 0) -> SpriteAction {
        let duration = 0.01
        let alphaOff = SKAction.fadeAlpha(to: 0.0, duration: duration)
        let alphaOn = SKAction.fadeAlpha(to: 1.0, duration: duration)
        let delay = SKAction.wait(forDuration: delayBefore)
        
        var action = SpriteAction.init(node, .sequence(delay, alphaOff, alphaOn))
        action.duration = duration*2
        return action
    }
    
    
    func animateRune(_ rune: Rune,
                     transformations: [Transformation],
                     affectedTiles: [TileCoord],
                     sprites: [[DFTileSpriteNode]],
                     spriteForeground: SKNode,
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
            
        case .getSwifty, .teleportation:
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
            
        case .rainEmbers, .fireball:
            
            var spriteActions: [SpriteAction] = []
            guard let pp = getTilePosition(.player(.playerZero), tiles: endTiles) else {
                completion()
                return
            }
            
            var delay = 0.0
            for target in affectedTiles {
                let (fireballDuration, fireballAnimation) = createFireballAnimation(sprites: sprites, from: pp, to: target, delayBeforeShoot: delay, spriteForeground: spriteForeground, runeAnimation: runeAnimation)
                
                if let screenShake = shakeScreen(duration: 0.25, ampX: 15, ampY: 15, delayBefore: fireballDuration) {
                    spriteActions.append(screenShake)
                }
                
                if case TileType.monster = sprites[target].type {
                    let spriteAction = createMonsterDyingAnimation(sprite: sprites[target], durationWaitBefore: fireballDuration)
                    spriteActions.append(spriteAction)   
                }
                
                spriteActions.append(fireballAnimation)
                delay += 0.5
            }
            
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
            
        default: break
        }
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
    
    public func explodeAnimation(size: CGSize) -> SKAction {
        let explodeTexture = SpriteSheet(texture: SKTexture(imageNamed: "explodeAnimation"), rows: 1, columns: 4).animationFrames()
        let explodeAnimation = SKAction.animate(with: explodeTexture, timePerFrame: 0.07)
        let scaleToSize = SKAction.scale(to: size, duration: 0.0)
        return SKAction.group([scaleToSize, explodeAnimation])
    }
    
    func timePerFrame() -> Double {
        return 0.07
    }
    
    var sparkleTimePerFrame: Double {
        return timePerFrame() * 1.25
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
        let smokeAnimation = smokeAnimation
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
        
        let speed = CGFloat.random(in: 1000...1100)
        let distance = targetPosition - sprite.position
        let duration = distance.length / speed
        let moveToAction = SKAction.move(to: targetPosition, duration: duration)
        moveToAction.timingMode = .easeIn
        
        let changeZPosition = SKAction.run {
            sprite.zPosition = -100_000
        }
        
        let moveToAndScale = SKAction.group([moveToAction, scaleDown])
        let sequence = SKAction.sequence([scaleUpAction, moveToAndScale, changeZPosition])
        
        return SpriteAction(sprite: sprite, action: sequence)
        
    }
    
    mutating func createAnimationForMiningGems(from coords: [TileCoord], tilesWithGems: [TileCoord], color: ShiftShaft_Color, spriteForeground: SKNode, sprites: [[DFTileSpriteNode]], amountPerRock: Int, tileSize: CGFloat, positionConverter: (TileCoord) -> CGPoint) -> [SpriteAction] {
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
            let actualGemSprite = DFTileSpriteNode(type: .item(Item(type: .gem, amount: 0, color: color)), height: 100, width: 100)
            let targetPosition = positionConverter(tileWithGemCoord)
            actualGemSprite.position = targetPosition
            
            
            
            var total = 0
            var waitTime = 0.0
            
            var numberWaitTime = 0.1
            
            
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
                let initialWait = SKAction.wait(forDuration: numberWaitTime)
                numberWaitTime += 0.02
                
                // move up and grow
                let moveAndScaleSpeed = 0.3
                let moveUp = SKAction.moveBy(x: 0, y: 150.0, duration: moveAndScaleSpeed)
                let grow = SKAction.scale(to: CGSize(width: 125, height: 125), duration: moveAndScaleSpeed)
                let growAndMove = SKAction.group([grow, moveUp])
                
                let pauseDuration = 0.4
                let pauseToAnimate = SKAction.wait(forDuration: pauseDuration)
                
                
                // move to and shrink
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
                let waitUntilNumberTicksUpDuration = numberWaitTime + moveAndScaleSpeed + pauseDuration + moveAndShrinkSpeed - waitTimeDurationPerRock
                let whiteOutGemWait = SKAction.wait(forDuration: waitUntilNumberTicksUpDuration)
                let whiteOutGemAction = SKAction.sequence([whiteOutGemWait, growTheWhiteOutGem, shrinkTheWhiteOutGem, makewhiteOutGemOriginalSize])
                
                spriteActions.append(SpriteAction(sprite: whiteOutGem, action: whiteOutGemAction))
                
                
                /// make sure we dont go negative
                waitTime += max(minWaitTime, waitTimeDurationPerRock - waitTimeSubtractEachLoop)
                waitTimeSubtractEachLoop += 0.005
            }
            
            
            // wait before doing these actions
            let wait = SKAction.wait(forDuration: numberWaitTime + 0.9)
            
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
            
            // add the actual gem
            let addActualGem = SKAction.run { [spriteForeground] in
                spriteForeground.addChild(actualGemSprite)
            }
            
            // create the sequence
            let sequence = SKAction.sequence([wait, addActualGem, scaleUpAndWiggle, scaleAndMove])
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
                print(numActions)
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
    
    func animatePlayerPayingForBoardShuffle(playerSprite: DFTileSpriteNode, paidTwoHearts: Bool, paidAmount: Int?, spriteForeground: SKNode, completion: @escaping () -> Void) {
        
        let paidWithSprite: SKSpriteNode
        let fullHeartSpriteName = "fullHeart"
        let gemsSpriteName = "crystals"
        var paidAmountString = ""
        if paidTwoHearts {
            paidWithSprite = SKSpriteNode(texture: SKTexture(imageNamed: fullHeartSpriteName), size: tileCGSize)
        } else {
            paidWithSprite = SKSpriteNode(texture: SKTexture(imageNamed: gemsSpriteName), size: tileCGSize)
        }
        
        if let newPaidAmount = paidAmount {
            paidAmountString = "\(newPaidAmount)"
        }
        
        // create and add container over palyer sprite
        let container = SKSpriteNode(texture: nil, size: tileCGSize)
        container.position = playerSprite.position
        container.zPosition = 1000
        spriteForeground.addChild(container)
        
        // create a minus in front of the payment
        let minusString = ParagraphNode(text: "- \(paidAmountString)", fontSize: .fontLargeSize, fontColor: .red)
        minusString.position = CGPoint.position(minusString.frame, inside: container.frame, verticalAlign: .center, horizontalAnchor: .left)
        container.addChild(minusString)
        
        // position the paidWithSprite next to the minus string
        paidWithSprite.position = CGPoint.alignVertically(paidWithSprite.frame, relativeTo: minusString.frame, horizontalAnchor: .right, verticalAlign: .center, verticalPadding: -4.0, horizontalPadding: 4.0, translatedToBounds: true)
        container.addChild(paidWithSprite)
        
        
        // move it up fade away and scale smaller all at the same time
        let duration = Double(1.5)
        let moveUpAction = SKAction.moveBy(x: 0.0, y: 50.0, duration: duration)
        let fadeAwayAction = SKAction.fadeAlpha(to: 0.2, duration: duration)
        
        let seq = SKAction.group(moveUpAction, fadeAwayAction, curve: .easeIn)
        
        animate([.init(container, seq)]) {
            container.removeFromParent()
            completion()
        }
        
        
    }
    
    
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
    
    func animateMineralSpirits(targetTileCoords: [TileCoord], playableRect: CGRect, spriteForeground: SKNode, tileSize: CGFloat, sprites: [[DFTileSpriteNode]], positionInForeground: (TileCoord) -> CGPoint) -> (waitDuration: Double, [SpriteAction]) {
        var spriteActions: [SpriteAction] = []
        let tileSize = CGSize(widthHeight: tileSize)
        
        // duration for movement
        let durationForMovement = 1.0
        
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
            let firstStartingPosition = CGPoint(x: startingX, y: 0.0)
            let secondStartingPosition = CGPoint(x: 0.0, y: startingY)
            
            // choose where to end
            let firstEndingPosition = firstStartingPosition.translate(xOffset: distanceFromTarget * 2, yOffset: 0.0)
            let secondEndPosition = secondStartingPosition.translate(xOffset: 0.0, yOffset: distanceFromTarget * 2)
            
            // create and add both sprites
            let firstMineralSpirit = SKSpriteNode(texture: mineralSpiritsTexture, size: tileSize)
            firstMineralSpirit.position = firstStartingPosition
            emptySprite.addChild(firstMineralSpirit)
            
            let secondMineralSpirit = SKSpriteNode(texture: mineralSpiritsTexture, size: tileSize)
            secondMineralSpirit.position = secondStartingPosition
            emptySprite.addChild(secondMineralSpirit)
            
            for (idx, sprite) in [firstMineralSpirit, secondMineralSpirit].enumerated() {
                let rotate: SKAction
                var startPosition: CGPoint
                var endPosition: CGPoint
                if idx == 0 {
                    rotate = SKAction.rotate(byAngle: -.pi/2, duration: 0.0)
                    startPosition = firstStartingPosition
                    endPosition = firstEndingPosition
                } else {
                    rotate = SKAction.rotate(byAngle: 0.0, duration: 0.0)
                    startPosition = secondStartingPosition
                    endPosition = secondEndPosition
                }
                
                let animateMovement = SKAction.animate(with: mineralSpiritsAttackSpriteSheet.animationFrames(), timePerFrame: timePerFrame())
                let waitBefore = SKAction.wait(forDuration: waitBeforeAdditionalTargets)
                let moveAcrossTheScreen = SKAction.move(to: endPosition, duration: durationForMovement)
                moveAcrossTheScreen.timingMode = .easeInEaseOut
                
                let grouped = SKAction.group(animateMovement, moveAcrossTheScreen)
                let allAction = SKAction.sequence([rotate, waitBefore, grouped])
                
                spriteActions.append(.init(sprite, allAction))
                
                // lets create some trailing ghost
                let trailingOffset: CGFloat = -200.0
                var zPosition = sprite.zPosition
                var alpha = sprite.alpha
                for _ in 0..<5 {
                    zPosition -= 50
                    alpha -= 0.15
                    if idx == 0 {
                        startPosition = startPosition.translate(xOffset: trailingOffset, yOffset: 0.0)
                    } else {
                        startPosition = startPosition.translate(xOffset: 0.0, yOffset: trailingOffset)
                    }
                    
                    let trailingSpirit = SKSpriteNode(texture: mineralSpiritsTexture, size: tileSize)
                    trailingSpirit.position = startPosition
                    trailingSpirit.zPosition = zPosition
                    trailingSpirit.alpha = alpha
                    emptySprite.addChild(trailingSpirit)
                    
                    spriteActions.append(.init(trailingSpirit, allAction))
                    
                }
                
            }
            
            let durationBeforeMonsterTakesDamage = waitBeforeAdditionalTargets + (durationForMovement/2)
            
            // The mineral spirits' kills dont count for the player
            if let takeDamageAnimation = sprites[coord].dyingAnimation() {
                let (sprite, animation) = takeDamageAnimation.tuple
                let waitBefore = SKAction.wait(forDuration: durationBeforeMonsterTakesDamage)
                
                spriteActions.append(.init(sprite, SKAction.sequence([waitBefore, animation])))
            }
            
            
            
            waitBeforeAdditionalTargets += 0.75
        }
        
        waitBeforeAdditionalTargets += durationForMovement - ( durationForMovement/2 )
        
        
        
        
        return (waitDuration: waitBeforeAdditionalTargets, spriteActions)
    }
    
    /// We also want to create an aniamtion for when the mineral spritis kill a monster during the shuffle board (we will want to resuse this animation for other things as well)
    /// Lets take a the mineral spritis sprite sheet and animate  sprite moving across the sceen at an angle
    /// Lets do that twice and make it so that the two sprites cross at the excat point over the monster they are kill
    /// While it animates across the screen, leave behind a trail of white that fades away as the time passes
    /// When the two paths cross the monster should player it's "take damage" animation
    /// When the two paths leave screen then the monsters should die and play their death animation
    
    
    // MARK: - Boss Animations
    
    func animateSpawnMonstersAttack(foreground: SKNode, tileTypes: [TileType], tileSize: CGFloat, startingPosition: CGPoint, targetPositions: [CGPoint], targetSprites: [DFTileSpriteNode], completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        // create a dynamite stick for each dynamiate
        guard let bossSprite = bossSprite else {
            completion()
            return
        }

        var bossAttackSprites: [DFTileSpriteNode] = []
        for tileType in tileTypes {
            let attackSprite = DFTileSpriteNode(type: tileType, height: tileSize, width: tileSize)
            bossAttackSprites.append(attackSprite)
        }
        
        
        // add them to the foreground
        var spritesAlreadyThere = bossSprite.monstersInWebs
        
        // add the monsters to where they already exist on screen
        for sprite in bossAttackSprites {
            var newStartingPosition = spritesAlreadyThere.removeFirstAndReturn(where: { sprite.type.entityType == $0.0 })?.1.monsterSprite.position ?? startingPosition
            
            let newZPosition = spritesAlreadyThere.removeFirstAndReturn(where: { sprite.type.entityType == $0.0 })?.1.monsterSprite.zPosition ?? 100_000
            
            newStartingPosition = bossSprite.convert(newStartingPosition, to: foreground)
            sprite.position = newStartingPosition
            sprite.zPosition = newZPosition
            foreground.addChild(sprite)
        }
        
        var waitTime = 0.0
        // remove them from the boss sprite
        if let ropesPullingUp = createAnimationRopesPullingAway(delayBefore: 0.0) {
            spriteActions.append(contentsOf: ropesPullingUp)
            waitTime += 0.2
        }
        
        // make it appear as if they are being thrown onto the screen
        var actions: [SKAction] = []
        //stagger the initial throw of each dynamite
        for (idx, target) in targetPositions.enumerated() {
            let distance = target - startingPosition
            let speed: Double = 1500
            
            // determine the duration based on the distance to the target
            let duration = Double(distance.length) / speed
            
            // wait before it all for the webs to unfurl
            let waitAction = SKAction.wait(forDuration: waitTime)
            
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
            let sequence = SKAction.sequence([waitAction, moveGrowShrink])
            
            // crumble the rock that gets "hit"
            let spriteToRemoveOnLanding = targetSprites[idx]
            if let crumble = spriteToRemoveOnLanding.crumble() {
                let waitBeforeCrumble = SKAction.wait(forDuration: duration)
                let crumbleAction = crumble.action
                let sequence = SKAction.sequence([waitAction, waitBeforeCrumble, crumbleAction])
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
        
        
        resetBossThenAnimate(spriteActions, completion: completion)
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
            let smoke = smokeAnimation
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
    
    func animateBossPoisonAttack(_ spriteForeground: SKNode, targetedColumns: [Int], targetedTiles: [TileTransformation], sprites: [[DFTileSpriteNode]], tileSize: CGFloat, playableRect: CGRect, completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite else {
            completion()
            return
        }
        
        var spriteActions: [SpriteAction] = []
        var waitBefore: TimeInterval = 0.0
        
        /// Recoil Counter Action to make poison beam look strong
        if let recoil = createBossRecoilFromPoison(delayBefore: waitBefore, reversed: false) {
            spriteActions.append(contentsOf: recoil)
        }

        /// POISON BEAM
        /// also shakes the screen for the duration of the poison beam blast
        if let poisonBeam = createBeamOfPoisonAnimation(delayBefore: waitBefore) {
            let unhidePoisonBeam = SKAction.run {
                bossSprite.spiderPoisonBeam.alpha = 1.0
            }
            let unhidePoison = SpriteAction(bossSprite, unhidePoisonBeam)

            let hidePoisonBeam = SKAction.run {
                bossSprite.spiderPoisonBeam.alpha = 0.0
            }

            let hidePoison = SpriteAction(bossSprite, hidePoisonBeam)

            spriteActions.append(unhidePoison.waitBefore(delay: waitBefore))
            spriteActions.append(poisonBeam)


            if let shake = shakeScreen(duration: poisonBeam.duration / 2, amp: 35, delayBefore: waitBefore) {
                spriteActions.append(shake)
            }

            waitBefore += (poisonBeam.duration / 2)

            spriteActions.append(hidePoison.waitBefore(delay: waitBefore))
        }
        
        /// UNDO Recoil Counter Action to make poison beam look strong
        if let recoil = createBossRecoilFromPoison(delayBefore: waitBefore, reversed: true) {
            spriteActions.append(contentsOf: recoil)
        }

        // Additional wait after the beam closes
        waitBefore += 0.0

        /// UNDO mouth
        if let closeMouth = createToothChompFirstHalfAnimation(delayBefore: 0.0)?.reversed {
            spriteActions.append(closeMouth.waitBefore(delay: waitBefore))
        }

        /// UNDO HEAD
        if let tiltHead = createTiltingHead(delayBefore: waitBefore, reversed: true) {
            spriteActions.append(contentsOf: tiltHead)
        }

        /// UNDO Face
        let undoAngryFace = createAngryFace(reverse: true, waitBeforeDelay: waitBefore)
        spriteActions.append(contentsOf: undoAngryFace)

        
        for column in targetedColumns {
            
            for index in 0..<5 {
                // create 1 poison sprite for each column attack
                let poisonSprite = SKSpriteNode(texture: SKTexture(imageNamed: Constants.poisonDropSpriteName), size: CGSize(width: tileSize, height: tileSize))
                
                // position it at the top and center of the attacked column
                let boardSize = sprites.count
                let topSpriteInColumn = sprites[boardSize-1][column]
                let poisonSpritePosition = CGPoint.alignHorizontally(poisonSprite.frame, relativeTo: playableRect, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.normal, translatedToBounds: true)
                poisonSprite.position = poisonSpritePosition
                poisonSprite.position.y += CGFloat(index * 50)
                poisonSprite.alpha = 1 - (CGFloat(index) * 0.15)
                poisonSprite.position.x = topSpriteInColumn.position.x
                poisonSprite.zPosition = 100_000_000 - CGFloat(index * 100)
                
                // add to the sprite foreground which will auto remove it after animations are finishied
                spriteForeground.addChild(poisonSprite)
                
                // animate it dripping down the column
                // grab the bottom row in the atttacked column
                if let finalRowAttacked = targetedTiles.filter({ $0.initial.column == column }).sorted(by: { $0.initial.row < $1.initial.row }).first?.initial {
                    
                    // calculate the target sprite
                    let targetSprite = sprites[finalRowAttacked]
                    let targetPosition = CGPoint.alignVertically(poisonSprite.frame, relativeTo: targetSprite.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
                    
                    
                    let distance = targetPosition - poisonSprite.position
                    let speed: Double = 2000
                    
                    // the poison should move at the same speed regardless of the distance to the target
                    let duration = Double(distance.length) / speed
                    
                    let moveAction = SKAction.move(to: targetPosition, duration: duration)
                    
                    // after passing the final tile, then you in the splash zone
                    let splashAnimation = self.poisonDropAnimation
                    let sequence = SKAction.sequence([moveAction, splashAnimation, .removeFromParent()])
                    
                    spriteActions.append(SpriteAction.init(poisonSprite, sequence.waitBefore(delay: waitBefore)))
                } else {
                    // after passing the final tile, then you in the splash zone
                    let splashAnimation = self.poisonDropAnimation
                    let sequence = SKAction.sequence([splashAnimation, .removeFromParent()])
                    
                    spriteActions.append(SpriteAction.init(poisonSprite, sequence.waitBefore(delay: waitBefore)))
                }
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
            let smoke = self.smokeAnimation
            
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
                let smoke = self.smokeAnimation
                
                let sprite = sprites[exitCoord.row][exitCoord.column]
                
                let spriteActions = [SpriteAction(sprite: sprite, action: smoke)]
                animate(spriteActions, completion: completion)
            } else {
                completion()
            }
        }
        
        
    }
    
    func animateGameLost(playerData: EntityModel, playerSprite: DFTileSpriteNode, delayBefore: TimeInterval, completion: @escaping () -> Void) {
        guard let dyingAnimation = playerData.animation(of: .dying) else {
            completion()
            return
        }
        
        let animation = SKAction.animate(with: dyingAnimation, timePerFrame: timePerFrame())
        let waitBefore = SKAction.wait(forDuration: delayBefore)
        let seq = SKAction.sequence([waitBefore, animation])
        let spriteAction = SpriteAction(playerSprite, seq)
        
        
        animate([spriteAction], completion: completion)
    }
    
}
