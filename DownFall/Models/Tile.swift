//
//  Tile.swift
//  DownFall
//
//  Created by William Katz on 5/11/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

enum TileType: String, Equatable, CaseIterable {
    case blueRock
    case blackRock
    case greenRock
    case player = "player2"
    case empty = "empty"
    case exit
    
    static func randomRock() -> TileType {
        return [TileType.blueRock, TileType.blackRock, TileType.greenRock].shuffled().first!
    }
}
