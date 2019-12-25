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
    let entities: EntitiesModel
    let difficulty: Difficulty
    var updatedEntity: EntityModel?
    let boardSize: Int
    var level: Level?
    var specialRocks = 0
    
    required init(_ entities: EntitiesModel,
                  difficulty: Difficulty,
                  updatedEntity: EntityModel? = nil,
                  level: Level?) {
        self.entities = entities
        self.difficulty = difficulty
        self.updatedEntity = updatedEntity
        self.level = level
        self.boardSize = level?.boardSize ?? 0
    }
    
    private func randomTile(_ given: Int) -> TileType {
        let index = abs(given) % TileType.allCases.count
        switch TileType.allCases[index] {
        case .monster:
            return randomMonster(given)
        case .blackRock, .blueRock, .purpleRock, .brownRock, .greenRock, .redRock:
            return randomRock(given)
        default:
            return TileType.allCases[index]
        }
    }
    
    private func randomMonster(_ given: Int) -> TileType {
        
        guard let level = level else { fatalError("You need to init with a level") }
        let totalNumber = level.monsterRatio.values.max { (first, second) -> Bool in
            return first.upper < second.upper
        }
        guard let upperRange = totalNumber?.upper else { fatalError("You need to init with a level") }

        let randomNumber = Int.random(upperRange)
        for (key, value) in level.monsterRatio {
            if value.contains(randomNumber), let data = entities.entity(with: key) {
                return TileType.monster(data)
            }
        }
        
        fatalError("We should always return a random monster from this function.")
        
    }
    
    private func randomRock(_ given: Int) -> TileType {
        guard let level = level else { fatalError("You need to init with a level") }
        let totalNumber = level.rocksRatio.values.max { (first, second) -> Bool in
            return first.upper < second.upper
        }
        guard let upperRange = totalNumber?.upper else { fatalError("You need to init with a level") }
        let randomNumber = Int.random(upperRange)
        for (key, value) in level.rocksRatio {
            if value.contains(randomNumber) {
                return key
            }
        }
        
        fatalError("The randomNumber between 0-\(upperRange-1) should find itself in the range of one of the rocks")
    }
    
    var maxMonstersTotal: Int {
        return level?.maxMonstersTotal ?? 20
    }
    
    var maxMonstersOnScreen: Int {
        return level?.maxMonstersOnScreen ?? 10
    }
    
    var totalMonstersAdded = 0
    
    var goldVariance = 2
    func goldDropped(from monster: EntityModel) -> Int {
        if let goldItem = monster.carry.items.first(where: { $0.type == .gold }) {
            let medianAmount = goldItem.amount * (level?.goldMultiplier ?? 1)
            return Int.random(lower: max(1, medianAmount-goldVariance), upper: medianAmount+goldVariance)
        }
        return 0
    }

    func tiles(for tiles: [[Tile]]) -> [Tile] {
        var newTiles: [Tile] = []
        var newMonsterCount = 0
        let currentMonsterCount = typeCount(for: tiles, of: .monster(.zero)).count
        // The paramter tiles array has .empty tiles in it
        // Create new tiles until we have enough to cover the empty tiles
        while (newTiles.count < typeCount(for: tiles, of: .empty).count) {
            let nextTile = Tile(type: randomTile(randomSource.nextInt()))
            
            switch nextTile.type {
                
            case .purpleRock, .brownRock, .blueRock, .blackRock, .redRock:
                newTiles.append(nextTile)
            case .empty, .item, .player, .fireball:
                ()
            case .greenRock:
                if specialRocks < level?.maxSpecialRocks ?? 0 {
                    specialRocks += 1
                    newTiles.append(nextTile)
                }

            case .exit:
                if typeCount(for: tiles, of: .exit).count < 1,
                    !newTiles.contains(Tile.exit)
                {
                    newTiles.append(nextTile)
                }
            case .monster:
                if totalMonstersAdded < maxMonstersTotal && currentMonsterCount < maxMonstersOnScreen  {
                    newMonsterCount += 1
                    newTiles.append(nextTile)
                    totalMonstersAdded += 1
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
    
    func board(difficulty: Difficulty) -> [[Tile]] {
        var newTiles: [Tile] = []
        while (newTiles.count < boardSize * boardSize) {
            let nextTile = Tile(type: randomRock(randomSource.nextInt()))
            
            switch nextTile.type {
            case .blueRock, .purpleRock, .brownRock, .blackRock, .redRock:
                newTiles.append(nextTile)
            case .greenRock:
                if specialRocks < level?.maxSpecialRocks ?? 0 {
                    specialRocks += 1
                    newTiles.append(nextTile)
                }
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
        
        
        guard let playerData = playerEntityData else { fatalError("We must get a playerData or else we cannot continue") }
        tiles[playerPosition.x][playerPosition.y] = Tile(type: .player(playerData))
        
        let upperMonsterbound = Int(Double(tiles.count))
        
        for _ in 0..<maxMonstersOnScreen {
            let randomRow = Int.random(upperMonsterbound)
            let randomCol = Int.random(upperMonsterbound)
            guard playerPosition != TileCoord(randomRow,randomCol),
                !TileCoord(randomRow, randomCol).isOrthogonallyAdjacent(to: playerPosition) else { continue }
            tiles[randomRow][randomCol] = Tile(type: randomMonster(randomSource.nextInt()))
            totalMonstersAdded += 1
        }
        
        //place the exit on the opposite side of the grid
//        let exitQuadrant = playerQuadrant.opposite
        let exitQuadrant = playerQuadrant
        let exitPosition = exitQuadrant.randomCoord(for: boardSize)
        
        tiles[exitPosition.x][exitPosition.y] = Tile.exit
        
        return tiles
    }
    
    var playerEntityData: EntityModel? {
        guard updatedEntity == nil else {
            return updatedEntity
        }
        switch difficulty {
        case .easy:
            return entities.easyPlayer
        case .normal:
            return entities.normalPlayer
        case .hard:
            return entities.hardPlayer
        }
    }
}
