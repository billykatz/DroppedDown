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
        [.blueRock, .redRock, .blueRock, .redRock, .purpleRock, .blueRock, .redRock],
        
        [.purpleRock, .blueRock, .redRock, .purpleRock, .redRock, .blueRock, .redRock],
        
        [.purpleRock, .purpleRock, Tile(type: .rock(color: .purple, holdsGem: true, groupCount: 7)), .purpleRock, .blueRock, .redRock, .blueRock],
        
        [.redRock, .blueRock, .redRock, .purpleRock, .redRock, Tile(type: .exit(blocked: true)), .redRock],
        
        [.blueRock, .redRock, .purpleRock, .redRock, .purpleRock, .redRock, .blueRock],
        
        [.redRock, .purpleRock, .blueRock, .player, .blueRock, .redRock, .purpleRock],
        
        [.purpleRock, .redRock, .purpleRock, .blueRock, .redRock, .purpleRock, .blueRock]
    ]
    
    
    static let testBoard: [[Tile]] =
    [
        [.brownRock, .brownRock, .redRock, .purpleRock, .purpleRock, .redRock],
        
        [.redRock, .ratTileTestOnly, .blueRock, .redRock, .purplePillar, .blueRock],
        
        [.ratTileTestOnly, .bluePillar, .brownRock, .brownRock, .purpleRock, .bluePillar],
        
        [.purpleRock, .redRock, .ratTileTestOnly, .blueRock, .player, .blueRock],
        
        [.ratTileTestOnly, .purpleRock, .redRock, .redPillar, .blueRock, .blockedExit],
        
        [.blueRock, .purpleRock, .redRock, .blueRock, .redRock, .purpleRock]
    ]

    
    
    let randomSource: GKLinearCongruentialRandomSource
    let entities: EntitiesModel
    let difficulty: Difficulty
    var updatedEntity: EntityModel?
    let tutorialConductor: TutorialConductor
    let boardSize: Int
    var level: Level
    var loadedTiles: [[Tile]]?
    var numberOfTilesSinceLastGemDropped = 0
    
    // get at least one gem per board
    var spawnAtleastOneGem = true;
    
    var specialGems: Int {
        get {
            level.gemsSpawned
        }
        set {
            level.gemsSpawned = newValue
        }
    }
    
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
        guard !level.isBossLevel else { return randomRock([], playerData: playerData) }
        let weight = 98
        let index = abs(given) % (TileType.randomCases.count + weight)
        
        
        let endRange = level.monsterChanceOfShowingUp(tilesSinceMonsterKilled: level.monsterSpawnTurnTimer)
        let monsterRange: ClosedRange<Int> = -1...endRange
        
        switch index {
        case monsterRange:
            return randomMonster()
        case endRange+1...Int.max:
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
            if let color = key.color,
               (lowerBound..<lowerBound+minValue).contains(randomNumber) {
                let shouldRockHoldGem = shouldRockHoldGem(playerData: playerData, rockColor: color, shouldSpawnAtleastOneGem: spawnAtleastOneGem)
                return TileType.rock(color: color, holdsGem: shouldRockHoldGem, groupCount: 0)
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
        
        let extraChanceBasedOnLuck = Float(playerData.luck) / 10
        guard specialGems < level.maxSpawnGems + Int(extraChanceBasedOnLuck) else { return false }
        
        let baseChance: Float = 2
        let extraChanceBasedOnTilesSinceLast = Float(numberOfTilesSinceLastGemDropped) / 50
        let totalShouldHoldGemChance = baseChance + extraChanceBasedOnTilesSinceLast + extraChanceBasedOnLuck
        let shouldNotHoldGemChance = 100 - totalShouldHoldGemChance
        
        let shouldHoldGemChanceModel: AnyChanceModel<Bool> = AnyChanceModel(thing: true, chance: totalShouldHoldGemChance)
        let shouldNotHoldGemChanceModel: AnyChanceModel<Bool> = AnyChanceModel(thing: false, chance: shouldNotHoldGemChance)
        
        let choice = randomSource.chooseElementWithChance([shouldHoldGemChanceModel, shouldNotHoldGemChanceModel])
        
        //
        if choice?.thing ?? false {
            if rockColor != .brown {
                specialGems += 1
                numberOfTilesSinceLastGemDropped = 0
                return true
            } else {
                return false
            }

        } else {
            return false
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
                if validTile {
                    print("Range: -1...\(level.monsterChanceOfShowingUp(tilesSinceMonsterKilled: level.monsterSpawnTurnTimer))")
                }
            case .rock(.red, _, _), .rock(.purple, _, _), .rock(.blue, _, _), .rock(.brown, _, _):
                validTile = true
            case .exit, .player, .rock(.green, _, _), .empty, .pillar, .dynamite, .emptyGem, .item, .offer, .rock(color: .blood, _, _):
                validTile = false
            }
        }
        return nextTile
    }
    
    private func neighbors(of coord: TileCoord, in tiles: [[Tile]]) -> [Tile] {
        [coord.colLeft, coord.colRight, coord.rowAbove, coord.rowBelow]
            .filter {
                return isWithinBounds($0, within: tiles)
            }.map {
                tiles[$0]
            }
    }
    
    func tiles(for tiles: [[Tile]], forceMonster: Bool, monsterWasKilled: Bool) -> [[Tile]] {
        guard let playerData = playerData(in: tiles) else { return tiles }
        
        // copy the given array to keep track of where we need tiles
        var newTiles: [[Tile]] = tiles
        
        let maxMonsters = Int(Double(tiles.count * tiles.count) * level.maxMonsterOnBoardRatio)
        numberOfTilesSinceLastGemDropped += tileCoords(for: tiles, of: .empty).count
        var currMonsterCount = tileCoords(for: tiles, of: .monster(.zero)).count
        var shouldForceMonsters = forceMonster
        
        //keep track of when monster was last killed
        if monsterWasKilled {
            level.monsterSpawnTurnTimer = 0
        } else {
            // keep track of how many tiles have been removed since the last monster
            level.monsterSpawnTurnTimer += tileCoords(for: tiles, of: .empty).count
        }
        
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
                        let neighbors = neighbors(of: TileCoord(row: row, column: col), in: newTiles)
                        let newTile = randomTile(neighbors,
                                                 noMoreMonsters: currMonsterCount >= maxMonsters,
                                                 playerData: playerData,
                                                 forceMonsters: shouldForceMonsters)
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
            var newTutorialBoard: [[Tile]] = Array.init(repeating: Array.init(repeating: .empty, count: 7), count: 7)
            
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
        } else if let screenShotBoard = self.boardForScreenshots() {
            var board: [[Tile]] = Array.init(repeating: Array.init(repeating: .empty, count: 6), count: 6)
            
            for row in 0..<screenShotBoard.count {
                for col in 0..<screenShotBoard.count {
                    board[row][col] = screenShotBoard[row][col]
                }
            }
            return (board, true)

        }
        
        // early return to load the load tiles we have loaded
        if let loadedTiles = self.loadedTiles, loadedTiles.count > 0 {
            print("we have a saved game to return")
            self.loadedTiles = nil
            return (loadedTiles, false)
        }
        
        var newTiles: [Tile] = []
        
        // just add a bunchhhhhhh of rocks
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
        var reservedCoordinates: Set<TileCoord> = Set()

        
        for levelStartTile in level.levelStartTiles {
            if case TileType.monster(let monster) = levelStartTile.tileType,
                let entity = entities.entity(with: monster.type) {
                tiles[levelStartTile.tileCoord.row][levelStartTile.tileCoord.col] = Tile(type: TileType.monster(entity))
            } else {
                tiles[levelStartTile.tileCoord.row][levelStartTile.tileCoord.col] = Tile(type: levelStartTile.tileType)
            }
            reservedCoordinates.insert(levelStartTile.tileCoord)
        }
        
        // place the player in a quadrant
        let playerQuadrant = Quadrant.allCases[Int.random(Quadrant.allCases.count)]
        let playerPosition = playerQuadrant.randomCoord(for: boardSize, notIn: reservedCoordinates)
        
        
        // place the player in the board
        tiles[playerPosition.x][playerPosition.y] = Tile(type: .player(playerData))
        
        
        // reserve all positions so we don't overwrite any one position multiple times
        var reservedSet = Set<TileCoord>([playerPosition, playerPosition.colLeft, playerPosition.colRight, playerPosition.rowAbove, playerPosition.rowBelow])
        reservedSet.formUnion(reservedCoordinates)
        
        // add monsters
        for _ in 0..<level.monsterCountStart {
            let randomTileCoord = randomCoord(notIn: reservedSet)
            let (randomRow, randomCol) = randomTileCoord.tuple
            reservedSet.insert(randomTileCoord)
            tiles[randomRow][randomCol] = Tile(type: randomMonster())
        }
        
        // no exit on the boss level
        if (!level.isBossLevel) {
            /// some level start tiles place exits inside encasements. So only add an exit if we need too.
            if getTilePosition(.exit(blocked: true), tiles: tiles) == nil {
                //place the exit on the opposite side of the grid
                #warning ("make sure this is set properly for release")
                let exitQuadrant = playerQuadrant.opposite
                //        let exitQuadrant = playerQuadrant
                let exitPosition = exitQuadrant.randomCoord(for: boardSize, notIn: reservedSet)
                reservedSet.insert(exitPosition)
                
                tiles[exitPosition.x][exitPosition.y] = Tile(type: .exit(blocked: true))
            }
        }
        
        return (tiles, true)
    }
    
    var playerEntityData: EntityModel? {
        return updatedEntity
    }
}
