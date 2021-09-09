//
//  StatsModel.swift
//  DownFall
//
//  Created by Billy on 9/8/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

enum Statistics: Hashable {
    // rocks
    case rocksDestroyed(ShiftShaft_Color, Int)
    case totalRocksDestroyed(Int)
    case largestRockGroupDestroyed(Int)
    
    // gems
    case gemsCollected(ShiftShaft_Color, Int)
    case totalGemsCollected(Int)
    
    // distance/depth
    case lowestDepthReached(Int)
    case distanceFallen(Int)
    
    // Rotations
    case counterClockwiseRotations(Int)
    case clockwiseRotations(Int)
    
    // Monsters
    case monstersKilled(EntityModel.EntityType, Int)
    case totalMonstersKilled(Int)
    case monstersKilledInARow(Int)
    
    // Damage/health
    case damageTaken(Int)
    case healthHealed(Int)
    
    // win/lose
    case totalWins(Int)
    case totalLoses(Int)
    
    // runes
    case runeUses(RuneType, Int)
    case totalRuneUses(Int)
}

extension Statistics: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case base
        case color
        case runeType
        case entityType
        case amount

    }
    
    private enum Base: String, Codable {
        
        case rocksDestroyed
        case totalRocksDestroyed
        case largestRockGroupDestroyed
        case gemsCollected
        case totalGemsCollected
        case lowestDepthReached
        case distanceFallen
        case counterClockwiseRotations
        case clockwiseRotations
        case monstersKilled
        case totalMonstersKilled
        case monstersKilledInARow
        case damageTaken
        case healthHealed
        case totalWins
        case totalLoses
        case runeUses
        case totalRuneUses
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        let amount = try container.decode(Int.self, forKey: .amount)
            
        switch base {
        case .rocksDestroyed:
            let color = try container.decode(ShiftShaft_Color.self, forKey: .color)
            self = .rocksDestroyed(color, amount)
        case .totalRocksDestroyed:
            self = .totalRocksDestroyed(amount)
        case .largestRockGroupDestroyed:
            self = .largestRockGroupDestroyed(amount)
        case .gemsCollected:
            let color = try container.decode(ShiftShaft_Color.self, forKey: .color)
            self = .gemsCollected(color, amount)
        case .totalGemsCollected:
            self = .totalGemsCollected(amount)
        case .lowestDepthReached:
            self = .lowestDepthReached(amount)
        case .distanceFallen:
            self = .distanceFallen(amount)
        case .counterClockwiseRotations:
            self = .counterClockwiseRotations(amount)
        case .clockwiseRotations:
            self = .clockwiseRotations(amount)
        case .monstersKilled:
            let type = try container.decode(EntityModel.EntityType.self, forKey: .entityType)
            self = .monstersKilled(type, amount)
        case .totalMonstersKilled:
            self = .totalMonstersKilled(amount)
        case .monstersKilledInARow:
            self = .monstersKilledInARow(amount)
        case .damageTaken:
            self = .damageTaken(amount)
        case .healthHealed:
            self = .healthHealed(amount)
        case .totalWins:
            self = .totalWins(amount)
        case .totalLoses:
            self = .totalLoses(amount)
        case .runeUses:
            let type = try container.decode(RuneType.self, forKey: .runeType)
            self = .runeUses(type, amount)
        case .totalRuneUses:
            self = .totalRuneUses(amount)
        
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .rocksDestroyed(color, amount):
            try container.encode(Base.rocksDestroyed, forKey: .base)
            try container.encode(color, forKey: .color)
            try container.encode(amount, forKey: .amount)
        case let .totalRocksDestroyed(amount):
            try container.encode(Base.totalRocksDestroyed, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case let .largestRockGroupDestroyed(amount):
            try container.encode(Base.largestRockGroupDestroyed, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case let .gemsCollected(color, amount):
            try container.encode(Base.gemsCollected, forKey: .base)
            try container.encode(color, forKey: .color)
            try container.encode(amount, forKey: .amount)
        case .totalGemsCollected(let amount):
            try container.encode(Base.totalGemsCollected, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .lowestDepthReached(let amount):
            try container.encode(Base.lowestDepthReached, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .distanceFallen(let amount):
            try container.encode(Base.distanceFallen, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .counterClockwiseRotations(let amount):
            try container.encode(Base.counterClockwiseRotations, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .clockwiseRotations(let amount):
            try container.encode(Base.clockwiseRotations, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .monstersKilled( let type, let amount):
            try container.encode(Base.monstersKilled, forKey: .base)
            try container.encode(type, forKey: .entityType)
            try container.encode(amount, forKey: .amount)
        case .totalMonstersKilled(let amount):
            try container.encode(Base.totalMonstersKilled, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .monstersKilledInARow(let amount):
            try container.encode(Base.monstersKilledInARow, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .damageTaken(let amount):
            try container.encode(Base.damageTaken, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .healthHealed(let amount):
            try container.encode(Base.healthHealed, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .totalWins(let amount):
            try container.encode(Base.totalWins, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .totalLoses(let amount):
            try container.encode(Base.totalLoses, forKey: .base)
            try container.encode(amount, forKey: .amount)
        case .runeUses(let runeType, let amount):
            try container.encode(Base.runeUses, forKey: .base)
            try container.encode(runeType, forKey: .runeType)
            try container.encode(amount, forKey: .amount)
        case .totalRuneUses(let amount):
            try container.encode(Base.totalRuneUses, forKey: .base)
            try container.encode(amount, forKey: .amount)
        }
    }

}

