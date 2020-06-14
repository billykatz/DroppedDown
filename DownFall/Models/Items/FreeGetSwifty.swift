//
//  FreeGetSwifty.swift
//  DownFall
//
//  Created by Katz, Billy on 4/30/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit

struct FreeGetSwifty: Ability {
    
    var rechargeMinimum: Int {
        return 1
    }
    
    var progressColor: UIColor {
        return UIColor.lightBarBlue
    }
    
    var cooldown: Int { return 25 }
    
    var rechargeType: [TileType] { return [TileType.rock(.blue)] }
    
    var count: Int
    
    init(count: Int = 0) {
        self.count = 0
    }
    
    func animatedColumns() -> Int? {
        return nil
    }
    
    var affectsCombat: Bool {
        return false
    }
    
    var textureName: String {
        return "getSwifty"
    }
    
    var cost: Int { return 0 }
    
    var currency: Currency { return .gem }
    
    var type: AbilityType { return .getSwifty }
    
    var description: String {
        return "Swap places with an adjacent rock."
    }
    
    var flavorText: String {
        return "Show them the meaning of swift."
    }
    
    var extraAttacksGranted: Int? {
        return nil
    }
    
    func blocksDamage(from: Direction) -> Int? {
        return nil
    }
    
    var usage: Usage {
        return .permanent
    }
    
    var heal: Int? { return nil }
    var targets: Int? { return 2 }
    var targetTypes: [TileType]? {
        var cases = TileType.rockCases
        cases.append(TileType.player(.playerZero))
        return cases
    }
    var distanceBetweenTargets: Int? { return 1 }
}

