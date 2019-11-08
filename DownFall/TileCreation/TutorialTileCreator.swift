//
//  TutorialTileCreator.swift
//  DownFall
//
//  Created by William Katz on 11/7/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

/*
 var array = Array(repeating: Tile.blackRock, count: 4)
 var playerArray = Array(repeating: Tile.blackRock, count: 3)
 playerArray.append(Tile.player)
 return [array, playerArray, array, array]

 
 Appears as:
 br br player br
 br br br br
 br br br br
 br gem br br
 
 */

import GameplayKit

struct TutorialTileCreator: TileStrategy {
    var updatedEntity: EntityModel?
    var difficulty: Difficulty
    var entities: [EntityModel]
    var randomSource: GKLinearCongruentialRandomSource = GKLinearCongruentialRandomSource()
    
    init(_ entities: [EntityModel], difficulty: Difficulty, updatedEntity: EntityModel?) {
        self.entities = entities
        self.difficulty = difficulty
        self.updatedEntity = updatedEntity
    }
    
    func board(_ boardSize: Int, difficulty: Difficulty) -> [[Tile]] {
        let blackRow = Array(repeating: Tile.blackRock, count: 4)
        
        var tiles: [[Tile]] = []
        switch difficulty {
        case .easy, .normal, .hard:
            fatalError("You cant create a tutorial board with one of these diffculties")
        case .tutorial1:
            tiles = [
                [.blackRock, .gold, .blackRock, .blackRock],
                blackRow,
                blackRow,
                [.blackRock, .blackRock, .player, .blackRock]
            ]
        }
        return tiles
    }
    
    
    func tiles(for tiles: [[Tile]]) -> [Tile] {
        let count = typeCount(for: tiles, of: .empty).count
        let array = Array(repeating: randomSource.nextInt() % 2 == 0 ? Tile.gold : Tile.blackRock, count: count)
        return array
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
