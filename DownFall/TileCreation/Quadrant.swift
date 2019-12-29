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
    
    func randomCoord(for boardSize: Int) -> TileCoord {
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
}
