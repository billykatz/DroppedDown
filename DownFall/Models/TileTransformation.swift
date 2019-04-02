//
//  TileTransformation.swift
//  DownFall
//
//  Created by William Katz on 12/24/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

struct TileTransformation: Equatable, Hashable {
    let initial : TileCoord
    let end : TileCoord
    
    init(_ initial: TileCoord, _ end: TileCoord) {
        self.initial = initial
        self.end = end
    }
}
