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
        let exitPosition = getTilePosition(.exit, tiles: tiles)
        
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
        
        func calculateAttacks(for entity: EntityModel, from position: TileCoord) -> [TileCoord] {
            return entity.attack.targets(from: position).compactMap { target in
                if isWithinBounds(target) {
                    return target
                }
                return nil
            }
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
        
        
        func attackedTiles(from position: TileCoord) -> [TileCoord] {
            let attacker = tiles[position]
            if case TileType.player(let player) = attacker.type  {
                return calculateAttacks(for: player, from: position)
            } else if case TileType.monster(let monster) = attacker.type {
                return calculateAttacks(for: monster, from: position)
            }
            return []
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
            let attackedTileArray = attackedTiles(from: playerPosition)
            for attackedTile in attackedTileArray {
                if case TileType.monster(let data) = tiles[attackedTile].type, data.hp > 0 {
                    return Input(.attack(attackType: playerData.attack.type,
                                         attacker: playerPosition,
                                         defender: attackedTile,
                                         affectedTiles: attackedTileArray))
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
                    
                    let attackedTileArray = attackedTiles(from: potentialMonsterPosition)
                    for attackedTile in attackedTileArray {
                        if case TileType.player = tiles[attackedTile].type {
                            return Input(.attack(attackType: monsterData.attack.type,
                                                 attacker: potentialMonsterPosition,
                                                 defender: attackedTile,
                                                 affectedTiles: attackedTileArray))
                        }
                    }
                    
                    // At this point, there was no player in the affect tiles
                    // We should still create an attack input, with the defender was nil
                    // So that the board and renderer can do their things
                    if monsterData.attack.type == .areaOfEffect {
                        return Input(.attack(attackType: monsterData.attack.type,
                                             attacker: potentialMonsterPosition,
                                             defender: nil,
                                             affectedTiles: attackedTileArray))
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
                            return Input(.monsterDies(TileCoord(i,j)))
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
        } else if !boardHasMoreMoves() {
            return Input(.gameLose("The board has no more moves"))
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
        
        if let monsterAttack = monsterAttacks() {
            return monsterAttack
        }
        
        let newTurn = TurnWatcher.shared.getNewTurnAndReset()
        return Input(.reffingFinished(newTurn: newTurn))
    }


}
