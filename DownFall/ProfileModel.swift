//
//  ProfileModel.swift
//  DownFall
//
//  Created by Billy on 6/23/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation


struct Profile: Codable, Equatable {
    static var debugProfile = Profile(name: "debug", progress: 0, player: .lotsOfCash, currentRun: nil, deepestDepth: 0, stats: Statistics.startingStats, unlockables: Unlockable.startingUnlockables)
    
    static var zero = Profile(name: "zero", progress: 0, player: .zero, currentRun: nil, deepestDepth: 0, stats: [], unlockables: [])
    
    let name: String
    let progress: Int
    let player: EntityModel
    var currentRun: RunModel?
    var randomRune: Rune?
    let deepestDepth: Int
    let stats: [Statistics]
    let unlockables: [Unlockable]
    
    var runPlayer: EntityModel {
        guard let rune = randomRune else {
            return player.update(pickaxe: Pickaxe(runeSlots: 1, runes: []))
        }
        return player.update(pickaxe: Pickaxe(runeSlots: 1, runes: [rune]))
    }
    
    func updatePlayer(_ entityModel: EntityModel) -> Profile {
        return Profile(name: name, progress: progress + 1, player: entityModel, currentRun: currentRun, deepestDepth: deepestDepth, stats: stats, unlockables: unlockables)
    }
    
    func updateRunModel(_ currentRun: RunModel?) -> Profile {
        return Profile(name: name, progress: progress + 1, player: player, currentRun: currentRun, deepestDepth: deepestDepth, stats: stats, unlockables: unlockables)
    }
    
    func updateDepth(_ depth: Int) -> Profile {
        let newDepth = depth > deepestDepth ? depth : deepestDepth
        return Profile(name: name, progress: progress + 1, player: player, currentRun: currentRun, deepestDepth: newDepth, stats: stats, unlockables: unlockables)
    }
    
    func updateStatistics(_ newStats: [Statistics]) -> Profile {
        return Profile(name: name, progress: progress, player: player, currentRun: currentRun, deepestDepth: deepestDepth, stats: newStats, unlockables: unlockables)
    }
    
    func updateStatistic(_ stat: Statistics, amount: Int, overwriteIfLarger: Bool = false) -> Profile {
        guard (!overwriteIfLarger || (overwriteIfLarger && amount > firstStat(stat)?.amount ?? 0)),
              let statIndex = firstIndexStat(stat)
        else { return self }
        
        var newStats = stats
        newStats[statIndex] = newStats[statIndex].updateStatAmount(amount, overwrite: overwriteIfLarger)
        
        return Profile(name: name, progress: progress, player: player, currentRun: currentRun, deepestDepth: deepestDepth, stats: newStats, unlockables: unlockables)
    }
    
    func firstStat(_ stat: Statistics) -> Statistics? {
        return stats.first(where: { playerStat in
            playerStat.statType == stat.statType &&
                playerStat.rockColor == stat.rockColor &&
                playerStat.gemColor == stat.gemColor &&
                playerStat.runeType == stat.runeType &&
                playerStat.monsterType == stat.monsterType
            
        })

    }
    
    func firstIndexStat(_ stat: Statistics) -> Int? {
        return stats.firstIndex(where: { playerStat in
            playerStat.statType == stat.statType &&
                playerStat.rockColor == stat.rockColor &&
                playerStat.gemColor == stat.gemColor &&
                playerStat.runeType == stat.runeType &&
                playerStat.monsterType == stat.monsterType
            
        })
    }
    
    func updateAllUnlockables(_ newUnlockables: [Unlockable]) -> Profile {
        return Profile(name: name, progress: progress, player: player, currentRun: currentRun, deepestDepth: deepestDepth, stats: stats, unlockables: newUnlockables)
        
    }
    
    func updateUnlockables(_ newUnlockable: Unlockable) -> Profile {
        guard let index = unlockables.firstIndex(of: newUnlockable) else { preconditionFailure("Unlockable must be in the array") }
        let newPlayer = player.spend(amount: newUnlockable.purchaseAmount)
        var newUnlockables = unlockables
        newUnlockables[index] = newUnlockable.purchase()
        
        return Profile(name: name, progress: progress, player: newPlayer, currentRun: currentRun, deepestDepth: deepestDepth, stats: stats, unlockables: newUnlockables)
        
    }
    
    // just for debug purposes
    public mutating func givePlayerARandomRune() {
        let runeType = RuneType.allCases.randomElement()!
        randomRune = Rune.rune(for: runeType)
    }
    
}
