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
    
    func animate(_ transformation: [TileTransformation]?,
                 boardSize: CGFloat,
                 bottomLeft: CGPoint,
                 spriteForeground: SKNode,
                 tileSize: CGFloat,
                 _ completion: (() -> Void)? = nil) {
        guard let transformation = transformation else { return }
        var childActionDict : [SKNode : SKAction] = [:]
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
        for (child, action) in childActionDict {
            child.run(action) {
                completion?()
            }
        }
    }
    
    // Indicate how the entity at a given Coord attacks
    func indicateAttackPattern(touchInputType: InputType,
                               foreground: SKNode,
                               tiles: [[TileType]]?,
                               sprites: [[DFTileSpriteNode]],
                               completion: (() -> Void)?) {
        guard case let InputType.touchBegan(coord, tileType) = touchInputType,
            case let TileType.monster(monsterData) = tileType,
            let tiles = tiles
            else {
                completion?()
                return
        }
        
        
        
        func attackedTiles(in tiles: [[TileType]], from position: TileCoord) -> [TileCoord] {
            guard isWithinBounds(position, boardSize: tiles.count) else { return [] }
            let attacker = tiles[position]
            if case TileType.player(let player) = attacker  {
                return calculateAttacks(for: player, from: position)
            } else if case TileType.monster(let monster) = attacker {
                return calculateAttacks(for: monster, from: position)
            }
            return []
        }
        
        func isWithinBounds(_ tileCoord: TileCoord, boardSize: Int) -> Bool {
            let (tileRow, tileCol) = tileCoord.tuple
            return tileRow >= 0 && //lower bound
                tileCol >= 0 && // lower bound
                tileRow < boardSize && // upper bound
                tileCol < boardSize
        }
        
        func calculateAttacks(for entity: EntityModel, from position: TileCoord) -> [TileCoord] {
            let attackDirections = entity.attack.directions
            let attackRange = entity.attack.range
            var affectedTiles: [TileCoord] = []
            for direction in attackDirections {
                for i in attackRange.lower...attackRange.upper {
                    // TODO: Let's add a property to attacks that says if the attack goes thru targets or not
                    let target = calculateTarget(in: direction, distance: i, from: position)
                    if isWithinBounds(target, boardSize: tiles.count) {
                        affectedTiles.append(target)
                    }
                }
            }
            return affectedTiles
        }

        func calculateTarget(in direction: Direction, distance i: Int, from position: TileCoord) -> TileCoord {
            let (initialRow, initialCol) = position.tuple
            let targetRow: Int
            let targetCol: Int
            switch direction {
            case .north:
                targetRow = initialRow + i
                targetCol = initialCol
            case .south:
                targetRow = initialRow - i
                targetCol = initialCol
            case .east:
                targetCol = initialCol + i
                targetRow = initialRow
            case .west:
                targetCol = initialCol - i
                targetRow = initialRow
            case .northEast:
                targetRow = initialRow + i
                targetCol = initialCol + i
            case .southEast:
                targetRow = initialRow - i
                targetCol = initialCol + i
            case .northWest:
                targetRow = initialRow + i
                targetCol = initialCol - i
            case .southWest:
                targetRow = initialRow - i
                targetCol = initialCol - i
            }
            
            return TileCoord(targetRow, targetCol)
        }

        
        let affectedTile = attackedTiles(in: tiles, from: coord)
        
        for coord in affectedTile {
            sprites[coord].indicateAboutToAttack()
        }
        
        completion?()
        
        //TODO: All this is happneing, but when we run our completion all the sprites are removed and added back to the foreground
        // This is unseful for keeping our UI and state in sync however it removes the sprites that indicate where an enemy attacks
        // We need to figure out how to represent this in our state rather than impratively show this on certain inputs
        
        
        
    }
    
    
    // Animate combat.  This includes:
    // - The attacker animation
    // - The defender animation
    // - And any projectile animation
    func animate(attackInputType: InputType,
                 foreground: SKNode,
                 tiles: [[TileType]],
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
         
         However, there is not always a projectile involved.  For example, a player hitting a rat with their pick axe
         And there doesn't have to be a defender. For example, the bat screams every 3 turns, but doesnt always hit something
         
         The basic sequence of attacks are:
         - animate the attacker
         - if there are projectiles, animate those
         - if there is a defender, animate that
         
         When we are all said and finished, we should call animations finished to move on
         
         */
        
        var attackAnimationFrames: [SKTexture]?
        var projectileAnimationFrames: [SKTexture]?
        var defenderAnimationFrames: [SKTexture]?
        
        // get the attack animation
        if case let TileType.monster(monsterData) = tiles[attackerPosition] {
            attackAnimationFrames = monsterData.animations.attackAnimation
        } else if case let TileType.player(playerData) = tiles[attackerPosition] {
            attackAnimationFrames = playerData.animations.attackAnimation
        }
        
        // get the projectile animation
        if case let TileType.monster(monsterData) = tiles[attackerPosition] {
            projectileAnimationFrames = monsterData.animations.projectileAnimation
        } else if case let TileType.player(playerData) = tiles[attackerPosition] {
            projectileAnimationFrames = playerData.animations.projectileAnimation
        }
        
        // get the defender animation
        if let defenderPosition = defenderPosition {
            if case let TileType.monster(monsterData) = tiles[defenderPosition] {
                defenderAnimationFrames = monsterData.animations.hurtAnimation
            } else if case let TileType.player(playerData) = tiles[defenderPosition] {
                defenderAnimationFrames = playerData.animations.hurtAnimation
            }
        }
        
        
        // group up the actions so we can run them sequentially
        var groupedActions: [SKAction] = []
        let timePerFrame = 0.07
        
        
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
        if let frames = projectileAnimationFrames {
            let positions = positions(affectedTiles)
            let projectileAnimation = SKAction.animate(with: frames, timePerFrame: timePerFrame)
            for position in positions {
                let sprite = SKSpriteNode(color: .clear, size: CGSize(width: 100, height: 100))
                sprite.position = position
                sprite.zPosition = Precedence.menu.rawValue
                groupedActions.append(SKAction.run {
                    foreground.addChild(sprite)
                    sprite.run(projectileAnimation) {
                        sprite.removeFromParent()
                    }
                })
            }
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
        
        
        foreground.run(SKAction.group(groupedActions))
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
        
    }
}
