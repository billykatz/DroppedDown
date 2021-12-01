//
//  TargetModel.swift
//  DownFall
//
//  Created by Billy on 12/1/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

struct Target {
    let coord: TileCoord
    let associatedCoord: [TileCoord]
    let isLegal: Bool
    
    var all: [TileCoord] {
        return  [coord] + associatedCoord
    }
}

struct AllTarget {
    var targets: [Target]
    let areLegal: Bool
    
    var all: [TileCoord] {
        return targets.reduce([]) { prev, target in
            var newArray = prev
            newArray.append(contentsOf: target.all)
            return newArray
        }
    }
}
