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
        return TileType.allCases[index]
    }
    
    let maxMonsters = 2
    let maxGems = 1
    var spawnedGem = false
    var randomSource = GKLinearCongruentialRandomSource()
    var entities: [EntityModel]
    
    
    init(_ entities: [EntityModel]) {
        self.entities = entities
    }
    
    func tiles(for board: Board, difficulty: Difficulty = .normal) -> [TileType] {
        var newTiles: [TileType] = []
        var newMonsterCount = 0
        let maxMonsters = 4
        let currentMonsterCount = board.tiles(of: .monster(.zero)).count
        while (newTiles.count < board.tiles(of: .empty).count) {
            let nextTile = randomTile(randomSource.nextInt())
            
            switch nextTile {
            case .player:
                if board.tiles(of: .player(.zero)).count < 1 && !newTiles.contains(.player(.zero)) {
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
            case .gem1:
                if randomSource.nextInt().isMultiple(of: 2),
                    !newTiles.contains(.exit),
                    !spawnedGem {
                    newTiles.append(nextTile)
                    spawnedGem = true
                }
            case .monster:
                if currentMonsterCount + newMonsterCount < maxMonsters  {
                    newMonsterCount += 1
                    newTiles.append(.monster(entities[0]))
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
            let nextTile = randomTile(randomSource.nextInt())
            
            switch nextTile {
            case .blueRock, .blackRock, .greenRock:
                newTiles.append(nextTile)
            case .empty:
                ()
//                fatalError("Should not get a empty tile here")
            case .exit, .gem1, .player, .monster:
                ()
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
        tiles[playerPosition.x][playerPosition.y] = TileType.player(entities[1])
        
        return tiles

    }

}
