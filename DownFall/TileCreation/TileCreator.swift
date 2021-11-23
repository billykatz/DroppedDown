//
//  TileCreator.swift
//  DownFall
//
//  Created by William Katz on 1/9/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import GameplayKit

class TileCreator: TileStrategy {

    
    
    static let tutorialBoard: [[Tile]] =
    [
        [.purpleRock, .blueRock, .redRock, .blueRock, .redRock, .purpleRock, .blueRock, .redRock],
        
        [.blueRock, .purpleRock, .blueRock, .redRock, .purpleRock, .redRock, .blueRock, .redRock],
        
        [.blueRock, .purpleRock, .purpleRock, Tile(type: .rock(color: .purple, holdsGem: true, groupCount: 7)), .purpleRock, .blueRock, .redRock, .blueRock],
        
        [.purpleRock, .redRock, .blueRock, .redRock, .purpleRock, .redRock, Tile(type: .exit(blocked: true)), .redRock],
        
        [.blueRock, .blueRock, .redRock, .purpleRock, .redRock, .purpleRock, .redRock, .blueRock],
        
        [.purpleRock, .redRock, .purpleRock, .blueRock, .player, .blueRock, .redRock, .purpleRock],
        
        [.blueRock, .purpleRock, .redRock, .purpleRock, .blueRock, .redRock, .purpleRock, .blueRock],
        
        [.blueRock, .purpleRock, .redRock, .blueRock, .redRock, .purpleRock, .redRock, .purpleRock]
    ]
    
    
    let randomSource: GKLinearCongruentialRandomSource
    let entities: EntitiesModel
    let difficulty: Difficulty
    var updatedEntity: EntityModel?
    let tutorialConductor: TutorialConductor
    let boardSize: Int
    var level: Level
    var loadedTiles: [[Tile]]?
    var specialRocks = 0
    var specialGems = 0
    var goldVariance = 2
    let maxMonsterRatio: Double = 0.15
    var numberOfTilesSinceLastGemDropped = 0
    
    // debug help to get at least one gem per board
    var spawnAtleastOneGem = true;
    
    var hasAlreadySpawnedMonsterForTutorial = false
    
    required init(_ entities: EntitiesModel,
                  difficulty: Difficulty,
                  updatedEntity: EntityModel? = nil,
                  level: Level,
                  randomSource: GKLinearCongruentialRandomSource,
                  loadedTiles: [[Tile]]? = [],
                  tutorialConductor: TutorialConductor) {
        self.entities = entities
        self.difficulty = difficulty
        self.updatedEntity = updatedEntity
        self.level = level
        self.randomSource = randomSource
        self.boardSize = level.boardSize
        self.tutorialConductor = tutorialConductor
        
        print("loadedTiles is nil \(loadedTiles == nil)")
        self.loadedTiles = loadedTiles
    }
    
    private func randomTile(given: Int, neighbors: [Tile], playerData: EntityModel, forceMonsters: Bool) -> TileType {
        guard !forceMonsters else { return randomMonster() }
        guard level.spawnsMonsters else { return randomRock([], playerData: playerData) }
        guard !level.isBossLevel else { return randomRock([], playerData: playerData) }
        let weight = 97
        let index = abs(given) % (TileType.randomCases.count + weight)
        
         
        /// 8% of the time we will try to create a monster
        /// 92 % of the time we will create a rock.
        /// This should probably vary based on the level
        /// This is worth to think about more
        
        switch index {
        case 0..<9:
            return randomMonster()
        case 9...Int.max:
            return randomRock(neighbors, playerData: playerData)
        default:
            preconditionFailure("Shouldnt be here")
        }
    }

    func monsterWithType(_ type: EntityModel.EntityType) -> Tile? {
        if let data = entities.entity(with: type) {
            return Tile(type: TileType.monster(data))
        }
        return nil
    }
    
    func randomMonster() -> TileType {
        let totalNumber = level.monsterTypeRatio.values.max { (first, second) -> Bool in
            return first.upper < second.upper
        }
        guard let upperRange = totalNumber?.upper else {
            fatalError("We need the max number or else we cannot continue")
            
        }
        
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
        let upperbound = level.boardSize
        
        var tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
        while set.contains(tileCoord) {
            tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
        }
        return tileCoord
    }
    
    func randomRock(_ neighbors: [Tile] = [], playerData: EntityModel) -> TileType {
        var tileTypeChances = level.tileTypeChances
        if !neighbors.isEmpty {
            tileTypeChances = tileTypeChances.increaseChances(basedOn: neighbors
                .map { $0.type }
                .filter { TileType.rockCases.contains($0) }
            )
        }
        let randomNumber = Int.random(tileTypeChances.outcomes)
        var lowerBound = 0
        for (key, value) in tileTypeChances.chances {
            let minValue = max(1, value)
            if let color = key.color, (lowerBound..<lowerBound+minValue).contains(randomNumber) {
                return TileType.rock(color: color, holdsGem: shouldRockHoldGem(playerData: playerData, rockColor: color, shouldSpawnAtleastOneGem: spawnAtleastOneGem), groupCount: 0)
            } else {
                lowerBound = lowerBound + minValue
            }
        }
        
        fatalError("The randomNumber should between 0 and \(randomNumber-1) should map to a TileType.")
    }
    
    func shouldRockHoldGem(playerData: EntityModel, rockColor: ShiftShaft_Color, shouldSpawnAtleastOneGem: Bool) -> Bool {
        // early return if we are in the tutorial
        guard !tutorialConductor.isTutorial else { return false }
        guard !level.isBossLevel else { return false }
        
        let extraGemsBasedOnLuck = playerData.luck / 5
        let extraChanceBasedOnLuck = extraGemsBasedOnLuck * 2
        guard specialGems < level.maxSpawnGems + extraGemsBasedOnLuck else { return false }

        let weight = 100
        let index = randomSource.nextInt() % weight
        let baseChance = 2
        let extraChance = extraChanceBasedOnLuck
        let moreChanceBasedOnLastTimeAGemDropped = numberOfTilesSinceLastGemDropped / 10
        let totalChance = baseChance + extraChance + moreChanceBasedOnLastTimeAGemDropped
        if (0..<totalChance).contains(index) {
            numberOfTilesSinceLastGemDropped = 0
            specialGems += 1
            return rockColor != .brown
        } else {
            let shouldSpawn = spawnAtleastOneGem
            spawnAtleastOneGem = false
            return false || shouldSpawn
        }


    }
    
    private func randomTile(_ neighbors: [Tile], noMoreMonsters: Bool, playerData: EntityModel, forceMonsters: Bool) -> Tile {
        
        /// This 100% gets set in the while loop
        var nextTile: Tile!
        
        var validTile = false
        while !validTile {
            nextTile = Tile(type: randomTile(given: randomSource.nextInt(), neighbors: neighbors, playerData: playerData, forceMonsters: forceMonsters))
            
            switch nextTile.type {
            case .monster:
                validTile = (!neighbors.contains {  $0.type == .monster(.zero) || $0.type == .player(.zero) } && !noMoreMonsters && !tutorialConductor.isTutorial) || (tutorialConductor.isTutorial && forceMonsters)
            case .rock(.red, _, _), .rock(.purple, _, _), .rock(.blue, _, _), .rock(.brown, _, _):
                validTile = true
            case .exit, .player, .rock(.green, _, _), .empty, .pillar, .dynamite, .emptyGem, .item, .offer, .rock(color: .blood, _, _):
                validTile = false
            }
        }
        return nextTile
    }
    
    private func neighbors(of coord: TileCoord, in tiles: [[Tile]]) -> [Tile] {
        
        return
            [coord.colLeft, coord.colRight, coord.rowAbove, coord.rowBelow]
            .filter {
                return isWithinBounds($0, within: tiles)
            }.map {
                tiles[$0]
            }
    }
    
    func tiles(for tiles: [[Tile]], forceMonster: Bool) -> [[Tile]] {
        guard let playerData = playerData(in: tiles) else { return tiles }
        
        // copy the given array to keep track of where we need tiles
        var newTiles: [[Tile]] = tiles
        
        let maxMonsters = Int(Double(tiles.count * tiles.count) * level.maxMonsterOnBoardRatio)
        numberOfTilesSinceLastGemDropped += typeCount(for: tiles, of: .empty).count
        var currMonsterCount = typeCount(for: tiles, of: .monster(.zero)).count
        var shouldForceMonsters = forceMonster
        
        for row in 0..<newTiles.count {
            for col in 0..<newTiles[row].count {
                //check the old array for empties
                if tiles[row][col].type == .empty {
                    // update the new array and check for neighbors in new array as well.
                    // check if there are any pillars above me
                    var pillarAboveMe = 0
                    for rowAbove in row..<newTiles.count {
                        if case TileType.pillar = newTiles[rowAbove][col].type {
                            pillarAboveMe += 1
                        }
                    }
                    
                    if pillarAboveMe == 0 {
                        let newTile = randomTile(neighbors(of: TileCoord(row: row, column: col), in: newTiles),
                                                 noMoreMonsters: currMonsterCount >= maxMonsters, playerData: playerData, forceMonsters: shouldForceMonsters)
                        shouldForceMonsters = false
                        if newTile.type == .monster(.zero) {
                            currMonsterCount += 1
                        }
                        newTiles[row][col] = newTile
                    }
                } else if case TileType.emptyGem(let color, let amount) = tiles[row][col].type {
                    newTiles[row][col] = Tile(type: .item(Item(type: .gem, amount: amount, color: color)))
                }
            }
        }
        
        return newTiles
    }
    
    func shuffle(tiles: [[Tile]]) -> [[Tile]] {
        guard let playerData = playerData(in: tiles) else { return tiles }
        var newTiles = tiles
        var reservedCoords = Set<TileCoord>()
        var currentMonsterCount = 0
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                switch tiles[row][col].type {
                case .monster:
                    currentMonsterCount += 1
                    newTiles[row][col] = Tile(type: randomRock([], playerData: playerData))
                case .rock:
                    newTiles[row][col] = Tile(type: randomRock([], playerData: playerData))
                case .player(let data):
                    reservedCoords.insert(TileCoord(row: row, column: col))
                    newTiles[row][col] = Tile(type: .player(data.wasAttacked(for: 2, from: .south)))
                default:
                    reservedCoords.insert(TileCoord(row: row, column: col))
                }
            }
        }
        
        let newMonsterCount = max(1, currentMonsterCount-3)
        for _ in 0..<newMonsterCount {
            let coord = randomCoord(notIn: reservedCoords)
            newTiles[coord.row][coord.column] = Tile(type: randomMonster())
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
    
    func board(difficulty: Difficulty) -> ([[Tile]], newLevel: Bool) {
        guard let playerData = updatedEntity else { preconditionFailure("Unable to create a board without a player") }
        
        
        if tutorialConductor.isTutorial {
            var newTutorialBoard: [[Tile]] = Array.init(repeating: Array.init(repeating: .empty, count: 8), count: 8)

            for row in 0..<TileCreator.tutorialBoard.count {
                for col in 0..<TileCreator.tutorialBoard.count {
                    if TileCreator.tutorialBoard[row][col].type == .player(.zero) {
                        newTutorialBoard[row][col] = Tile(type: .player(playerData))
                    } else {
                        newTutorialBoard[row][col] = TileCreator.tutorialBoard[row][col]
                    }
                }
            }
            
            return (newTutorialBoard, true)
        }
        
        // early return to load the load tiles we have loaded
        if let loadedTiles = self.loadedTiles, loadedTiles.count > 0 {
            print("we have a saved game to return")
            self.loadedTiles = nil
            return (loadedTiles, false)
        }
        
        var newTiles: [Tile] = []
        
        //just add a bunchhhhhhh of rocks
        while (newTiles.count < boardSize * boardSize) {
            let nextTile = Tile(type: randomRock([], playerData: playerData))
            
            switch nextTile.type {
            case .rock:
                newTiles.append(nextTile)
            case .exit, .player, .monster, .item, .empty, .pillar, .dynamite, .emptyGem, .offer:
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
        let pillarCoordinates: Set<TileCoord> = Set(level.pillarCoordinates.map { $0.coord })
        for (pillar) in level.pillarCoordinates {
            tiles[pillar.coord.row][pillar.coord.column] = Tile(type: pillar.pillar)
        }
        
        // place the player in a quadrant
        let playerQuadrant = Quadrant.allCases[Int.random(Quadrant.allCases.count)]
        let playerPosition = playerQuadrant.randomCoord(for: boardSize, notIn: pillarCoordinates)
        
        
        //
        tiles[playerPosition.x][playerPosition.y] = Tile(type: .player(playerData))
//        tiles[3][7] = Tile(type: .player(playerData))
        
        
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
        
        guard level.hasExit else { return (tiles, false) }
        //place the exit on the opposite side of the grid
        #warning ("make sure this is set properly for release")
        // no exit on the boss level
        if (!level.isBossLevel) {
            let exitQuadrant = playerQuadrant.opposite
    //        let exitQuadrant = playerQuadrant
            let exitPosition = exitQuadrant.randomCoord(for: boardSize, notIn: reservedSet)
            reservedSet.insert(exitPosition)
            
            tiles[exitPosition.x][exitPosition.y] = Tile(type: .exit(blocked: true))
        }
        
        // Quick testing for rune replacement
        let data = entities.entity(with: .alamo)!
        tiles[playerPosition.row+1][playerPosition.column] = Tile(type: .monster(data))
        
        // quick testing gem collectin
//        tiles[3][6] = Tile(type: .item(Item.init(type: .gem, amount: 10, color: .blue)))
//        tiles[3][5] = Tile(type: .item(Item.init(type: .gem, amount: 50, color: .red)))
//        tiles[3][4] = Tile(type: .item(Item.init(type: .gem, amount: 100, color: .purple)))
//        tiles[3][3] = Tile(type: .item(Item.init(type: .gem, amount: 250, color: .blue)))
//        tiles[3][2] = Tile(type: .item(Item.init(type: .gem, amount: 5, color: .red)))
//        tiles[3][1] = Tile(type: .item(Item.init(type: .gem, amount: 25, color: .purple)))
        
        return (tiles, true)
    }
    
    var playerEntityData: EntityModel? {
        return updatedEntity
    }
}
