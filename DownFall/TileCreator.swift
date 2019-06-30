//
//  TileCreator.swift
//  DownFall
//
//  Created by William Katz on 1/9/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import GameplayKit

class TileCreator: TileStrategy {
    
    func randomTile(_ given: Int) -> TileType {
        let index = abs(given) % TileType.allCases.count
        switch TileType.allCases[index] {
        case .item:
            if randomSource.nextInt().isMultiple(of: 2) {
                return TileType.gem
            } else {
                return TileType.empty
            }
        case .monster:
            if randomSource.nextInt().isMultiple(of: 2), !spawnedGem {
                spawnedGem = true
                return TileType.monster(entities[1])
            } else {
                return TileType.monster(entities[0])
            }
        default:
            return TileType.allCases[index]
        }
    }
    
    func randomRock(_ given: Int) -> TileType {
        let index = abs(given) % TileType.rockCases.count
        return TileType.rockCases[index]
    }

    var spawnedGem = false
    var randomSource = GKLinearCongruentialRandomSource()
    var entities: [EntityModel]
    
    
    init(_ entities: [EntityModel]) {
        self.entities = entities
    }
    
    func tiles(for tiles: [[TileType]], difficulty: Difficulty = .normal) -> [TileType] {
        var newTiles: [TileType] = []
        var newMonsterCount = 0
        let maxMonsters = 4
        let currentMonsterCount =  typeCount(for: tiles, of: .monster(.zero)).count
        while (newTiles.count < typeCount(for: tiles, of: .empty).count) {
            let nextTile = randomTile(randomSource.nextInt())
            
            switch nextTile {
            case .player:
                if typeCount(for: tiles, of: .player(.zero)).count < 1 && !newTiles.contains(.player(.zero)) {
                    newTiles.append(nextTile)
                }
            case .blueRock, .blackRock, .greenRock:
                newTiles.append(nextTile)
            case .empty, .item:
                ()
            case .exit:
                if typeCount(for: tiles, of: .exit).count < 1,
                    !newTiles.contains(.exit),
                    randomSource.nextInt().isMultiple(of: 3)
                {
                    newTiles.append(nextTile)
                }
            case .monster:
                if currentMonsterCount + newMonsterCount < maxMonsters  {
                    newMonsterCount += 1
                    newTiles.append(nextTile)
                }
            }
        }
        return newTiles
    }
    
    /**
    Create a 2d Array of tile types
    - Parameters:
     - boardSize: The width and height of a board
     - entities: An array of entities loaded from data
     - difficulty: The level of difficuly
 
    */
    func board(_ boardSize: Int, difficulty: Difficulty) -> [[TileType]] {
        
        //TODO: determine when we should add monsters to a new board
        
        var newTiles: [TileType] = []
        while (newTiles.count < boardSize * boardSize) {
            let nextTile = randomRock(randomSource.nextInt())
            
            switch nextTile {
            case .blueRock, .blackRock, .greenRock:
                newTiles.append(nextTile)
            case .exit, .player, .monster, .item, .empty:
                assertionFailure("randomRock should only create rocks")
            }
        }
        
        var tiles: [[TileType]] = []
        var currIdx = 0
        for row in 0..<boardSize {
            tiles.append([])
            for _ in 0..<boardSize {
                tiles[row].append(newTiles[currIdx])
                currIdx += 1
            }
        }
        let lowerbound = Int(Double(tiles.count) * 0.33)
        
        let playerPosition = TileCoord((Int.random(lowerbound) + lowerbound), (Int.random(lowerbound) + lowerbound))
        tiles[playerPosition.x][playerPosition.y] = TileType.player(entities[2])
        
        return tiles

    }

}
