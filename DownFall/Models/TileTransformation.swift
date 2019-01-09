//
//  TileTransformation.swift
//  DownFall
//
//  Created by William Katz on 12/24/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

struct TileTransformation {
    let initial : TileCoord
    let end : TileCoord
    let endTileType: TileType?
    
    init(_ initial: TileCoord, _ end: TileCoord, _ endTileType: TileType? = nil) {
        self.initial = initial
        self.end = end
        self.endTileType = endTileType
    }
}
