//
//  Quadrant.swift
//  DownFall
//
//  Created by William Katz on 11/7/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

enum Quadrant: CaseIterable {
    case northEast
    case northWest
    case southEast
    case southWest
    
    var opposite: Quadrant {
        switch self {
        case .northEast:
            return .southWest
        case .northWest:
            return .southEast
        case .southEast:
            return .northWest
        case .southWest:
            return .northEast
        }
    }
    
    var adjacent: [Quadrant] {
        switch self {
        case .northEast:
            return [.northWest, .southEast]
        case .northWest:
            return [.northEast, .southWest]
        case .southWest:
            return [.northWest, .southEast]
        case .southEast:
            return [.southWest, .northEast]
        }
    }
    
    static func quadrant(of coord: TileCoord, in boardSize: Int) -> Quadrant {
        guard boardSize > 1 else { preconditionFailure("The board must be at least 2x2 to use Quadrant") }
        if coord.x < boardSize/2 {
            if coord.y < boardSize/2 {
                return .southWest
            } else {
                return .southEast
            }
        } else {
            if coord.y < boardSize/2 {
                return .northWest
            } else {
                return .northEast
            }
        }
    }
    
    private func randomCoord(for boardSize: Int) -> TileCoord {
        switch self {
        case .northEast:
            return TileCoord(Int.random(in: 2*boardSize/3..<boardSize),
                             Int.random(in: 2*boardSize/3..<boardSize))
        case .northWest:
            return TileCoord(Int.random(in: 2*boardSize/3..<boardSize),
                             Int.random(in: 0...boardSize/3))

        case .southEast:
            return TileCoord(Int.random(in: 0...boardSize/3),
                             Int.random(in: 2*boardSize/3..<boardSize))
        case .southWest:
            return TileCoord(Int.random(in: 0...boardSize/3),
                             Int.random(in: 0...boardSize/3))

        }
    }
    
    func randomCoord(for boardSize: Int, notIn tileCoordSet: Set<TileCoord>) -> TileCoord {
        var tileCoord = randomCoord(for: boardSize)
        while tileCoordSet.contains(tileCoord) {
            tileCoord = randomCoord(for: boardSize)
        }
        return tileCoord
    }
    
    
}
