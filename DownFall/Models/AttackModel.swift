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
    var attackSlope: [AttackSlope]
    var lastAttackTurn: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        typealias RawValue = String
        case type
        case frequency
        case range
        case damage
        case attacksPerTurn
        case attackSlope
    }

    static let zero = AttackModel(type: .targets,
                                  frequency: 0,
                                  range: RangeModel(lower: 0, upper: 0),
                                  damage: 0,
                                  attacksThisTurn: 0,
                                  turns: 0,
                                  attacksPerTurn: 0,
                                  attackSlope: [],
                                  lastAttackTurn: 0)
    
    func didAttack() -> AttackModel {
        return AttackModel(type: type,
                           frequency: frequency,
                           range: range,
                           damage: damage,
                           attacksThisTurn: attacksThisTurn + 1,
                           turns: turns,
                           attacksPerTurn: attacksPerTurn,
                           attackSlope: attackSlope,
                           lastAttackTurn: turns)
    }
    
    func resetAttack() -> AttackModel {
        return AttackModel(type: type,
                           frequency: frequency,
                           range: range,
                           damage: damage,
                           attacksThisTurn: 0,
                           turns: turns,
                           attacksPerTurn: attacksPerTurn,
                           attackSlope: attackSlope,
                           lastAttackTurn: lastAttackTurn)
    }
    
    func incrementTurns() -> AttackModel {
        return AttackModel(type: type,
                           frequency: frequency,
                           range: range,
                           damage: damage,
                           attacksThisTurn: attacksThisTurn,
                           turns:  turns + 1,
                           attacksPerTurn: attacksPerTurn,
                           attackSlope: attackSlope,
                           lastAttackTurn: lastAttackTurn)
    }
    
    func willAttackNextTurn() -> Bool {
        //TODO: delete this
        return false
    }
    
    
    func turnsUntilNextAttack() -> Int? {
        if type == .targets { return 0 }
        if isCharged { return 0 }
        return self.frequency - (self.turns - lastAttackTurn) % self.frequency
    }
    
    var isCharged: Bool {
        if turns == lastAttackTurn { return false }
        if (turns - lastAttackTurn) / frequency >= 1 { return true }
        if (turns - lastAttackTurn) < frequency { return false }
        return (self.turns % self.frequency) == 0
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
