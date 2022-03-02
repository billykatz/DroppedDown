//
//  ChanceModel.swift
//  DownFall
//
//  Created by Billy on 3/1/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation

class BlockChangeModel {
    let block: () -> ()
    let chance: Float
    
    init(block: @escaping () -> (), chance: Float) {
        self.block = block
        self.chance = chance
    }
  
}

class ChanceModel: Equatable {
    static func == (lhs: ChanceModel, rhs: ChanceModel) -> Bool {
        return  (lhs.tileType == rhs.tileType) && (lhs.chance == rhs.chance)
    }
    
    
    let tileType: TileType
    let chance: Float
    
    init(tileType: TileType, chance: Float) {
        self.tileType = tileType
        self.chance = chance
    }
}
