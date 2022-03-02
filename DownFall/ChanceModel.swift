//
//  ChanceModel.swift
//  DownFall
//
//  Created by Billy on 3/1/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation

class IdentifiableBlock: Equatable {
    static func ==(lhs: IdentifiableBlock, rhs: IdentifiableBlock) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    let block: () -> ()
    let id = UUID()
    
    init(block: @escaping () -> ()) {
        self.block = block
    }

}

class BlockChanceModel {
    
    let block: () -> ()
    let chance: Float
    
    init(block: @escaping () -> (), chance: Float) {
        self.block = block
        self.chance = chance
    }
  
}

class AnyChanceModel<T: Equatable>: Equatable {
    static func == (lhs: AnyChanceModel, rhs: AnyChanceModel) -> Bool {
        return  (lhs.thing == rhs.thing) && (lhs.chance == rhs.chance)
    }
    
    
    let thing: T
    let chance: Float
    
    init(thing: T, chance: Float) {
        self.thing = thing
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
