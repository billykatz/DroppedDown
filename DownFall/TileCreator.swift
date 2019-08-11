//
//  TileCreator.swift
//  DownFall
//
//  Created by William Katz on 1/9/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import GameplayKit

class TileCreator: TileStrategy {
    
    var spawnedGem = false
    var randomSource = GKLinearCongruentialRandomSource()
    let entities: [EntityModel]
    let difficulty: Difficulty
    let objectiveTracker: ProvidesObjectiveData
    var updatedEntity: EntityModel?
    
    init(_ entities: [EntityModel],
         difficulty: Difficulty,
         objectiveTracker: ProvidesObjectiveData,
         updatedEntity: EntityModel? = nil) {
        self.entities = entities
        self.difficulty = difficulty
        self.objectiveTracker = objectiveTracker
        self.updatedEntity = updatedEntity
    }
    
    func randomTile(_ given: Int) -> TileType {
        let index = abs(given) % TileType.allCases.count
        switch TileType.allCases[index] {
        case .monster:
            return TileType.monster(entities[6])
        default:
            return TileType.allCases[index]
        }
    }
    
    func randomRock(_ given: Int) -> TileType {
        let index = abs(given) % TileType.rockCases.count
        return TileType.rockCases[index]
    }
    
    func getTilePosition(_ type: TileType, tiles: [[TileType]]) -> TileCoord? {
        for i in 0..<tiles.count {
            for j in 0..<tiles[i].count {
                if tiles[i][j] == type {
                    return TileCoord(i,j)
                }
            }
        }
        return nil
    }
    
    var maxMonsters: Int {
        return difficulty.maxExpectedMonsters(for: 10)
    }

    
    func tiles(for tiles: [[TileType]]) -> [TileType] {
        var newTiles: [TileType] = []
        var newMonsterCount = 0
        let currentMonsterCount =  typeCount(for: tiles, of: .monster(.zero)).count
        while (newTiles.count < typeCount(for: tiles, of: .empty).count) {
            let nextTile = randomTile(randomSource.nextInt())
            
            switch nextTile {
            case .blueRock, .blackRock, .greenRock:
                newTiles.append(nextTile)
            case .empty, .item, .player, .fireball:
                ()
            case .exit:
                if typeCount(for: tiles, of: .exit).count < 1,
                    !newTiles.contains(.exit),
                    objectiveTracker.shouldSpawnExit
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
    func board(_ boardSize: Int,
               difficulty: Difficulty) -> [[TileType]] {
        
        //TODO: determine when we should add monsters to a new board
        
        var newTiles: [TileType] = []
        while (newTiles.count < boardSize * boardSize) {
            let nextTile = randomRock(randomSource.nextInt())
            
            switch nextTile {
            case .blueRock, .blackRock, .greenRock:
                newTiles.append(nextTile)
            case .exit, .player, .monster, .item, .empty, .fireball:
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
        tiles[playerPosition.x][playerPosition.y] = TileType.player(playerEntityData)
        
        let lowerMonsterbound = Int(Double(tiles.count))
        
        for _ in 0..<maxMonsters/2 {
            let randomRow = Int.random(lowerMonsterbound)
            let randomCol = Int.random(lowerMonsterbound)
            guard !TileCoord(randomRow, randomCol).isOrthogonallyAdjacent(to: playerPosition) else { continue }
            tiles[randomRow][randomCol] = TileType.monster(entities[6])
        }
        
        return tiles

    }
    
    var playerEntityData: EntityModel {
        
        //TODO remove this hack
        guard updatedEntity == nil else {
            return updatedEntity!
        }
        switch difficulty {
        case .easy:
            return entities[2]
        case .normal:
            return entities[3]
        case .hard:
            return entities[4]
        }
    }
}
