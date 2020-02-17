//
//  TileCreator.swift
//  DownFall
//
//  Created by William Katz on 1/9/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import GameplayKit

class TileCreator: TileStrategy {
    var randomSource = GKLinearCongruentialRandomSource()
    let entities: EntitiesModel
    let difficulty: Difficulty
    var updatedEntity: EntityModel?
    let boardSize: Int
    var level: Level?
    var specialRocks = 0
    var totalMonstersAdded = 0
    var specialGems = 0
    var goldVariance = 2
    let maxMonsterRatio: Double = 0.20
    
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
            return randomMonster()
        case .blackRock, .blueRock, .purpleRock, .brownRock, .greenRock, .redRock:
            return randomRock()
        default:
            return TileType.allCases[index]
        }
    }
    
    private func randomMonster() -> TileType {
        
        guard let level = level else { fatalError("You need to init with a level") }
        let totalNumber = level.monsterTypeRatio.values.max { (first, second) -> Bool in
            return first.upper < second.upper
        }
        guard let upperRange = totalNumber?.upper else { fatalError("We need the max number or else we cannot continue") }

        let randomNumber = Int.random(upperRange)
        for (key, value) in level.monsterTypeRatio {
            if value.contains(randomNumber), let data = entities.entity(with: key) {
                return TileType.monster(data)
            }
        }
        
        fatalError("We should always return a random monster from this function.")
        
    }
    
    func randomMonster(not this: EntityModel.EntityType) -> Tile {
        while true {
            let ranMonster = randomMonster()
            if case let TileType.monster(data) = ranMonster {
                if data.type != this {
                    return Tile(type: ranMonster)
                }
            }
        }
    }
    
    private func randomRock() -> TileType {
        guard let level = level else { fatalError("You need to init with a level") }
        let totalNumber = level.rocksRatio.values.max { (first, second) -> Bool in
            return first.upper < second.upper
        }
        guard let upperRange = totalNumber?.upper else { fatalError("We need the max number or else we cannot continue") }
        let randomNumber = Int.random(upperRange)
        for (key, value) in level.rocksRatio {
            if value.contains(randomNumber) {
                return key
            }
        }
        
        fatalError("The randomNumber between 0-\(upperRange-1) should find itself in the range of one of the rocks")
    }

    func goldDropped(from monster: EntityModel) -> Int {
        if let goldItem = monster.carry.items.first(where: { $0.type == .gold }) {
            let medianAmount = goldItem.amount * (level?.goldMultiplier ?? 1)
            return Int.random(lower: max(1, medianAmount-goldVariance), upper: medianAmount+goldVariance)
        }
        return 0
    }
    
    private func randomTile(_ neighbors: [Tile], noMoreMonsters: Bool = false) -> Tile {
        var nextTile = Tile(type: randomTile(randomSource.nextInt()))
        
        var validTile = false
        while !validTile {
            nextTile = Tile(type: randomTile(randomSource.nextInt()))
            
            switch nextTile.type {
            case .monster:
                validTile = !neighbors.contains {  $0.type == .monster(.zero) || $0.type == .player(.zero) } && !noMoreMonsters
            case .redRock, .blueRock, .brownRock, .purpleRock:
                validTile = true
            case .item, .exit, .player, .fireball, .blackRock, .greenRock, .empty:
                validTile = false
            }
        }
        return nextTile
    }
    
    private func neighbors(of coord: TileCoord, in tiles: [[Tile]]) -> [Tile] {
        
        return [coord.colLeft, coord.colRight, coord.rowAbove, coord.rowBelow]
            .filter {
                return isWithinBounds($0, within: tiles)
            }.map {
                tiles[$0]
            }
    }
    
    func tiles(for tiles: [[Tile]]) -> [[Tile]] {
        
        // copy the given array to keep track of where we need tiles
        var newTiles: [[Tile]] = tiles
        
        let maxMonsters = Int(Double(tiles.count) * maxMonsterRatio)
        var currMonsterCount = typeCount(for: tiles, of: .monster(.zero)).count
        
        for row in 0..<newTiles.count {
            for col in 0..<newTiles[row].count {
                
                //check the old array for empties
                if tiles[row][col].type == .empty {
                    // update the new array and check for neighbors in new array as well.
                    
                     let newTile = randomTile(neighbors(of: TileCoord(row: row, column: col), in: newTiles), noMoreMonsters: currMonsterCount < maxMonsters)
                    if newTile.type == .monster(.zero) {
                        currMonsterCount += 1
                    }
                    newTiles[row][col] = newTile
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
            let nextTile = Tile(type: randomRock())
            
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
        
        for _ in 0..<level!.monsterCountStart {
            let randomRow = Int.random(upperMonsterbound)
            let randomCol = Int.random(upperMonsterbound)
            guard playerPosition != TileCoord(randomRow,randomCol),
                !TileCoord(randomRow, randomCol).isOrthogonallyAdjacent(to: playerPosition) else { continue }
            tiles[randomRow][randomCol] = Tile(type: randomMonster())
            totalMonstersAdded += 1
        }
        
        //place the exit on the opposite side of the grid
        #warning ("make sure this is set properly for release")
        let exitQuadrant = playerQuadrant.opposite
//        let exitQuadrant = playerQuadrant
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
