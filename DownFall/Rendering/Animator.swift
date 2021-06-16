//
//  Animator.swift
//  DownFall
//
//  Created by William Katz on 9/15/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit


struct Animator {
    
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
        
 
            
        case .rainEmbers:
                       
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
                
                spriteActions.append(SpriteAction(sprite: playerSprite, action: floatUpAction))
                
            }
            
            animate(spriteActions) { completion?() }
        case .flameWall:
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

            
        }
    }
    
    
    public func smokeAnimation() -> SKAction {
        let smokeTexture = SpriteSheet(texture: SKTexture(imageNamed: "smokeAnimation"), rows: 1, columns: 6).animationFrames()
        let smokeAnimation = SKAction.animate(with: smokeTexture, timePerFrame: 0.07)
        return smokeAnimation
    }
    
    public func explodeAnimation() -> SKAction {
        let explodeTexture = SpriteSheet(texture: SKTexture(imageNamed: "explodeAnimation"), rows: 1, columns: 4).animationFrames()
        let explodeAnimation = SKAction.animate(with: explodeTexture, timePerFrame: 0.07)
        return explodeAnimation
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
    
    func animateCollectOffer(offerType: StoreOfferType,  offerSprite: SKSpriteNode, targetPosition: CGPoint, to hud: HUD, completion: @escaping () -> Void) {
        
        
        let moveToAction = SKAction.move(to: targetPosition, duration: AnimationSettings.Board.goldGainSpeedEnd)
        let scaleAction = SKAction.scale(to: Style.Board.goldGainSizeEnd, duration: AnimationSettings.Board.goldGainSpeedEnd)
        let toPosition = offerSprite.frame.center.translate(xOffset: CGFloat.random(in: AnimationSettings.Gem.randomXOffsetRange), yOffset: CGFloat.random(in: AnimationSettings.Gem.randomYOffsetRange))
        let moveAwayAction = SKAction.move(to: toPosition, duration: 0.25)
        let moveToAndScale = SKAction.group([moveToAction, scaleAction])
        let moveAwayMoveToScale = SKAction.sequence([moveAwayAction, moveToAndScale])
        
        moveAwayMoveToScale.timingMode = .easeOut
        
        let hudAction = SKAction.run {
            hud.incrementStat(offer: offerType)
        }
        
        let hudActionRemoveFromparent = SKAction.group([hudAction, .removeFromParent()])
        
        let finalizedAction = SKAction.sequence([moveAwayMoveToScale, hudActionRemoveFromparent])
        
        animate([SpriteAction(sprite: offerSprite, action: finalizedAction)], completion: completion)
    }
    
    func animateGold(goldSprites: [SKSpriteNode], gained: Int, from startPosition: CGPoint, to hud: HUD, in foreground: SKNode, completion: @escaping () -> Void) {
        var index = 0
        
        var hasShownTotalGain = false
        
        let animations: [SpriteAction] = goldSprites.map { sprite in
            let wait = SKAction.wait(forDuration: Double(index) * AnimationSettings.Board.goldWaitTime)
            let toPosition = sprite.frame.center.translate(xOffset: CGFloat.random(in: AnimationSettings.Gem.randomXOffsetRange), yOffset: CGFloat.random(in: AnimationSettings.Gem.randomYOffsetRange))
            
            let moveAwayAction = SKAction.move(to: toPosition, duration: 0.25)
            
            let targetPosition = hud.gemSpriteNode?.convert(hud.gemSpriteNode?.frame.center ?? .zero, to: foreground) ?? .zero
            let moveToAction = SKAction.move(to: targetPosition, duration: AnimationSettings.Board.goldGainSpeedEnd)
            let scaleAction = SKAction.scale(to: Style.Board.goldGainSizeEnd, duration: AnimationSettings.Board.goldGainSpeedEnd)
            
            let moveToAndScale = SKAction.group([moveToAction, scaleAction])
            let moveAwayMoveToScale = SKAction.sequence([moveAwayAction, moveToAndScale])
            
            moveAwayMoveToScale.timingMode = .easeOut
            
            let tickUpHudCounter = SKAction.run {
                hud.incrementCurrencyCountByOne()
                 
                if !hasShownTotalGain {
                    hasShownTotalGain = true
                    hud.showTotalGemGain(goldSprites.count)
                }
            }
            
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

    
    func animate(_ spriteActions: [SpriteAction], completion: @escaping () -> Void) {
        if spriteActions.count == 0 { completion() }
        var numActions = spriteActions.count
        // tell each child to run it's action
        for spriteAction in spriteActions {
            spriteAction.sprite.run(spriteAction.action) {
                numActions -= 1
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
