//
//  TutorialTileCreator.swift
//  DownFall
//
//  Created by William Katz on 11/7/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

/*
 var array = Array(repeating: Tile.greenRock, count: 4)
 var playerArray = Array(repeating: Tile.greenRock, count: 3)
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
    func goldDropped(from monster: EntityModel) -> Int {
        return 5
    }
    
    var updatedEntity: EntityModel?
    var difficulty: Difficulty
    var entities: EntitiesModel
    var level: Level?
    var randomSource: GKLinearCongruentialRandomSource = GKLinearCongruentialRandomSource()
    
    init(_ entities: EntitiesModel, difficulty: Difficulty, updatedEntity: EntityModel?, level: Level?) {
        self.entities = entities
        self.difficulty = difficulty
        self.updatedEntity = updatedEntity
        self.level = level
    }
    
    func board(difficulty: Difficulty) -> [[Tile]] {
        guard let playerData = playerEntityData else { fatalError("We must have player data to continue") }
        
        let greenRow = Array(repeating: Tile.greenRock, count: 4)
        let purpleRow = Array(repeating: Tile.purpleRock, count: 4)
        
        var tiles: [[Tile]] = []
        switch level?.type {
        case .first, .second, .third, .boss, .none:
            fatalError("You cant create a tutorial board with one of these diffculties")
        case .tutorial1:
            tiles = [
                [.greenRock, .gem, .greenRock, .greenRock],
                greenRow,
                greenRow,
                [.greenRock, .greenRock, Tile(type: .player(playerData)), .greenRock]
            ]
        case .tutorial2:
            guard let rat = entities.entity(with: .rat) else { fatalError("Could not find a rat in the entities array") }
            tiles = [
                [.greenRock, .greenRock, .monster(rat), .brownRock],
                [.greenRock, .greenRock, .brownRock , .purpleRock],
                purpleRow,
                [.purpleRock, .purpleRock, Tile(type: .player(playerData)), .brownRock]
            ]
        }
        return tiles
    }
    
    
    func tiles(for tiles: [[Tile]]) -> [Tile] {
        let count = typeCount(for: tiles, of: .empty).count
        let array = Array(repeating: randomSource.nextInt() % 2 == 0 ? Tile.greenRock : Tile.brownRock, count: count)
        return array
    }
    
    var playerEntityData: EntityModel? {
        
        //TODO remove this hack
        guard updatedEntity == nil else {
            return updatedEntity
        }
        
        return entities.easyPlayer
    }
}
