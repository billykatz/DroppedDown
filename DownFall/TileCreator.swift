//
//  TileCreator.swift
//  DownFall
//
//  Created by William Katz on 1/9/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import GameplayKit

protocol TileCreatorResets {
    static func reset()
}

struct TileCreator: TileStrategy {
    
    static func randomTile(_ given: Int) -> TileType {
        let index = abs(given) % TileType.allCases.count
        return TileType.allCases[index]
    }
    
    static let maxMonsters = 2
    static let maxGems = 1
    static var spawnedGem = false
    
    static func tiles(for board: Board, difficulty: Difficulty = .normal) -> [TileType] {
        var newTiles: [TileType] = []
        var newMonsterCount = 0
        let maxMonsters = 6
        let currentMonsterCount = board.tiles(of: .greenMonster()).count
        while (newTiles.count < board.tiles(of: .empty).count) {
            let nextTile = randomTile(randomSource.nextInt())
            
            switch nextTile {
            case .player:
                if board.tiles(of: .player()).count < 1 && !newTiles.contains(.player()) {
                    newTiles.append(nextTile)
                }
            case .blueRock, .blackRock, .greenRock:
                newTiles.append(nextTile)
            case .empty:
                ()
            case .exit:
                if board.tiles(of: .exit).count < 1,
                    !newTiles.contains(.exit),
                    !newTiles.contains(.gem1),
                    randomSource.nextInt().isMultiple(of: 3)
                {
                    newTiles.append(nextTile)
                }
            case .greenMonster:
                if currentMonsterCount + newMonsterCount < maxMonsters  {
                    newMonsterCount += 1
                    newTiles.append(nextTile)
                }
            case .gem1:
                if randomSource.nextInt().isMultiple(of: 2),
                    !newTiles.contains(.exit),
                    !spawnedGem {
                    newTiles.append(nextTile)
                    spawnedGem = true
                }
            }
        }
        return newTiles
    }
    
    
    
    static func board(_ boardSize: Int, difficulty: Difficulty) -> [[TileType]] {
        
        func getNumber(of type: TileType, in tiles: [[TileType]]) -> Int {
            var numberOf = 0
            for i in 0..<tiles.count {
                for j in 0..<tiles[i].count {
                    if tiles[i][j] == type {
                        numberOf += 1
                    }
                }
            }
            return numberOf
        }

        
        var tiles: [[TileType]] = []
        for row in 0..<boardSize {
            tiles.append([])
            for _ in 0..<boardSize {
                tiles[row].append(TileType.empty)
            }
        }
        
        
        
        var newTiles: [TileType] = []
        var newMonsterCount = 0
        let currentMonsterCount = 0
        while (newTiles.count < boardSize * boardSize) {
            let nextTile = randomTile(randomSource.nextInt())
            
            switch nextTile {
            case .blueRock, .blackRock, .greenRock:
                newTiles.append(nextTile)
            case .empty, .exit, .gem1, .player:
                ()
            case .greenMonster:
                if currentMonsterCount + newMonsterCount < maxMonsters  {
                    newMonsterCount += 1
                    newTiles.append(nextTile)
                }
            }
        }
        
        var currIdx = 0
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                tiles[row][col] = newTiles[currIdx]
                currIdx += 1
            }
        }
        let lowerbound = Int(Double(tiles.count) * 0.33)
        
        let playerPosition = TileCoord((Int.random(lowerbound) + lowerbound), (Int.random(lowerbound) + lowerbound))
        tiles[playerPosition.x][playerPosition.y] = TileType.player()
        
        return tiles

    }
    
    static var randomSource = GKLinearCongruentialRandomSource()

}

extension TileCreator: TileCreatorResets {
    static func reset() {
        spawnedGem = false
    }
}
