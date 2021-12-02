//
//  TileTransformation.swift
//  DownFall
//
//  Created by William Katz on 12/24/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import CoreGraphics

struct TileTransformation: Hashable {
    let initial : TileCoord
    let end : TileCoord
    
    init(_ initial: TileCoord, _ end: TileCoord) {
        self.initial = initial
        self.end = end
    }
    
    var distanceBetweenPoints: CGFloat {
        return initial.distance(to: end)
    }
    
    /// This function assumes that the coords are in the same column
    var coordsBelowStartIncludingEnd: [TileCoord] {
        guard initial.col == end.col else { return [] }
        var coords: [TileCoord] = []
        
        var nextCoord = initial.rowBelow
        while nextCoord.row >= end.row && nextCoord.row >= 0 {
            coords.append(nextCoord)
            nextCoord = nextCoord.rowBelow
        }
        
        return coords
    }
}
