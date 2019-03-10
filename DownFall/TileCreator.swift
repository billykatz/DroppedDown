//
//  TileCreator.swift
//  DownFall
//
//  Created by William Katz on 1/9/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import GameplayKit

struct TileCreator: TileStrategy {
    static func tiles(for board: Board, difficulty: Difficulty = .normal) -> [TileType] {
        var newTiles: [TileType] = []
        var newMonsterCount = 0
        let maxMonsters = 0//difficulty.maxExpectedMonsters(for: board)
        let currentMonsterCount = board.tiles(of: .greenMonster()).count
        while (newTiles.count < board.tiles(of: .empty).count) {
            var canAdd = true
            let nextTile = TileType.randomTile(randomSource.nextInt())
            if (TileType.exit == nextTile) {
                canAdd = false
                if board.tiles(of: .exit).count < 1 && !newTiles.contains(.exit) {
                    newTiles.append(nextTile)
                }
            }
            
            if (TileType.player() == nextTile) {
                canAdd = false
                if board.tiles(of: .player()).count < 1 && !newTiles.contains(.player()) {
                    newTiles.append(nextTile)
                }
            }
            
            if (TileType.greenMonster() == nextTile) {
                canAdd = false
                if currentMonsterCount + newMonsterCount < maxMonsters  {
                    newMonsterCount += 1
                    newTiles.append(nextTile)
                }
            }
            
            if TileType.empty == nextTile {
                canAdd = false
            }
            canAdd ? newTiles.append(nextTile) : ()
        }
        return newTiles
    }
    
    static var randomSource = GKLinearCongruentialRandomSource()

}

