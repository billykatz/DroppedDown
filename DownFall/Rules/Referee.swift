//
//  Referee.swift
//  DownFallTests
//
//  Created by William Katz on 12/29/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation

class Referee {
    static var level: Level = .zero

    static func injectLevel(_ level: Level) {
        Referee.level = level
    }
    
    static func enterRules(_ tiles: [[Tile]]?) {
        InputQueue.append(Referee.enforceRules(tiles))
    }
    
    static func enforceRules(_ tiles: [[Tile]]?) -> Input {
        guard let tiles = tiles, !tiles.isEmpty else { return Input(.reffingFinished(newTurn: false)) }
        
        func valid(neighbor: TileCoord?, for currCoord: TileCoord?) -> Bool {
            guard let (neighborRow, neighborCol) = neighbor?.tuple,
                let (tileRow, tileCol) = currCoord?.tuple else { return false }
            guard neighborRow >= 0, //lower bound
                neighborCol >= 0, // lower bound
                neighborRow < tiles.count, // upper bound
                neighborCol < tiles.count, // upper bound
                neighbor != currCoord // not the same coord
                else { return false }
            let tileSum = tileRow + tileCol
            let neighborSum = neighborRow + neighborCol
            let difference = abs(neighborSum - tileSum)
            guard difference <= 1 //tiles are within one of eachother
                && ((tileSum % 2 == 0  && neighborSum % 2 == 1) || (tileSum % 2 == 1 && neighborSum % 2 == 0)) // they are not diagonally touching
                else { return false }
            return true
        }
        
        func findNeighbors(_ x: Int, _ y: Int) -> [TileCoord] {
            guard x >= 0,
                x < tiles.count,
                y >= 0,
                y < tiles.count else { return [] }
            var queue = [TileCoord(x, y)]
            var tileCoordSet = Set(queue)
            var head = 0
            
            while head < queue.count {
                let tileRow = queue[head].x
                let tileCol = queue[head].y
                let currTile = tiles[tileRow][tileCol]
                head += 1
                //add neighbors to queue
                for i in tileRow-1...tileRow+1 {
                    for j in tileCol-1...tileCol+1 {
                        //check that it is within bounds, that we havent visited it before, and it's the same type as us
                        guard valid(neighbor: TileCoord(i,j), for: TileCoord(tileRow, tileCol)),
                            !tileCoordSet.contains(TileCoord(i,j)),
                            tiles[i][j] == currTile else { continue }
                        //valid neighbor within bounds
                        queue.append(TileCoord(i,j))
                        tileCoordSet.insert(TileCoord(i,j))
                    }
                }
            }
            return queue
        }
        
        func validCardinalNeighbors(of coord: TileCoord) -> [TileCoord] {
            var neighbors : [TileCoord] = []
            let (tileRow, tileCol) = coord.tuple
            for i in tileRow-1...tileRow+1 {
                for j in tileCol-1...tileCol+1 {
                    //check that it is within bounds
                    if valid(neighbor: TileCoord(i,j), for: TileCoord(tileRow, tileCol)) {
                        neighbors.append(TileCoord(i, j))
                    }
                }
            }
            return neighbors
        }
        
        
        
        let playerPosition = getTilePosition(.player(.zero), tiles: tiles)
        let exitPosition = getTilePosition(.exit(blocked: false), tiles: tiles)
        let dynamitePositions = getTilePositions(.dynamite(DynamiteFuse(count: 0, hasBeenDecremented: false)), tiles: tiles)
        let emptyPositions = getTilePosition(.empty, tiles: tiles)
        
        func boardHasMoreMoves() -> Bool {
            guard let playerPosition = playerPosition else { return false }
            for (i, row) in tiles.enumerated() {
                for (j, _) in row.enumerated() {
                    if findNeighbors(i, j).count > 2 || valid(neighbor: exitPosition, for: playerPosition) || playerHasPossibleAttack() {
                        return true
                    }
                }
            }
            return false
        }
        
        func calculateTargetSlope(in slopedDirection: AttackSlope, distance i: Int, from position: TileCoord) -> TileCoord {
            let (initialRow, initialCol) = position.tuple
            
            // Take the initial position and calculate the target
            // Add the slope's "up" value multiplied by the distance to the row
            // Add the slope's "over" value multipled by the distane to the column
            return TileCoord(initialRow + (i * slopedDirection.up), initialCol + (i * slopedDirection.over))
        }
        
        func calculateAttacks(for entity: EntityModel, from position: TileCoord) -> ([TileCoord], [TileCoord]) {
            
            /// remove attacks that are out of bounds
            let attackedTiles = entity.attack.targets(from: position).compactMap { target -> TileCoord? in
                if isWithinBounds(target) {
                    return target
                }
                return nil
            }
            
            /// determine if there are any pillars that are attacks
            var pillarCoords = Set<TileCoord>()
            for tileCoord in attackedTiles {
                if tiles[tileCoord].type.isAPillar {
                    pillarCoords.insert(tileCoord)
                }
            }
            
            let playerCoord = attackedTiles.first { coord in
                if case TileType.player = tiles[coord].type {
                    return true
                }
                return false
            }
            
            /// deteremine if the pillar stops attacks and remove those tile coord.
            var attackedTilesWithPillarsBlocking: [TileCoord] = []
            for tileCoord in attackedTiles {
                var blockedByPillar = false
                for pillar in pillarCoords {
                    if tileCoord.existsOnLineAfter(b: pillar, onLineFrom: position) {
                        blockedByPillar = true
                    }
                }
                
                /// TODO: we need to fix this ugly logic
                if entity.type == .sally, let playerCoord = playerCoord {
                    if !tileCoord.existsOnLineBetween(b: playerCoord, onLineFrom: position) {
                        blockedByPillar = true
                    }
                }
                
                if !blockedByPillar {
                    attackedTilesWithPillarsBlocking.append(tileCoord)
                }
            }
            
            /// return attack tiles considering pillars blocking attacks and the original attacks tile coords
            return (attackedTilesWithPillarsBlocking, attackedTiles)
        }
        
        func calculatePossibleAttacks(for entity: EntityModel, from position: TileCoord) -> [TileCoord] {
            let attackRange = entity.attack.range
            var affectedTiles: [TileCoord] = []
            for attackSlopes in AttackSlope.playerPossibleAttacks {
                for i in attackRange.lower...attackRange.upper {
                    // TODO: Let's add a property to attacks that says if the attack goes thru targets or not
                    let target = calculateTargetSlope(in: attackSlopes, distance: i, from: position)
                    if isWithinBounds(target) {
                        affectedTiles.append(target)
                    }
                }
            }
            return affectedTiles
        }
        
        func isWithinBounds(_ tileCoord: TileCoord) -> Bool {
            let (tileRow, tileCol) = tileCoord.tuple
            return tileRow >= 0 && //lower bound
                tileCol >= 0 && // lower bound
                tileRow < tiles.count && // upper bound
                tileCol < tiles.count
        }
        
        
        func attackedTiles(from position: TileCoord) -> ([TileCoord], [TileCoord]) {
            let attacker = tiles[position]
            if case TileType.player(let player) = attacker.type  {
                return calculateAttacks(for: player, from: position)
            } else if case TileType.monster(let monster) = attacker.type {
                return calculateAttacks(for: monster, from: position)
            }
            return ([], [])
        }
        
        
        func attackableTiles(from position: TileCoord) -> [TileCoord] {
            let attacker = tiles[position]
            if case TileType.player(let player) = attacker.type  {
                return calculatePossibleAttacks(for: player, from: position)
            } else if case TileType.monster(let monster) = attacker.type {
                return calculatePossibleAttacks(for: monster, from: position)
            }
            return []
        }
        
        func playerHasPossibleAttack() -> Bool {
            guard let playerPosition = playerPosition,
                case TileType.player(let playerData) = tiles[playerPosition].type,
                playerData.canAttack else { return false }
            
            for attackedTile in attackableTiles(from: playerPosition) {
                if case TileType.monster = tiles[attackedTile].type {
                    return true
                }
            }
            return false
        }
        
        func playerAttacks() -> Input? {
            guard let playerPosition = playerPosition,
                case TileType.player(let playerData) = tiles[playerPosition].type,
                playerData.canAttack else { return nil }
            let (_, attackedTileArray) = attackedTiles(from: playerPosition)
            for attackedTile in attackedTileArray {
                if case TileType.monster(let data) = tiles[attackedTile].type, data.hp > 0 {
                    return Input(.attack(attackType: playerData.attack.type,
                                         attacker: playerPosition,
                                         defender: attackedTile,
                                         affectedTiles: attackedTileArray,
                                         dodged: false))
                }
            }
            return nil
        }
        
        
        func monsterAttacks() -> Input? {
            for (i, row) in tiles.enumerated() {
                for (j, _) in row.enumerated() {
                    let potentialMonsterPosition = TileCoord(i, j)
                    
                    guard case TileType.monster(let monsterData) = tiles[potentialMonsterPosition].type,
                        monsterData.canAttack,
                        monsterData.hp > 0 else { continue }
                    
                    let attackFrequency = monsterData.attack.frequency
                    let totalTurns = monsterData.attack.turns
                    let shouldAttack: Bool
                    
                    switch monsterData.attack.type {
                    case .charges:
                        shouldAttack = monsterData.attack.isCharged
                    case .areaOfEffect, .targets:
                        shouldAttack = totalTurns % attackFrequency == 0
                    }
                    
                    guard shouldAttack else { continue }
                    
                    
                    let (nonBlockedAttackedTiles, allAttackedTileArray) = attackedTiles(from: potentialMonsterPosition)

                    for attackedTile in nonBlockedAttackedTiles {
                        if case TileType.player = tiles[attackedTile].type {
                            return Input(.attack(attackType: monsterData.attack.type,
                                                 attacker: potentialMonsterPosition,
                                                 defender: attackedTile,
                                                 affectedTiles: nonBlockedAttackedTiles,
                                                 dodged: false))
                        } else if case TileType.pillar = tiles[attackedTile].type,
                            allAttackedTileArray.contains(where: { (coord) -> Bool in
                                if case TileType.player = tiles[coord].type {
                                    return true
                                }
                                return false
                            })
                            {
                            return Input(.attack(attackType: monsterData.attack.type,
                                                 attacker: potentialMonsterPosition,
                                                 defender: attackedTile,
                                                 affectedTiles: nonBlockedAttackedTiles,
                                                 dodged: false
                                ))
                        }
                    }
                    
                    // At this point, there was no player in the affect tiles
                    // We should still create an attack input, with the defender was nil
                    // So that the board and renderer can do their things
                    if monsterData.attack.type == .areaOfEffect {
                        return Input(.attack(attackType: monsterData.attack.type,
                                             attacker: potentialMonsterPosition,
                                             defender: nil,
                                             affectedTiles: nonBlockedAttackedTiles,
                                             dodged: false))
                    }
                    
                }
            }
            return nil
        }
        
        func monsterDies() -> Input? {
            for (i, row) in tiles.enumerated() {
                for (j, _) in row.enumerated() {
                    if case TileType.monster(let data) = tiles[TileCoord(i,j)].type {
                        if data.hp <= 0 {
                            return Input(.monsterDies(TileCoord(i,j), data.type))
                        }
                    }
                }
            }
            return nil
        }
        
        func playerIsDead() -> Bool {
            guard let playerPosition = playerPosition,
                case TileType.player(let playerCombat) = tiles[playerPosition].type else { return false }
            return playerCombat.hp <= 0
        }
        
        func playerCollectsItem() -> Input? {
            guard let playerPosition = playerPosition,
                case let TileType.player(playerData) = tiles[playerPosition].type,
                isWithinBounds(playerPosition.rowBelow),
                case TileType.item(let item) = tiles[playerPosition.rowBelow].type
                else { return nil }
            return Input(.collectItem(playerPosition.rowBelow, item, playerData.carry.total(in: item.type.currencyType)), tiles)
        }
        
        func decrementDynamiteFuses() -> Input? {
            guard let dynamitePos = dynamitePositions else { return nil }
            return Input(.decrementDynamites(dynamitePos))
        }
        
        /// We need to refill if ever there is an empty tile with a non-empty and non-pillar tile above it
        /// Edge cases: If there is a chain of 2 or more empty tiles witha pillar directly on top of them, we do not need to refill
        /// Edge cases: If there is an empty tile beneath in the same column as a pillar, but the pillar is not directly above the empty tile.  we _do_ need to refill
        func refillEmptyTiles() -> Input? {
            var needsRefill = false
            for col in 0..<tiles.count {
                var pillarIdx = -1
                var prevEmptyIdx = -1
                for row in 0..<tiles.count {
                    var currEmptyIdx = -1
                    switch tiles[row][col].type {
                    case .pillar:
                        // save the most revent pillar idx
                        pillarIdx = row
                    case .empty:
                        // save the current empty idx
                        currEmptyIdx = row
                    default:
                        /// if the row above a empty tile is not empty and not a pillar, then we need to shit down tiles
                        if prevEmptyIdx >= 0 {
                            needsRefill = true
                        }
                    }
                    
                    /// if the previous tile was empty and the current tile is a pillar, we do not need to shift down.  Reset the indexes so we can properly determine more shift down cases up the column.
                    if prevEmptyIdx >= 0 && // empty has been set
                        pillarIdx >= 0 && // pillar has been set
                        prevEmptyIdx == pillarIdx - 1 {
                        /// the string of empties has met a pillar
                        /// reset everything and continue going up the row
                        
                        prevEmptyIdx = -1
                        pillarIdx = -1
                    }
                    
                    /// We need to remember the previous empty tile and the current tile to recognize adjacent empty tiles.
                    /// Save the current empty tile index for the next loop
                    if currEmptyIdx >= 0 {
                        prevEmptyIdx = currEmptyIdx
                    }
                    
                    
                    /// edge case where the top most tile is empty
                    if currEmptyIdx == tiles.count - 1 {
                        needsRefill = true
                    }
                }
            }
            guard needsRefill else { return nil }
            return Input(.refillEmpty)
        }

        
        // Game rules are enforced in the following priorities
        // Game Win
        // Game Lose
        // Player attack
        // Monster attack
        // Monster Die
        // Player collects gems
        
        let winRule = Rulebook.winRule
        
        if let input = winRule.apply(tiles) {
            return input
        } else if playerIsDead() {
            return Input(.gameLose("You ran out of health"))
        }
        
        
        if let attack = playerAttacks() {
            return attack
        }
        
        if let deadMonster = monsterDies() {
            return deadMonster
        }
        
        if let collectItem = playerCollectsItem() {
            return collectItem
        }
        
        if let refill = refillEmptyTiles() {
            return refill
        }
        
        if let monsterAttack = monsterAttacks() {
            return monsterAttack
        }
        
        if let decrementDynamite = decrementDynamiteFuses() {
            return decrementDynamite
        }
        
        
        let newTurn = TurnWatcher.shared.getNewTurnAndReset()
        return Input(.reffingFinished(newTurn: newTurn), tiles, nil)
    }


}
