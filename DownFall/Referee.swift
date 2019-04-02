//
//  Referee.swift
//  DownFallTests
//
//  Created by William Katz on 12/29/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation

class Referee {

    static func enterRules(_ tiles: [[TileType]]?) {
        InputQueue.append(Referee.enforceRules(tiles))
    }
    
    static func enforceRules(_ tiles: [[TileType]]?) -> Input {
        guard let tiles = tiles else { return Input(.reffingFinished) }
        
        func getTilePosition(_ type: TileType) -> TileCoord? {
            for i in 0..<tiles.count {
                for j in 0..<tiles[i].count {
                    if tiles[i][j] == type {
                        return TileCoord(i,j)
                    }
                }
            }
            return nil
        }
        
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


        
        let playerPosition = getTilePosition(.player())
        let exitPosition = getTilePosition(.exit)
        
        func playerWins() -> Bool {
            guard let playerRow = playerPosition?.x,
                let playerCol = playerPosition?.y,
                let exitRow = exitPosition?.x,
                let exitCol = exitPosition?.y else { return false }
            return playerRow == exitRow + 1 && playerCol == exitCol
        }
        
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
            }

            return TileCoord(targetRow, targetCol)
        }
        
        func calculateAttacks(combatTile: CombatTileData, from position: TileCoord) -> [TileCoord] {
            let (attackDirections, attackRange) = combatTile.attackVector
            var affectedTiles: [TileCoord] = []
            for direction in attackDirections {
                for i in attackRange {
                    //TODO: consider how to add logic that stops at the first thing it hits
                    let target = calculateTarget(in: direction, distance: i, from: position)
                    if isWithinBounds(target) {
                        affectedTiles.append(target)
                    }
                }
            }
            return affectedTiles
        }
        
        func calculatePossibleAttacks(combatTile: CombatTileData, from position: TileCoord) -> [TileCoord] {
            let (_, attackRange) = combatTile.attackVector
            var affectedTiles: [TileCoord] = []
            for direction in Directions.all {
                for i in attackRange {
                    //TODO: consider how to add logic that stops at the first thing it hits
                    let target = calculateTarget(in: direction, distance: i, from: position)
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
            if case TileType.player(let data) = attacker  {
                return calculateAttacks(combatTile: data, from: position)
            } else if case TileType.greenMonster(let data) = attacker {
                return calculateAttacks(combatTile: data, from: position)
            }
            return []
        }
        
        
        func attackableTiles(from position: TileCoord) -> [TileCoord] {
            let attacker = tiles[position]
            if case TileType.player(let data) = attacker  {
                return calculatePossibleAttacks(combatTile: data, from: position)
            } else if case TileType.greenMonster(let data) = attacker {
                return calculatePossibleAttacks(combatTile: data, from: position)
            }
            return []
        }
        
        func playerHasPossibleAttack() -> Bool {
            guard let playerPosition = playerPosition,
                case TileType.player(let playerCombat) = tiles[playerPosition],
                playerCombat.canAttack else { return false }
            
            for attackedTile in attackableTiles(from: playerPosition) {
                if case TileType.greenMonster(_) = tiles[attackedTile] {
                    return true
                }
            }
            return false
        }
        
        func playerAttacks() -> Input? {
            guard let playerPosition = playerPosition,
                case TileType.player(let playerCombat) = tiles[playerPosition],
                playerCombat.canAttack else { return nil }
            for attackedTile in attackedTiles(from: playerPosition) {
                if case TileType.greenMonster(let data) = tiles[attackedTile], data.hp > 0 {
                    return Input(.attack(playerPosition, attackedTile))
                }
            }
            return nil
        }
        
        
        func monsterAttacks() -> Input? {
            for (i, row) in tiles.enumerated() {
                for (j, _) in row.enumerated() {
                    let potentialMonsterPosition = TileCoord(i, j)
                    if case TileType.greenMonster(let monsterCombat) = tiles[potentialMonsterPosition],
                        monsterCombat.canAttack {
                        for attackedTile in attackedTiles(from: potentialMonsterPosition) {
                            if case TileType.player(_) = tiles[attackedTile] {
                                return Input(.attack(potentialMonsterPosition, attackedTile))
                            }
                        }
                    }
                }
            }
            return nil
        }
        
        func monsterDies() -> Input? {
            for (i, row) in tiles.enumerated() {
                for (j, _) in row.enumerated() {
                    if case TileType.greenMonster(let data) = tiles[TileCoord(i,j)] {
                        if data.hp == 0 {
                            return Input(.monsterDies(TileCoord(i,j)))
                        }
                    }
                }
            }
            return nil
        }
        
        // Game rules are enforced in the following priorities
        // Game Win
        // Game Lose
        // Player attack
        // Monster attack
        // Monster Die
        
        if playerWins() {
            return Input(.gameWin)
        } else if !boardHasMoreMoves() {
            return Input(.gameLose)
        }
        
        
        if let attack = playerAttacks() {
            return attack
        }
        
        if let monsterAttack = monsterAttacks() {
            return monsterAttack
        }
        
        if let deadMonster = monsterDies() {
            return deadMonster
        }

        return Input(.reffingFinished)
    }

}
