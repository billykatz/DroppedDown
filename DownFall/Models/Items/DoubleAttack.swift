//
//  DoubleAttack.swift
//  DownFall
//
//  Created by William Katz on 8/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct DoubleAttack: Ability {
    
    var count: Int
    
    init(count: Int = 0) {
        self.count = 0
    }
    
    var heal: Int? { return nil }
    
    
    func animatedColumns() -> Int? {
        return nil
    }
    
    var affectsCombat: Bool {
        return true
    }
    
    var textureName: String {
        return "doubleAttack"
    }
    
    var cost: Int { return 2 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .doubleAttack }
    
    var description: String {
        return "Swing at your foes twice in one turn with this two headed pickaxe."
    }
    
    var flavorText: String {
        return "Gives whole new meaning to the ol' saying 'kill two birds with one pickaxe.'"
    }
    
    var extraAttacksGranted: Int? {
        return 1
    }
    
    func blocksDamage(from: Direction) -> Int? {
        return nil
    }
    
    var usage: Usage {
        return .oneRun
    }
    
    var targets: Int? { return nil }
    var targetTypes: [TileType]? { return nil }
}
