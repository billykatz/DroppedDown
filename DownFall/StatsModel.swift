//
//  StatsModel.swift
//  DownFall
//
//  Created by Billy on 9/8/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

enum StatisticType: Int, Codable {
    case rocksDestroyed
    case totalRocksDestroyed
    case largestRockGroupDestroyed
    
    // gems
    case gemsCollected
    case totalGemsCollected
    
    // distance/depth
    case lowestDepthReached
    case distanceFallen
    
    // Rotations
    case counterClockwiseRotations
    case clockwiseRotations
    
    // Monsters
    case monstersKilled
    case totalMonstersKilled
    case monstersKilledInARow
    
    // Damage/health
    case damageTaken
    case healthHealed
    
    // win/lose
    case totalWins
    case totalLoses
    
    // runes
    case runeUses
    case totalRuneUses
    
}

struct Statistics: Codable, Equatable {
    let rockColor: ShiftShaft_Color?
    let gemColor: ShiftShaft_Color?
    let monsterType: EntityModel.EntityType?
    let runeType: RuneType?
    let amount: Int
    let statType: StatisticType
    
    init(rockColor: ShiftShaft_Color? = nil, gemColor: ShiftShaft_Color? = nil, monsterType: EntityModel.EntityType? = nil, runeType: RuneType? = nil, amount: Int, statType: StatisticType) {
        self.rockColor = rockColor
        self.gemColor = gemColor
        self.monsterType = monsterType
        self.runeType = runeType
        self.amount = amount
        self.statType = statType
    }
}

extension Statistics {
    static var oneHundredRocks = Self.init(amount: 100, statType: .totalRocksDestroyed)
    static var fiveHundredRocks = Self.init(amount: 500, statType: .totalRocksDestroyed)
    static var oneThousandRocks = Self.init(amount: 1000, statType: .totalRocksDestroyed)
    
    static var oneHundredGems = Self.init(amount: 100, statType: .totalGemsCollected)
    static var twoHundredGems = Self.init(amount: 200, statType: .totalGemsCollected)
    static var threeHundredGems = Self.init(amount: 300, statType: .totalGemsCollected)
    
    /// base cases
    static var blueRocksDestroyed = Self.init(rockColor: .blue, amount: 0, statType: .rocksDestroyed)
    static var redRocksDestroyed = Self.init(rockColor: .red, amount: 0, statType: .rocksDestroyed)
    static var purpleRocksDestroyed = Self.init(rockColor: .purple, amount: 0, statType: .rocksDestroyed)
    static var totalRocksDestroyed = Self.init(amount: 0, statType: .totalRocksDestroyed)
    static var totalRocksDestroyed100_000 = Self.init(amount: 100_000, statType: .totalRocksDestroyed)
    static var largestRockGroupDestroyed = Self.init(amount: 0, statType: .largestRockGroupDestroyed)
    static var blueGemsCollected = Self.init(gemColor: .blue, amount: 0, statType: .gemsCollected)
    static var purpleGemsCollected = Self.init(gemColor: .purple, amount: 0, statType: .gemsCollected)
    static var redGemsCollected = Self.init(gemColor: .red, amount: 0, statType: .gemsCollected)
    static var totalGemsCollected = Self.init(amount: 0, statType: .totalGemsCollected)
    static var lowestDepthReached = Self.init(amount: 0, statType: .lowestDepthReached)
    static var distanceFallen = Self.init(amount: 0, statType: .distanceFallen)
    static var counterClockwiseRotations = Self.init(amount: 0, statType: .counterClockwiseRotations)
    static var clockwiseRotations = Self.init(amount: 0, statType: .clockwiseRotations)
    static var alamosKilled = Self.init(monsterType: .alamo, amount: 0, statType: .monstersKilled)
    static var batsKilled = Self.init(monsterType: .bat, amount: 0, statType: .monstersKilled)
    static var dragonsKilled = Self.init(monsterType: .dragon, amount: 0, statType: .monstersKilled)
    static var ratsKilled = Self.init(monsterType: .rat, amount: 0, statType: .monstersKilled)
    static var sallysKilled = Self.init(monsterType: .sally, amount: 0, statType: .monstersKilled)
    static var totalMonstersKilled = Self.init(amount: 0, statType: .totalMonstersKilled)
    static var monstersKilledInARow = Self.init(amount: 0, statType: .monstersKilledInARow)
    static var damageTaken = Self.init(amount: 0, statType: .damageTaken)
    static var healthHealed = Self.init(amount: 0, statType: .healthHealed)
    static var totalWins = Self.init(amount: 0, statType: .totalWins)
    static var totalLoses = Self.init(amount: 0, statType: .totalLoses)
    static var totalRuneUsesamount = Self.init(amount: 0, statType: .totalRuneUses)
    
    
    static var startingStats: [Statistics] {
        var nonRuneCases =
            [
                Statistics.blueRocksDestroyed,
                Statistics.redRocksDestroyed,
                Statistics.purpleRocksDestroyed,
                Statistics.totalRocksDestroyed100_000,
                Statistics.largestRockGroupDestroyed,
                Statistics.blueGemsCollected,
                Statistics.purpleGemsCollected,
                Statistics.redGemsCollected,
                Statistics.totalGemsCollected,
                Statistics.lowestDepthReached,
                Statistics.distanceFallen,
                Statistics.counterClockwiseRotations,
                Statistics.clockwiseRotations,
                Statistics.alamosKilled,
                Statistics.batsKilled,
                Statistics.dragonsKilled,
                Statistics.ratsKilled,
                Statistics.sallysKilled,
                Statistics.totalMonstersKilled,
                Statistics.monstersKilledInARow,
                Statistics.damageTaken,
                Statistics.healthHealed,
                Statistics.totalWins,
                Statistics.totalLoses,
                Statistics.totalRuneUsesamount
            ]
        
        let runeCases = RuneType.allCases.map { Statistics(runeType: $0, amount: 0, statType: .runeUses)}
        nonRuneCases.append(contentsOf: runeCases)
        return nonRuneCases
    }
}
