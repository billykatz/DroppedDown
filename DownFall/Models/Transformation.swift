//
//  Transformation.swift
//  DownFall
//
//  Created by William Katz on 12/24/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

struct Transformation {
    let endBoard: Board
    let endTiles: [[TileType]]?
    var tileTransformation: [[TileTransformation]]?
    
    init(board endBoard: Board, tiles endTiles: [[TileType]]? = nil, transformation tileTransformation: [[TileTransformation]]? = nil) {
        self.endBoard = endBoard
        self.endTiles = endTiles
        self.tileTransformation = tileTransformation
    }
}
