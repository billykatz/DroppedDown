//
//  TileCoord.swift
//  DownFall
//
//  Created by William Katz on 2/15/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation



enum Axis {
    case vertical
    case horizontal
}


struct TileCoord: Codable, Hashable {
    var column: Int {
        return y
    }
    var row: Int {
        return x
    }
    
    let x: Int
    let y: Int
    var tuple : (Int, Int) { return (x, y) }
    static var zero: TileCoord = TileCoord(0,0)
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    init(row: Int, column: Int) {
        self.init(row, column)
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
    
    var northEast: TileCoord {
        return TileCoord(x+1, y+1)
    }
    
    var northWest: TileCoord {
        return TileCoord(x-1, y+1)
    }
    
    var southWest: TileCoord {
        return TileCoord(x-1, y-1)
    }
    
    var southEast: TileCoord {
        return TileCoord(x+1, y-1)
    }
    
    var orthogonalNeighbors: Set<TileCoord> {
        return Set<TileCoord>([colLeft, colRight, rowAbove, rowBelow])
    }
    
    var diagonalNeighbors: Set<TileCoord> {
        return Set<TileCoord>([northEast, northWest, southEast, southWest])
    }
    
    var allNeighbors: Set<TileCoord> {
        return Set<TileCoord>(orthogonalNeighbors.union(diagonalNeighbors))
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
    
    func totalDistance(to: TileCoord, along axis: Axis) -> Int {
        switch axis {
        case .vertical:
            return to.x - x
        case .horizontal:
            return to.y - y
        }
    }
    
    func distance(to: TileCoord, along axis: Axis) -> Int {
        switch axis {
        case .vertical:
            return abs(x - to.x)
        case .horizontal:
            return abs(y - to.y)
        }
    }
    
    /// x              other(same col, row above)     x
    /// other(colLeft, same row)    us    other(colRight, same row)
    /// x              other(same col, row below)   x
    func direction(relative to: TileCoord) -> Direction? {
        if to.y <= colLeft.y && to.x == x {
            return .west
        }
        
        if to.y >= colRight.y && to.x == x {
            return .east
        }
        
        if to.x >= rowAbove.x && to.y == y {
            return .north
        }
        
        if to.x <= rowBelow.x && to.y == y {
            return .south
        }
        
        // We might be a diagonally on the same line
        // Therefore our row and col could both be different than the other row and col
        // If the other coords are different, we have to make sure the difference is the same
        guard distance(to: to, along: .vertical) == distance(to: to, along: .horizontal) else {
            return nil
        }
        
        if to.y <= colLeft.y && to.x >= rowAbove.x {
            return  .northWest
        }
        
        if to.y >= colRight.y && to.x >= rowAbove.x {
            return .northEast
        }
        
        if to.x <= rowBelow.x && to.y <= colLeft.y {
            return .southWest
        }
        
        if to.x <= rowBelow.x && to.y >= colRight.y {
            return .southEast
        }
        
        return nil
    }
    
    func coordsAbove(boardSize: Int) -> [TileCoord] {
        var coordinates: [TileCoord] = []
        for row in x+1..<Int(boardSize) {
            coordinates.append(TileCoord(row, y))
        }
        return coordinates
    }
    
    /// Returns true if self ( c ) exists on the line from points a and to b. With a magnitude larger than ab and in the same direction as the vector ab
    /// ---a---b---c
    /// return true
    /// a------c
    ///  \
    ///   \
    ///    b
    /// return false
    /// a----c----b return false
    /// c---a----b return false
    /// cross productduct = (c.y - a.y) * (b.x - a.x) - (c.x - a.x) * (b.y - a.y)
    func existsOnLineAfter(b: TileCoord, onLineFrom a: TileCoord) -> Bool {
        let crossProduct = (self.y-a.y) * (b.x-a.x) - (self.x-a.x) * (b.y - a.y)

        guard crossProduct == 0 else { return false }
        
        let dotProduct = (self.x - a.x) * (b.x - a.x) + (self.y - a.y) * (b.y - a.y)
        
        guard dotProduct > 0 else { return false }
        
        let lengthAB = (b.x-a.x)*(b.x-a.x) + (b.y-a.y)*(b.y-a.y)
        
        guard dotProduct > lengthAB else { return false }
        
        return true
    }
    
    
    func existsOnLineBetween(b: TileCoord, onLineFrom a: TileCoord) -> Bool {
        let crossProduct = (self.y-a.y) * (b.x-a.x) - (self.x-a.x) * (b.y - a.y)

        guard crossProduct == 0 else { return false }
        
        let dotProduct = (self.x - a.x) * (b.x - a.x) + (self.y - a.y) * (b.y - a.y)
        
        guard dotProduct > 0 else { return false }
        
        let lengthAB = (b.x-a.x)*(b.x-a.x) + (b.y-a.y)*(b.y-a.y)
        
        guard dotProduct <= lengthAB else { return false }
        
        return true
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
    
    static func random(_ size: Int, notInReservedCoords reservedCoords: [TileCoord]) -> TileCoord {
        var newTileCoord = random(size)
        while (reservedCoords.contains(newTileCoord)) {
            newTileCoord = random(size)
        }
        return newTileCoord
    }
}
