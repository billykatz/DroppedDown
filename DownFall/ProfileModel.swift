//
//  ProfileModel.swift
//  DownFall
//
//  Created by Billy on 6/23/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation


struct Profile: Codable, Equatable {
    static var debugProfile = Profile(name: "debug", player: .lotsOfCash, currentRun: nil, stats: Statistics.startingStats, unlockables: Unlockable.unlockables, startingUnlockbles: [])
    
    static var zero = Profile(name: "zero", player: .zero, currentRun: nil, stats: [], unlockables: [], startingUnlockbles: [])
    
    let name: String
    let player: EntityModel
    var currentRun: RunModel?
    var randomRune: Rune?
    let stats: [Statistics]
    let unlockables: [Unlockable]
    
    let startingUnlockbles: [Unlockable]
    
    
    /// for now this is just the number of unlockables unlocked
    var progress: Int {
        return unlockables.filter { $0.isUnlocked }.count
    }
    
//    enum CodingKeys: String, CodingKey {
//        case name
//        case progress
//        case player
//        case currentRun
//        case randomRune
//        case deepestDepth
//        case stats: [Stat]
//
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let name = container.deco
//    }
//
    
    // TODO: apply the unlockables that affect the base player
    var runPlayer: EntityModel {
        guard let rune = randomRune else {
            return player.update(pickaxe: Pickaxe(runeSlots: 1, runes: []))
        }
        return player.update(pickaxe: Pickaxe(runeSlots: 1, runes: [rune]))
    }
    
    func updatePlayer(_ entityModel: EntityModel) -> Profile {
        return Profile(name: name, player: entityModel, currentRun: currentRun, stats: stats, unlockables: unlockables, startingUnlockbles: startingUnlockbles)
    }
    
    func updateRunModel(_ currentRun: RunModel?) -> Profile {
        return Profile(name: name, player: player, currentRun: currentRun, stats: stats, unlockables: unlockables, startingUnlockbles: startingUnlockbles)
    }
    
    
    func updateStatistics(_ newStats: [Statistics]) -> Profile {
        return Profile(name: name, player: player, currentRun: currentRun, stats: newStats, unlockables: unlockables, startingUnlockbles: startingUnlockbles)
    }
    
    func updateStatistic(_ stat: Statistics, amount: Int, overwriteIfLarger: Bool = false) -> Profile {
        guard (!overwriteIfLarger || (overwriteIfLarger && amount > firstStat(stat)?.amount ?? 0)),
              let statIndex = firstIndexStat(stat)
        else { return self }
        
        var newStats = stats
        newStats[statIndex] = newStats[statIndex].updateStatAmount(amount, overwrite: overwriteIfLarger)
        
        return Profile(name: name, player: player, currentRun: currentRun, stats: newStats, unlockables: unlockables, startingUnlockbles: startingUnlockbles)
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
        return Profile(name: name, player: player, currentRun: currentRun, stats: stats, unlockables: newUnlockables, startingUnlockbles: startingUnlockbles)
        
    }
    
    func updateUnlockables(_ newUnlockable: Unlockable) -> Profile {
        guard let index = unlockables.firstIndex(of: newUnlockable) else { preconditionFailure("Unlockable must be in the array") }
        let newPlayer = player.spend(amount: newUnlockable.purchaseAmount)
        var newUnlockables = unlockables
        newUnlockables[index] = newUnlockable.purchase()
        
        return Profile(name: name, player: newPlayer, currentRun: currentRun, stats: stats, unlockables: newUnlockables, startingUnlockbles: startingUnlockbles)
        
    }
    
    // just for debug purposes
    public mutating func givePlayerARandomRune() {
        let runeType = RuneType.allCases.randomElement()!
        randomRune = Rune.rune(for: runeType)
    }
    
}
