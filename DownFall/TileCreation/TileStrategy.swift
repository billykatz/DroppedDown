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
    func tiles(for tiles: [[Tile]]) -> [Tile]
    func board(_ boardSize: Int, difficulty: Difficulty) -> [[Tile]]
    func goldDropped(from monster: EntityModel) -> Int
    var entities: [EntityModel] { get }
    var difficulty: Difficulty { get }
    var updatedEntity: EntityModel? { get }
    var level: Level? { get }
    init(_ entities: [EntityModel],
         difficulty: Difficulty,
         updatedEntity: EntityModel?,
         level: Level?)

}
    
