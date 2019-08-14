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
    
    func isOrthogonallyAdjacent(to other: TileCoord) -> Bool {
        
        /// x  x  x
        /// x  us them
        /// x  x  x
        if other.y == colRight.y && other.x == x {
            return true
        }
        
        /// x    x   x
        /// them us  x
        /// x    x   x
        if other.y == colLeft.y && other.x == x {
            return true
        }
        
        /// x   them  x
        /// x    us   x
        /// x    x    x
        if other.x == rowAbove.x && other.y == y {
            return true
        }
        
        /// x    x     x
        /// x    us    x
        /// x   them   x
        if other.x == rowBelow.x && other.y == y {
            return true
        }
        
        return false
    }
    
    /// x              other(same col, row above)     x
    /// other(colLeft, same row)    us    other(colRight, same row)
    /// x              other(same col, row below)   x
    func direction(relative to: TileCoord) -> Direction? {
        if to.y == colLeft.y && to.x == x {
            return .west
        }
        
        if to.y == colRight.y && to.x == x {
            return .east
        }
        
        if to.x == rowAbove.x && to.y == y {
            return .north
        }
        
        if to.x == rowBelow.x && to.y == y {
            return .south
        }
        
        return nil
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
