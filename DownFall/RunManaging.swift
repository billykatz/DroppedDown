//
//  RunManaging.swift
//  DownFall
//
//  Created by Katz, Billy on 8/1/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

class RunModel: Codable {
    let player: EntityModel
    var depth: Int
    
    init(player: EntityModel, depth: Int) {
        self.player = player
        self.depth = depth
    }
 
    /// Keep track of levels
    private var levels: [Level] = []
    
    /// Return the level that corresponds with the depth
    /// If that level has not been built yet, then build it, append it to our private level store, and return the newly built level
    func currentLevel() -> Level {
        guard levels.count > depth else {
            // generate a level and append it to our level property
            let level = LevelConstructor.buildLevel(depth: depth)
            levels.append(level)
            return level
        }
        return levels[depth]
    }
}
