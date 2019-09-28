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
    
    init(_ entities: [EntityModel],
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
        let index = abs(given) % EntityModel.monsterCases.count
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
        //TODO: dont hardcode
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
                    !newTiles.contains(.exit)
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
        self.boardSize = boardSize
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
        
        let playerQuadrant = Quadrant.allCases[Int.random(Quadrant.allCases.count)]
        let playerPosition = playerQuadrant.randomCoord(for: boardSize)
        tiles[playerPosition.x][playerPosition.y] = TileType.player(playerEntityData)
        
        let upperMonsterbound = Int(Double(tiles.count))
        
        for _ in 0..<maxMonsters {
            let randomRow = Int.random(upperMonsterbound)
            let randomCol = Int.random(upperMonsterbound)
            guard playerPosition != TileCoord(randomRow,randomCol),
                !TileCoord(randomRow, randomCol).isOrthogonallyAdjacent(to: playerPosition) else { continue }
            tiles[randomRow][randomCol] = randomMonster(randomSource.nextInt())
        }
        
        //place the exit on the opposite side of the grid
        let exitQuadrant = playerQuadrant.opposite
        let exitPosition = exitQuadrant.randomCoord(for: boardSize)
        
        tiles[exitPosition.x][exitPosition.y] = TileType.exit
        
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
        }
    }
}

enum Quadrant: CaseIterable {
    case northEast
    case northWest
    case southEast
    case southWest
    
    var opposite: Quadrant {
        switch self {
        case .northEast:
            return .southWest
        case .northWest:
            return .southEast
        case .southEast:
            return .northWest
        case .southWest:
            return .northEast
        }
    }
    
    func randomCoord(for boardSize: Int) -> TileCoord {
        switch self {
        case .northEast:
            return TileCoord(Int.random(in: 2*boardSize/3..<boardSize),
                             Int.random(in: 2*boardSize/3..<boardSize))
        case .northWest:
            return TileCoord(Int.random(in: 2*boardSize/3..<boardSize),
                             Int.random(in: 0...boardSize/3))

        case .southEast:
            return TileCoord(Int.random(in: 0...boardSize/3),
                             Int.random(in: 2*boardSize/3..<boardSize))
        case .southWest:
            return TileCoord(Int.random(in: 0...boardSize/3),
                             Int.random(in: 0...boardSize/3))

        }
    }
}
