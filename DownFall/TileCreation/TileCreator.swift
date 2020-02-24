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
        let weight = 12
        let index = abs(given) % (TileType.randomCases.count + weight)
        switch index {
        case 0...1:
            return randomMonster()
        case 1...Int.max:
            return randomRock()
        default:
            preconditionFailure("Shouldnt be here")
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
    
    private func randomCoord(notIn set: Set<TileCoord>) -> TileCoord {
        guard let level = level else { preconditionFailure("We need a level to work") }
        let upperbound = level.boardSize
        
        var tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
        while set.contains(tileCoord) {
            tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
        }
        return tileCoord
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
            case .rock(.red), .rock(.purple), .rock(.blue), .rock(.brown):
                validTile = true
            case .item, .exit, .player, .fireball, .rock(.green), .empty, .pillar:
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
                    // check if there are any columns above me
                    var columnAboveMe = 0
                    for rowAbove in row..<newTiles.count {
                        if case TileType.pillar = newTiles[rowAbove][col].type {
                            columnAboveMe += 1
                        }
                    }
                    
                    if columnAboveMe == 0 {
                        let newTile = randomTile(neighbors(of: TileCoord(row: row, column: col), in: newTiles), noMoreMonsters: currMonsterCount < maxMonsters)
                        if newTile.type == .monster(.zero) {
                            currMonsterCount += 1
                        }
                        newTiles[row][col] = newTile
                    }
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
        guard let level = level else { preconditionFailure("Can;t build a build without a level") }
        var newTiles: [Tile] = []
        
        //just add a bunchhhhhhh of rocks
        while (newTiles.count < boardSize * boardSize) {
            let nextTile = Tile(type: randomRock())
            
            switch nextTile.type {
            case .rock:
                newTiles.append(nextTile)
            case .exit, .player, .monster, .item, .empty, .fireball, .pillar:
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
        
        // place the pillars
        let pillarCoordinates: Set<TileCoord> = Set(level.pillarCoordinates.map { $0.1 })
        for (tiletype, coord) in level.pillarCoordinates {
            tiles[coord.row][coord.column] = Tile(type: tiletype)
        }
        
        // place the player in a quadrant
        let playerQuadrant = Quadrant.allCases[Int.random(Quadrant.allCases.count)]
        let playerPosition = playerQuadrant.randomCoord(for: boardSize, notIn: pillarCoordinates)
        
        
        guard let playerData = playerEntityData else { fatalError("We must get a playerData or else we cannot continue") }
        tiles[playerPosition.x][playerPosition.y] = Tile(type: .player(playerData))
        
        
        // reserve all positions so we don't overwrite any one position multiple times
        var reservedSet = Set<TileCoord>([playerPosition, playerPosition.colLeft, playerPosition.colRight, playerPosition.rowAbove, playerPosition.rowBelow])
        reservedSet.formUnion(pillarCoordinates)
        // add monsters
        for _ in 0..<level.monsterCountStart {
            let randomTileCoord = randomCoord(notIn: reservedSet)
            let (randomRow, randomCol) = randomTileCoord.tuple
            reservedSet.insert(randomTileCoord)
            tiles[randomRow][randomCol] = Tile(type: randomMonster())
        }
        
        //place the exit on the opposite side of the grid
        #warning ("make sure this is set properly for release")
        let exitQuadrant = playerQuadrant.opposite
//        let exitQuadrant = playerQuadrant
        let exitPosition = exitQuadrant.randomCoord(for: boardSize, notIn: reservedSet)
        
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
