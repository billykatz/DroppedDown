//
//  KillMonsterGroup.swift
//  DownFall
//
//  Created by Katz, Billy on 3/29/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation


struct KillMonsterGroupPotion: Ability {
    
    var count: Int
    
    init(count: Int = 0) {
        self.count = 0
    }
    
    func animatedColumns() -> Int? {
        return nil
    }
    
    var affectsCombat: Bool {
        false
    }
    
    var type: AbilityType { return .tapAwayMonster }
    
    var textureName: String {
        return "killMonsterPotionSpriteSheet"
    }
    
    var cost: Int { return 399 }
    
    var currency: Currency {
        return .gold
    }
    
    var description: String {
        return "Destory a group (3+) monsters"
    }
    
    var flavorText: String {
        return "Finger pushups finally pay off"
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
