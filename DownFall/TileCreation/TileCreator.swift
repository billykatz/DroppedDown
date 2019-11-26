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
    var updatedEntity: EntityModel?
    var boardSize: Int = 0
    
    required init(_ entities: [EntityModel],
         difficulty: Difficulty,
         updatedEntity: EntityModel? = nil) {
        self.entities = entities
        self.difficulty = difficulty
        self.updatedEntity = updatedEntity
    }
    
    func randomTile(_ given: Int) -> TileType {
        let index = abs(given) % TileType.allCases.count
        switch TileType.allCases[index] {
        case .monster:
            return randomMonster(given)
        default:
            return TileType.allCases[index]
        }
    }
    
    func randomMonster(_ given: Int) -> TileType {
        let index = Int.random(EntityModel.monsterCases.count)
        switch EntityModel.monsterCases[index] {
        case .dragon:
            return TileType.monster(entities[3])
        case .rat:
            return TileType.monster(entities[4])
        case .bat:
            return TileType.monster(entities[5])
        case .player:
            fatalError("monstersCases should not included player")
        }
        
    }
    
    func randomRock(_ given: Int) -> TileType {
        let index = abs(given) % TileType.rockCases.count
        return TileType.rockCases[index]
    }
    
    var maxMonsters: Int {
        //TODO: dont hardcode
        return difficulty.maxExpectedMonsters(for: 10)
    }

    func tiles(for tiles: [[Tile]]) -> [Tile] {
        var newTiles: [Tile] = []
        var newMonsterCount = 0
        let currentMonsterCount =  typeCount(for: tiles, of: .monster(.zero)).count
        // The paramter tiles array has .empty tiles in it
        // Create new tiles until we have enough to cover the empty tiles
        while (newTiles.count < typeCount(for: tiles, of: .empty).count) {
            let nextTile = Tile(type: randomTile(randomSource.nextInt()))
            
            switch nextTile.type {
            case .blueRock, .blackRock, .greenRock, .purpleRock, .brownRock:
                newTiles.append(nextTile)
            case .empty, .item, .player, .fireball:
                ()
            case .exit:
                if typeCount(for: tiles, of: .exit).count < 1,
                    !newTiles.contains(Tile.exit)
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
               difficulty: Difficulty) -> [[Tile]] {
        self.boardSize = boardSize
        var newTiles: [Tile] = []
        while (newTiles.count < boardSize * boardSize) {
            let nextTile = Tile(type: randomRock(randomSource.nextInt()))
            
            switch nextTile.type {
            case .blueRock, .blackRock, .greenRock, .purpleRock, .brownRock:
                newTiles.append(nextTile)
            case .exit, .player, .monster, .item, .empty, .fireball:
                assertionFailure("randomRock should only create rocks")
            }
        }
        
        var tiles: [[Tile]] = []
        var currIdx = 0
        for row in 0..<boardSize {
            tiles.append([])
            for _ in 0..<boardSize {
                tiles[row].append(newTiles[currIdx])
                currIdx += 1
            }
        }
        
        let playerQuadrant = Quadrant.allCases[Int.random(Quadrant.allCases.count)]
        let playerPosition = playerQuadrant.randomCoord(for: boardSize)
        tiles[playerPosition.x][playerPosition.y] = Tile(type: .player(playerEntityData))
        
        let upperMonsterbound = Int(Double(tiles.count))
        
        for _ in 0..<maxMonsters {
            let randomRow = Int.random(upperMonsterbound)
            let randomCol = Int.random(upperMonsterbound)
            guard playerPosition != TileCoord(randomRow,randomCol),
                !TileCoord(randomRow, randomCol).isOrthogonallyAdjacent(to: playerPosition) else { continue }
            tiles[randomRow][randomCol] = Tile(type: randomMonster(randomSource.nextInt()))
        }
        
        //place the exit on the opposite side of the grid
        let exitQuadrant = playerQuadrant.opposite
        let exitPosition = exitQuadrant.randomCoord(for: boardSize)
        
        tiles[exitPosition.x][exitPosition.y] = Tile.exit
        
        return tiles
        
    }
    
    var playerEntityData: EntityModel {
        
        //TODO remove this hack
        guard updatedEntity == nil else {
            return updatedEntity!
        }
        switch difficulty {
        case .easy:
            return entities[0]
        case .normal:
            return entities[1]
        case .hard:
            return entities[2]
        case .tutorial1:
            return entities[0]
        }
    }
}
