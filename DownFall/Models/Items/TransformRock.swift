//
//  TransformRock.swift
//  DownFall
//
//  Created by Katz, Billy on 4/30/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit

struct TransformRock: Ability {
    
    var rechargeMinimum: Int {
        return 1
    }
    
    var progressColor: UIColor {
        return UIColor.lightBarPurple
    }
    
    var cooldown: Int { return 25 }
    
    var rechargeType: [TileType] { return [TileType.rock(.purple)] }
    
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
        return "transformRock"
    }
    
    var cost: Int { return 0 }
    
    var currency: Currency { return .gem }
    
    var type: AbilityType { return .transformRock }
    
    var description: String {
        return "Transform 3 rocks into purple"
    }
    
    var flavorText: String {
        return "Barney was one a red dinosaur before running into me. - Durham the Dwarf"
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
    var targets: Int? { return 3 }
    var targetTypes: [TileType]? {
        return TileType.rockCases
    }
    var distanceBetweenTargets: Int? { return Int.max }
}


