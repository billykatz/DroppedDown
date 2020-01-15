//
//  Attack.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct AttackSlope: Equatable, Decodable {
    let over: Int
    let up: Int
    
    static var playerPossibleAttacks: [AttackSlope] {
        return [
            AttackSlope(over: -1, up: 0),
            AttackSlope(over: 0, up: 1),
            AttackSlope(over: 0, up: -1),
            AttackSlope(over: 1, up: 0)
        ]
    }
}


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
    var attacksThisTurn: Int = 0
    var turns: Int = 1
    let attacksPerTurn: Int
    var charge: Int?
    var attackSlope: [AttackSlope]
    
    private enum CodingKeys: String, CodingKey {
        typealias RawValue = String
        case type
        case frequency
        case range
        case damage
        case attacksPerTurn
        case charge
        case attackSlope
    }

    static let zero = AttackModel(type: .targets,
                                  frequency: 0,
                                  range: RangeModel(lower: 0, upper: 0),
                                  damage: 0,
                                  attacksThisTurn: 0,
                                  turns: 0,
                                  attacksPerTurn: 0,
                                  charge: 0,
                                  attackSlope: [])
    
    func didAttack() -> AttackModel {
        return AttackModel(type: type,
                           frequency: frequency,
                           range: range,
                           damage: damage,
                           attacksThisTurn: attacksThisTurn + 1,
                           turns: turns,
                           attacksPerTurn: attacksPerTurn,
                           charge: 0,
                           attackSlope: attackSlope)
    }
    
    func resetAttack() -> AttackModel {
        return AttackModel(type: type,
                           frequency: frequency,
                           range: range,
                           damage: damage,
                           attacksThisTurn: 0,
                           turns: turns,
                           attacksPerTurn: attacksPerTurn,
                           charge: charge ?? 0,
                           attackSlope: attackSlope)
    }
    
    func incrementTurns() -> AttackModel {
        let charge = self.charge ?? 0
        return AttackModel(type: type,
                           frequency: frequency,
                           range: range,
                           damage: damage,
                           attacksThisTurn: attacksThisTurn,
                           turns:  turns + 1,
                           attacksPerTurn: attacksPerTurn,
                           charge: min(frequency, charge + 1),
                           attackSlope: attackSlope)
    }
    
    func willAttackNextTurn() -> Bool {
        let shouldAttack = (self.turns + 1) % self.frequency == 0
        return shouldAttack && type == .areaOfEffect
    }
    
    func turnsUntilNextAttack() -> Int? {
        if type == .targets { return nil }
        if isCharged { return 0 }
        return self.frequency - self.turns % self.frequency
    }
    
    var isCharged: Bool {
        return (charge ?? 0) == frequency
    }
    
    public func targets(from position: TileCoord) -> [TileCoord] {
        func calculateTargetSlope(in slopedDirection: AttackSlope, distance i: Int, from position: TileCoord) -> TileCoord {
            let (initialRow, initialCol) = position.tuple
            
            // Take the initial position and calculate the target
            // Add the slope's "up" value multiplied by the distance to the row
            // Add the slope's "over" value multipled by the distane to the column
            return TileCoord(initialRow + (i * slopedDirection.up), initialCol + (i * slopedDirection.over))
        }
        
        return attackSlope.flatMap { attackSlope in
            return (range.lower...range.upper).map { range in
                return calculateTargetSlope(in: attackSlope, distance: range, from: position)
            }
        }
    }
    
}
