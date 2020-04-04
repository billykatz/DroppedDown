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
    func tiles(for tiles: [[Tile]]) -> [[Tile]]
    func board(difficulty: Difficulty) -> [[Tile]]
    func goldDropped(from monster: EntityModel) -> Int
    func randomMonster() -> TileType
    func randomMonster(not: EntityModel.EntityType) -> Tile
    func shuffle(tiles: [[Tile]]) -> [[Tile]]
    var entities: EntitiesModel { get }
    var difficulty: Difficulty { get }
    var updatedEntity: EntityModel? { get }
    var level: Level? { get }
    init(_ entities: EntitiesModel,
         difficulty: Difficulty,
         updatedEntity: EntityModel?,
         level: Level?)

}
    
