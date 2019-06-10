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
    func tiles(for board: Board, difficulty: Difficulty) -> [TileType]
}
    
