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
    
    func gameWin(transformation: Transformation?,
                 sprites: [[DFTileSpriteNode]],
                 completion: (() -> Void)? = nil) {
        guard let transformation = transformation,
            let playerWinTransformation = transformation.tileTransformation?.first?.first else {
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
        minecart.position = CGPoint.position(minecart.frame, inside: exitSprite.frame, verticaliy: .center, anchor: .center)
        
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
    
    func animateGold(goldSprites: [SKSpriteNode], gained: Int, from startPosition: CGPoint, to endPosition: CGPoint) { 
        var index = 0
        let animations: [(SKSpriteNode, SKAction)] = goldSprites.map { sprite in
            let wait = SKAction.wait(forDuration: Double(index) * AnimationSettings.Board.goldWaitTime)
            let moveAction = SKAction.move(to: endPosition, duration: AnimationSettings.Board.goldGainSpeedEnd)
            index += 1
            return (sprite, SKAction.sequence([wait,moveAction, SKAction.removeFromParent()]))
        }
        animate(animations)
    }
    
    func animate(_ spriteActions: [(SKSpriteNode, SKAction)], completion: (() -> Void)? = nil) {
        if spriteActions.count == 0 { completion?() }
        var numActions = spriteActions.count
        // tell each child to run it's action
        for (child, action) in spriteActions {
            child.run(action) {
                numActions -= 1
                if numActions == 0 {
                    completion?()                    
                }
            }
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
    
    func animate(attackInputType: InputType,
                 foreground: SKNode,
                 tiles: [[Tile]],
                 sprites: [[DFTileSpriteNode]],
                 positions: ([TileCoord]) -> [CGPoint],
                 completion: (() -> Void)?) {
        guard case InputType.attack(_,
                                    let attackerPosition,
                                    let defenderPosition,
                                    let affectedTiles) = attackInputType else { return }
        
        /*
         Attack animations involve a few things depending on the attack.
         
         There is the animation of the attacker.
         The animation of the defender.
         The sprite/animation of the projectile
         
         However, there is not always a projectile involved.  For example, a player hitting a rat with their pick axe.
         
         The basic sequence of attacks are:
         - animate the attacker
         - if there are projectiles, animate those
         
         When we are all said and finished, we should call animations finished to move on
         
         */
        
        var attackAnimationFrames: [SKTexture]?
        var projectileAnimationFrames: [SKTexture]?
        var defenderAnimationFrames: [SKTexture]?
        
        // get the attack animation
        if case let TileType.monster(monsterData) = tiles[attackerPosition].type {
            attackAnimationFrames = monsterData.animations.attackAnimation
        } else if case let TileType.player(playerData) = tiles[attackerPosition].type {
            attackAnimationFrames = playerData.animations.attackAnimation
        }
        
        // get the projectile animation
        // set a default projectileLength
        var projectileLength: Double = 0
        var projectileRetracts = false
        var isProjectileSequenced = false
        if case let TileType.monster(monsterData) = tiles[attackerPosition].type {
            projectileAnimationFrames = monsterData.animations.projectileAnimation
            switch monsterData.type {
            case .alamo:
                projectileLength = 6
                projectileRetracts = true
                isProjectileSequenced = true
            case .dragon:
                isProjectileSequenced = true
                projectileLength = Double(projectileAnimationFrames?.count ?? 0)
            default:
                // TODO implement different projectile lengths based on the attacker
                projectileLength = Double(projectileAnimationFrames?.count ?? 0)
                ()
            }
        } else if case let TileType.player(playerData) = tiles[attackerPosition].type {
            projectileAnimationFrames = playerData.animations.projectileAnimation
        }
        
        // get the defender animation
        if let defenderPosition = defenderPosition {
            if case let TileType.monster(monsterData) = tiles[defenderPosition].type {
                defenderAnimationFrames = monsterData.animations.hurtAnimation
            } else if case let TileType.player(playerData) = tiles[defenderPosition].type {
                defenderAnimationFrames = playerData.animations.hurtAnimation
            }
        }
        
        
        // group up the actions so we can run them sequentially
        var groupedActions: [SKAction] = []
        let timePerFrame = 0.07
        let projectileTilePerFrame = 0.03
        
        // CAREFUL: Synchronizing with main thread
        let dispatchGroup = DispatchGroup()
        
        
        // attack
        if let frames = attackAnimationFrames {
            let attackAnimation = SKAction.animate(with: frames, timePerFrame: timePerFrame)
                        
            dispatchGroup.enter()
            groupedActions.append(
                SKAction.run {
                    sprites[attackerPosition].run(attackAnimation) {
                        dispatchGroup.leave()
                    }
                }
            )
        }
        
        // projectile
        var projectileGroup: [SKAction] = []
        
        /// certain projectiles like Alamo's attack move across a tile and animate while extending across the entire tile.  This can give the illusion of a connected attack.  The first X frames in an attack are is projectile moving across the tile.  The last Y frames are the projectile animating while stretched across the tile.
        /// This variable `frames` holds the attack as it moves across the tile
        let frames = Array<SKTexture>(projectileAnimationFrames?[0..<Int(projectileLength)] ?? [])
        if frames.count > 0 {
            
            /// this is a local time per frame variable because projectiles feel better when they move faster
            let timePerFrame = projectileTilePerFrame
            
            /// the TileCoords of the affected tiles
            let positions = positions(affectedTiles)
            for (idx, position) in positions.enumerated() {
                
                /// the initial projectile animation
                var projectileAnimations: [SKAction] = [SKAction.animate(with: frames, timePerFrame: timePerFrame)]
                
                /// Create a sprite where to run the animations
                /// This will get added and removed from the foreground node
                let sprite = SKSpriteNode(color: .clear, size: CGSize(width: 100, height: 100))
                sprite.position = position
                sprite.zPosition = Precedence.menu.rawValue
                
                /// The following actions are sequenced.
                var sequencedActions: [SKAction] = []
                
                /// For Alamo's attack, the projectile goes out and comes back.
                /// We need to animate an `idle` animation and a reverse of the original projectile aniamtion to create this effect
                if projectileRetracts, let totalFrames = projectileAnimationFrames?.count {
                    /// For each tile besides the last.  Animate an idle animation for the correct amount of time
                    if idx < positions.count - 1 {
                        let idleFrames = Array<SKTexture>(projectileAnimationFrames?[Int(projectileLength)..<totalFrames] ?? [])
                        let idleAnimation = SKAction.animate(with: idleFrames, timePerFrame: timePerFrame)
                        
                        /// It is really helpful to have the projectile frames be a multiple of the idle frames
                        let projectileToIdleRatio = frames.count / idleFrames.count
                        let outAndBackConstant = 2
                        let numberOfTilesAfterThis = (positions.count - idx - 1)
                        
                        /// The equation for how many times to repeat the idle
                        let repeatCount = outAndBackConstant * projectileToIdleRatio * numberOfTilesAfterThis
                        
                        /// The repeat animation
                        let repeated = SKAction.repeat(idleAnimation, count: repeatCount)
                        projectileAnimations.append(repeated)
                    }
                    
                    /// For every tile, we will eventually show the original animation in reverese
                    let retractAnimation = SKAction.animate(with: frames.reversed(), timePerFrame: timePerFrame)
                    projectileAnimations.append(retractAnimation)
                }
                
                if isProjectileSequenced {
                    /// Created a wait action to wait before animating.
                    /// For example, if a projectile will fly across 3 tiles, then the 2nd and 2rd tile need to wait before displaying the projectile
                    let waitAction = SKAction.wait(forDuration: Double(idx) * Double(frames.count) * timePerFrame)
                    sequencedActions.append(waitAction)
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
        }
        if projectileGroup.count > 0 {
            groupedActions.append(SKAction.group(projectileGroup))
        }
        
        //defender
        if let defenderPosition = defenderPosition,
            let frames = defenderAnimationFrames {
            let defenderAnimation = SKAction.animate(with: frames, timePerFrame: timePerFrame)
            dispatchGroup.enter()
            groupedActions.append(
                SKAction.run {
                    sprites[defenderPosition].run(defenderAnimation) {
                        dispatchGroup.leave()
                    }
                }
            )
        }
        
        
        foreground.run(SKAction.sequence(groupedActions))
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
        
    }

}
