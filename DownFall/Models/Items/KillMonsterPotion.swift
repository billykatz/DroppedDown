//
//  KillMonsterPotion.swift
//  DownFall
//
//  Created by Katz, Billy on 1/16/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

struct KillMonsterPotion: Ability {
    
    var count: Int
    
    init(count: Int = 0) {
        self.count = 0
    }
    
    func animatedColumns() -> Int? {
        return 7
    }
    
    var affectsCombat: Bool {
        false
    }
    
    var type: AbilityType { return .killMonsterPotion }
    
    var textureName: String {
        return "killMonsterPotionSpriteSheet"
    }
    
    var cost: Int {
        return 125
    }
    
    var currency: Currency {
        return .gold
    }
    
    var description: String {
        return "Kill any monster.  That monster does not drop any gold."
    }
    
    var flavorText: String {
        return "The patent is held by the Dryad Queen Cecila, known far and wide for her thriftiness."
    }
    
    var extraAttacksGranted: Int? {
        return nil
    }
    
    var usage: Usage {
        .once
    }
    
    func blocksDamage(from: Direction) -> Int? {
        return nil
    }
    
    var heal: Int? { return nil }
    var targets: Int? { return 1 }
    var targetTypes: [TileType]? { return [TileType.monster(.zero)] }
}
