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
    
    var humanReadable: String {
        if abs(over) == abs(up) {
            return "diagonally"
        } else if over > 0, up == 0 {
            return "right"
        } else if over < 0, up == 0 {
            return "left"
        } else if up > 0, over == 0 {
            return "up"
        } else if up < 0, over == 0 {
            return "down"
        }
        return "over \(over) and up \(up)"
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
    
    func numberDescription(for number: Int) -> String {
        let numberDescriptor: String
        switch number {
        case 1:
            numberDescriptor = "st"
        case 2:
            numberDescriptor = "nd"
        case 3:
            numberDescriptor = "rd"
        default:
            numberDescriptor = "th"
            
        }
        return numberDescriptor
    }
    
    public func humanReadable() -> String {
        var string = ""
        let numberDescriptor = numberDescription(for: range.lower)
        let upperNumberDescriptor = numberDescription(for: range.upper)
        
        /// direction string
        let directionString: String
        let directions = attackSlope.map { $0.humanReadable }.removingDuplicates()
        if directions.count == 1 {
            directionString = "attacks \(directions.first!)."
        } else if directions.count == 2 {
            directionString = "attacks \(directions[0]) and \(directions[1])."
        } else {
            let directionsWithCommas = directions.dropLast().joined(separator: ", ")
            let lastDirection = "and \(directions.last ?? "")"
            directionString = "attacks \(directionsWithCommas)\(lastDirection)."
        }
        string.append("\u{2022} \(directionString)")
        
        /// range string
        let attackString: String
        if range.lower == range.upper {
            attackString = "attacks the \(range.lower)\(numberDescriptor) tile."
        } else if range.lower == range.upper - 1  {
            attackString = "attacks the \(range.lower)\(numberDescriptor) and \(range.upper)\(upperNumberDescriptor) tile."
        }
        else {
            attackString = "attacks the \(range.lower)\(numberDescriptor) through the \(range.upper)\(upperNumberDescriptor) tiles."
        }
        string.append("\n\u{2022} \(attackString)")
        string.append("\n\u{2022} deals \(damage) base damage.")
        
        return string
        
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
