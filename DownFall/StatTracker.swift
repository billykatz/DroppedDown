//
//  StatTracker.swift
//  DownFall
//
//  Created by Billy on 9/16/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

class RunStatTracker {
    
    public var runStats: [Statistics]
    private let level: Level
    
    init(runStats: [Statistics], level: Level) {
        self.runStats = runStats
        self.level = level
        
        initializeStats()
        
        Dispatch.shared.register { [weak self] input in
            self?.handleInput(input: input)
        }
    }
    
    func initializeStats() {
        self.addStat(Statistics(amount: 0, statType: .totalRocksDestroyed), amount: 0)
        self.addStat(Statistics(amount: 0, statType: .largestRockGroupDestroyed), amount: 0)
        self.addStat(Statistics(amount: 0, statType: .totalGemsCollected), amount: 0)
        self.addStat(Statistics(amount: 0, statType: .totalMonstersKilled), amount: 0)
        self.addStat(Statistics(amount: 0, statType: .totalRuneUses), amount: 0)
        self.addStat(Statistics(amount: 0, statType: .damageTaken), amount: 0)
        self.addStat(Statistics(amount: 0, statType: .healthHealed), amount: 0)
    }
    
//    Statistics.distanceFallen,
//    Statistics.monstersKilledInARow,
    
    private func handleInput(input: Input) {
        switch input.type {
        case .rotateCounterClockwise(preview: false):
            self.addStat(Statistics(amount: 1, statType: .counterClockwiseRotations), amount: 1)
            
        case .rotateClockwise(preview: false):
            self.addStat(Statistics(amount: 1, statType: .clockwiseRotations), amount: 1)
            
        case .transformation(let trans):
            self.handleTransformation(trans)
            
        case .gameLose:
            self.addStat(Statistics(amount: 1, statType: .totalLoses), amount: 1)
            
        case .runeUsed(let rune, _):
            self.addStat(Statistics(amount: 1, statType: .totalRuneUses), amount: 1)
            self.addStat(Statistics(runeType: rune.type, amount: 1, statType: .runeUses), amount: 1)
            
        case .collectItem(_, let item, _):
            self.addStat(Statistics(amount: item.amount, statType: .totalGemsCollected), amount: item.amount)
            self.addStat(Statistics(gemColor: item.color, amount: item.amount, statType: .gemsCollected), amount: item.amount)
            
        case .collectOffer(_, let offer, _, _):
            if offer.type == .lesserHeal {
                self.addStat(Statistics(amount: 1, statType: .healthHealed), amount: offer.type.healAmount)
            } else if offer.type == .greaterHeal {
                self.addStat(Statistics(amount: 2, statType: .healthHealed), amount: offer.type.healAmount)
            } else if offer.type == .plusOneMaxHealth {
                self.addStat(Statistics(amount: 1, statType: .healthHealed), amount: 1)
            } else if offer.type == .plusTwoMaxHealth {
                self.addStat(Statistics(amount: 1, statType: .healthHealed), amount: 2)
            }
            
        case .gameWin:
            if level.isBossLevel {
                self.addStat(Statistics(amount: 1, statType: .totalWins), amount: 1)
            }
            
        default:
            break
        }
    }
    
    private func handleTransformation(_ transformation: [Transformation]) {
        guard let trans = transformation.first else { return }
        switch trans.inputType {
        case let .attack(_, _, _, _, dodged: dodged, attackerIsPlayer: attackerIsPlayer):
            if attackerIsPlayer {
                self.addStat(Statistics(amount: 1, statType: .damageDealt), amount: 1)
            } else {
                if dodged {
                    self.addStat(Statistics(amount: 1, statType: .attacksDodged), amount: 1)
                } else {
                    self.addStat(Statistics(amount: 1, statType: .damageTaken), amount: 1)
                }
            }
        case .touch(_, let type):
            guard case let TileType.rock(color: color, _, _) = type,
                  let removedCount = trans.removed?.count
                  else { return }
            self.addStat(Statistics(rockColor: color, amount: removedCount, statType: .rocksDestroyed), amount: removedCount)
            self.addStat(Statistics(amount: removedCount, statType: .totalRocksDestroyed), amount: removedCount)
            
            if removedCount > runStats.first(where: { $0.statType == .largestRockGroupDestroyed })?.amount ?? 0 {
                self.addStat(Statistics(amount: removedCount, statType: .largestRockGroupDestroyed), amount: removedCount)
            }
            
        default:
            break
            
        }
        
        for tran in transformation {
            if let monstersKilled = tran.monstersDies {
                for monstersKill in monstersKilled {
                    if case TileType.monster(let data) = monstersKill.tileType {
                        self.addStat(Statistics(amount: 1, statType: .totalMonstersKilled), amount: 1)
                        self.addStat(Statistics(monsterType: data.type, amount: 1, statType: .monstersKilled), amount: 1)
                    }
                }
            }
        }

    }
    
    private func addStat(_ stat: Statistics, amount: Int) {
        if let index = runStats.firstIndex(where: { $0 == stat } ) {
            runStats[index] = runStats[index].updateStatAmount(amount, overwrite: stat.statType.overwriteIfLarger)
        } else {
            runStats.append(stat)
        }
    }
}

