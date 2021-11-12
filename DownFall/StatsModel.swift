//
//  StatsModel.swift
//  DownFall
//
//  Created by Billy on 9/8/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import UIKit

enum StatisticType: String, Codable {
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
    case damageDealt
    case attacksDodged
    
    // win/lose
    case totalWins
    case totalLoses
    
    // runes
    case runeUses
    case totalRuneUses
    
    var overwriteIfLarger: Bool {
        switch self {
        case .largestRockGroupDestroyed, .monstersKilledInARow, .lowestDepthReached:
            return true
        default:
            return false
        }
    }
}

struct Statistics: Codable, Equatable, Identifiable {
    let rockColor: ShiftShaft_Color?
    let gemColor: ShiftShaft_Color?
    let monsterType: EntityModel.EntityType?
    let runeType: RuneType?
    let amount: Int
    let statType: StatisticType
    let id: UUID
     
    init(rockColor: ShiftShaft_Color? = nil, gemColor: ShiftShaft_Color? = nil, monsterType: EntityModel.EntityType? = nil, runeType: RuneType? = nil, amount: Int, statType: StatisticType) {
        self.rockColor = rockColor
        self.gemColor = gemColor
        self.monsterType = monsterType
        self.runeType = runeType
        self.amount = amount
        self.statType = statType
        self.id = UUID()
    }
    
    func updateStatAmount(_ amount: Int, overwrite: Bool) -> Statistics {
        let newAmount = overwrite ? amount : self.amount + amount
        return Self.init(rockColor: self.rockColor, gemColor: self.gemColor, monsterType: self.monsterType, runeType: self.runeType, amount: newAmount, statType: self.statType)
    }
    
    func overwriteStatAmount(_ amount: Int) -> Statistics {
        return Self.init(rockColor: self.rockColor, gemColor: self.gemColor, monsterType: self.monsterType, runeType: self.runeType, amount: amount, statType: self.statType)
    }
    
    var color: UIColor {
        return .lightBarBlue
    }
    
    var textureName: String {
        switch statType {
        case .rocksDestroyed where rockColor == .blue:
            return "blueRock"
        case .rocksDestroyed where rockColor == .purple:
            return "purpleRock"
        case .rocksDestroyed where rockColor == .red:
            return "redRock"
        case .totalRocksDestroyed, .largestRockGroupDestroyed, .rocksDestroyed:
            return "allRocks"
        case .monstersKilled where monsterType == .alamo:
            return "alamo"
        case .monstersKilled where monsterType == .bat:
            return "bat"
        case .monstersKilled where monsterType == .dragon:
            return "dragon"
        case .monstersKilled where monsterType == .rat:
            return "rat"
        case .monstersKilled where monsterType == .sally:
            return "sally"
        case .totalMonstersKilled, .monstersKilled, .monstersKilledInARow, .totalLoses:
            return "skullAndCrossbones"
        case .runeUses, .totalRuneUses:
            return  "blankRune"
        case .lowestDepthReached, .distanceFallen:
            return "mineshaft"
        case .gemsCollected where gemColor == .red:
            return "redCrystal"
        case .gemsCollected where gemColor == .blue:
            return "blueCrystal"
        case .gemsCollected where gemColor == .purple:
            return "purpleCrystal"
        case .totalGemsCollected, .gemsCollected:
            return "crystals"
        case .counterClockwiseRotations:
            return "rotateLeft"
        case .clockwiseRotations:
            return "rotateRight"
        case .damageTaken, .healthHealed, .damageDealt:
            return "fullHeart"
        case .attacksDodged:
            return "dodge"
        case .totalWins:
            return "buttonAffirmitive"
        }
        
            
    }
}

extension Statistics {
    /// base cases
    static var blueRocksDestroyed = Self.init(rockColor: .blue, amount: 0, statType: .rocksDestroyed)
    static var redRocksDestroyed = Self.init(rockColor: .red, amount: 0, statType: .rocksDestroyed)
    static var purpleRocksDestroyed = Self.init(rockColor: .purple, amount: 0, statType: .rocksDestroyed)
    static var totalRocksDestroyed = Self.init(amount: 0, statType: .totalRocksDestroyed)
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
    static var damageDealt = Self.init(amount: 0, statType: .damageDealt)
    static var attacksDodged = Self.init(amount: 0, statType: .attacksDodged)
    static var totalWins = Self.init(amount: 0, statType: .totalWins)
    static var totalLoses = Self.init(amount: 0, statType: .totalLoses)
    static var totalRuneUsesamount = Self.init(amount: 0, statType: .totalRuneUses)
    
    
    static var startingStats: [Statistics] {
        var nonRuneCases =
            [
                Statistics.blueRocksDestroyed,
                Statistics.redRocksDestroyed,
                Statistics.purpleRocksDestroyed,
                Statistics.totalRocksDestroyed,
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
                Statistics.totalLoses,
                Statistics.totalRuneUsesamount
            ]
        
        let runeCases = RuneType.allCases.map { Statistics(runeType: $0, amount: 0, statType: .runeUses)}
        nonRuneCases.append(contentsOf: runeCases)
        return nonRuneCases
    }
}


extension Statistics {
    
    // rocks mined
    static var fiveRocks = Self.init(amount: 5, statType: .totalRocksDestroyed)
    static var fiftyRocks = Self.init(amount: 50, statType: .totalRocksDestroyed)
    static var oneHundredRocks = Self.init(amount: 100, statType: .totalRocksDestroyed)
    static var fiveHundredRocks = Self.init(amount: 500, statType: .totalRocksDestroyed)
    static var oneThousandRocks = Self.init(amount: 1000, statType: .totalRocksDestroyed)
    static var twoThousandRocks = Self.init(amount: 2000, statType: .totalRocksDestroyed)
    static var fiveThousandRocks = Self.init(amount: 5000, statType: .totalRocksDestroyed)
    static var tenThousandRocks = Self.init(amount: 10000, statType: .totalRocksDestroyed)
    static var twentyThousandRocks = Self.init(amount: 20000, statType: .totalRocksDestroyed)
    
    static var oneThousandBlueRocks = Self.init(rockColor: .blue, amount: 1000, statType: .rocksDestroyed)
    static var oneThousandRedRocks = Self.init(rockColor: .red, amount: 1000, statType: .rocksDestroyed)
    static var twoThousandRedRocks = Self.init(rockColor: .red, amount: 2000, statType: .rocksDestroyed)
    static var threeThousandRedRocks = Self.init(rockColor: .red, amount: 3000, statType: .rocksDestroyed)
    static var oneThousandPurpleRocks = Self.init(rockColor: .purple, amount: 1000, statType: .rocksDestroyed)
    
//    static var blueRocks100Mined = Self.init(rockColor: .blue, amount: 100, statType: .rocksDestroyed)
//    static var redRocks123Mined = Self.init(rockColor: .red, amount: 123, statType: .rocksDestroyed)
//    static var purpleRocks501Mined = Self.init(rockColor: .purple, amount: 501, statType: .rocksDestroyed)
    
    // monsters killed
    static var dragonKilled10 = Self.init(monsterType: .dragon, amount: 10, statType: .monstersKilled)
    static var alamoKilled10 = Self.init(monsterType: .alamo, amount: 10, statType: .monstersKilled)
    static var sallyKilled10 = Self.init(monsterType: .sally, amount: 10, statType: .monstersKilled)
    static var batKilled10 = Self.init(monsterType: .bat, amount: 10, statType: .monstersKilled)
    static var ratKilled10 = Self.init(monsterType: .rat, amount: 10, statType: .monstersKilled)
    
    static var monstersKilled100 = Self.init(amount: 100, statType: .totalMonstersKilled)
    
    // runes
    static var flameColumnUsed100 = Self.init(runeType: .flameColumn, amount: 100, statType: .runeUses)
    static var bubbleUpUsed10 = Self.init(runeType: .bubbleUp, amount: 10, statType: .runeUses)
    static var allRunesUses100 = Self.init(amount: 100, statType: .totalRuneUses)
    static var allRunesUses50 = Self.init(amount: 50, statType: .totalRuneUses)
    
    // gem cases
    static var blueGems100Collected = Self.init(gemColor: .blue, amount: 100, statType: .gemsCollected)
    static var purpleGems100Collected = Self.init(gemColor: .purple, amount: 100, statType: .gemsCollected)
    static var redGems100Collected = Self.init(gemColor: .red, amount: 100, statType: .gemsCollected)
    static var purpleGems501Collected = Self.init(gemColor: .purple, amount: 501, statType: .gemsCollected)
    static var oneHundredGems = Self.init(amount: 100, statType: .totalGemsCollected)
    static var twoHundredGems = Self.init(amount: 200, statType: .totalGemsCollected)
    static var fiveHundredGems = Self.init(amount: 500, statType: .totalGemsCollected)

    
    // reach depth
    static let reachDepth5 = Self.init(amount: 5, statType: .lowestDepthReached)
    static let reachDepth8 = Self.init(amount: 8, statType: .lowestDepthReached)
    static let reachDepth10 = Self.init(amount: 10, statType: .lowestDepthReached)
    
    // largest group
    static let largestGroup40 = Self.init(amount: 40, statType: .largestRockGroupDestroyed)
}
