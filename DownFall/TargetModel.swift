//
//  TargetModel.swift
//  DownFall
//
//  Created by Billy on 12/1/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

struct Target: Codable, Hashable {
    let coord: TileCoord
    let associatedCoord: [TileCoord]
    let isLegal: Bool
    
    var all: [TileCoord] {
        return  [coord] + associatedCoord
    }
    
}

struct AllTarget: Codable, Hashable {
    var targets: [Target]
    let areLegal: Bool
    
    var allTargetCoords: [TileCoord] {
        return targets.map { $0.coord }
    }
    
    var allTargetAssociatedCoords: [TileCoord] {
        return targets.flatMap { $0.all }
    }
    
    func targetContaining(playerCoord: TileCoord) -> Target? {
        for target in targets {
            if target.all.contains(where: { $0 == playerCoord }) {
                return target
            }
        }
        return nil
    }
}
