//
//  Attack.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

enum AttackType: String, Decodable {
    case targets
    case areaOfEffect
    case charges
}

struct AttackModel: Equatable, Decodable {
    let type: AttackType
    let frequency: Int
    let range: RangeModel
    let damage: Int
    let directions: [Direction]
    var attacksThisTurn: Int = 0
    var turns: Int = 1
    let attacksPerTurn: Int
    var charge: Int?
    
    private enum CodingKeys: String, CodingKey {
        typealias RawValue = String
        case type
        case frequency
        case range
        case damage
        case directions
        case attacksPerTurn
    }

    static let zero = AttackModel(type: .targets,
                                  frequency: 0,
                                  range: RangeModel(lower: 0, upper: 0),
                                  damage: 0,
                                  directions: [],
                                  attacksThisTurn: 0,
                                  turns: 0,
                                  attacksPerTurn: 0,
                                  charge: 0)
    
    func didAttack() -> AttackModel {
        return AttackModel(type: type,
                           frequency: frequency,
                           range: range,
                           damage: damage,
                           directions: directions,
                           attacksThisTurn: attacksThisTurn + 1,
                           turns: turns,
                           attacksPerTurn: attacksPerTurn,
                           charge: 0)
    }
    
    func resetAttack() -> AttackModel {
        return AttackModel(type: type,
                           frequency: frequency,
                           range: range,
                           damage: damage,
                           directions: directions,
                           attacksThisTurn: 0,
                           turns: turns,
                           attacksPerTurn: attacksPerTurn,
                           charge: charge ?? 0)
    }
    
    func incrementTurns() -> AttackModel {
        let charge = self.charge ?? 0
        return AttackModel(type: type,
                           frequency: frequency,
                           range: range,
                           damage: damage,
                           directions: directions,
                           attacksThisTurn: attacksThisTurn,
                           turns:  turns + 1,
                           attacksPerTurn: attacksPerTurn,
                           charge: min(frequency, charge + 1))
    }
    
    func willAttackNextTurn() -> Bool {
        let shouldAttack = (self.turns + 1) % self.frequency == 0
        return shouldAttack && type == .areaOfEffect
    }
    
    var isCharged: Bool {
        return (charge ?? 0) == frequency
    }
    
}
