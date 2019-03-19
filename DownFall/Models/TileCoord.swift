//
//  TileCoord.swift
//  DownFall
//
//  Created by William Katz on 2/15/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation


struct TileCoord: Hashable {
    let x, y: Int
    var tuple : (Int, Int) { return (x, y) }
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    var rowAbove : TileCoord {
        return TileCoord(self.x+1, self.y)
    }
    
    var rowBelow : TileCoord {
        return TileCoord(self.x-1, self.y)
    }
    
    var colLeft : TileCoord {
        return TileCoord(self.x, self.y-1)
    }
    
    var colRight : TileCoord {
        return TileCoord(self.x, self.y+1)
    }
    
    static func random(_ size: Int) -> TileCoord {
        return TileCoord(Int.random(size), Int.random(size))
    }
    
    static func random(_ size: Int, not: TileCoord) -> TileCoord {
        var newTileCoord = not
        while (newTileCoord == not) {
            newTileCoord = random(size)
        }
        return newTileCoord
    }
}
