//
//  EmptyAttack.swift
//  DownFall
//
//  Created by Katz, Billy on 1/24/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit

struct Empty: Ability {
    var rechargeMinimum: Int {
        return 1
    }
    
    var progressColor: UIColor {
        return UIColor.darkBarRed
    }
    
    var cooldown: Int { return 0 }
    
    var rechargeType: [TileType] { return [] }
    
    var count: Int
    
    init(count: Int = 0) {
        self.count = 0
    }
    
    var heal: Int? { return nil }
    
    func animatedColumns() -> Int? { return nil }
    
    var affectsCombat: Bool { return false }
    
    var textureName: String { return "" }
    
    var cost: Int { return 0 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .doubleAttack }
    
    var description: String { return "Empty ability." }
    
    var flavorText: String { return "Gives whole new meaning to the ol' saying 'kill two birds with one pickaxe.'" }
    
    var extraAttacksGranted: Int? { return nil }
    
    func blocksDamage(from: Direction) -> Int? { return nil }
    
    var usage: Usage { return .once }
    
    var targets: Int? { return nil }
    
    var targetTypes: [TileType]? { return nil }
    
    var distanceBetweenTargets: Int? { return nil }
}
