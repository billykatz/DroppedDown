//
//  TileStrategy.swift
//  DownFall
//
//  Created by William Katz on 1/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import GameplayKit

protocol TileStrategy {
    var randomSource: GKLinearCongruentialRandomSource { get }
    var entities: EntitiesModel { get }
    var difficulty: Difficulty { get }
    var updatedEntity: EntityModel? { get }
    var level: Level { get }
    
    func tiles(for tiles: [[Tile]], forceMonster: Bool, monsterWasKilled: Bool) -> [[Tile]]
    func board(difficulty: Difficulty) -> ([[Tile]], newLevel: Bool)
    func monsterWithType(_ type: EntityModel.EntityType) -> Tile?
    func randomMonster() -> TileType
    func randomMonster(not: EntityModel.EntityType) -> Tile
    func shuffle(tiles: [[Tile]]) -> [[Tile]]
    func randomRock(_ neighbors: [Tile], playerData: EntityModel, forceHoldGem: Bool) -> TileType

}
    
