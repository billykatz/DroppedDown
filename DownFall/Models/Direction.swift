//
//  Direction.swift
//  DownFall
//
//  Created by William Katz on 6/29/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

protocol Option: RawRepresentable, Hashable, CaseIterable {}

enum Direction: String, Option, Codable {
    case north, south, east, west, northEast, southEast, northWest, southWest
}

typealias Directions = Set<Direction>
typealias Vector = (Directions, ClosedRange<Int>)

extension Set where Element: Option {
    var rawValue: Int {
        var rawValue = 0
        for (index, element) in Element.allCases.enumerated() {
            if self.contains(element) {
                rawValue |= (1 << index)
            }
        }
        
        return rawValue
    }
}

extension Set where Element == Direction {
    static var sideways: Set<Direction> {
        return [.east, .west]
    }
    
    static var upDown: Set<Direction> {
        return [.north, .south]
    }
    
    static var all: Set<Direction> {
        return Set(Element.allCases)
    }
}
