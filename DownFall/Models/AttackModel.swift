//
//  Attack.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct AttackModel: Equatable, Decodable {
    let frequency: Int
    let range: RangeModel
    let damage: Int
    let directions: [Direction]
    var attacksThisTurn: Int = 0
    let attacksPerTurn: Int
    
    private enum CodingKeys: String, CodingKey {
        typealias RawValue = String
        
        case frequency
        case range
        case damage
        case directions
        case attacksPerTurn
    }

    
    static let zero = AttackModel(frequency: 0,
                                  range: RangeModel(lower: 0, upper: 0),
                                  damage: 0,
                                  directions: [],
                                  attacksThisTurn: 0,
                                  attacksPerTurn: 0)
    
    func didAttack() -> AttackModel {
        return AttackModel(frequency: frequency,
                           range: range,
                           damage: damage,
                           directions: directions,
                           attacksThisTurn: attacksThisTurn + 1,
                           attacksPerTurn: attacksPerTurn)
    }
    
    func resetAttack() -> AttackModel {
        return AttackModel(frequency: frequency,
                           range: range,
                           damage: damage,
                           directions: directions,
                           attacksThisTurn: 0,
                           attacksPerTurn: attacksPerTurn)
    }
    
}
