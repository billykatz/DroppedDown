//
//  ProfileModel.swift
//  DownFall
//
//  Created by Billy on 6/23/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

class Profile: Codable, Equatable {
    
    static func ==(_ lhs: Profile, _ rhs: Profile) -> Bool {
        return lhs.name == rhs.name
    }

    static var debugProfile = Profile(name: "debug", player: .lotsOfCash, currentRun: nil, stats: Statistics.startingStats, unlockables: Unlockable.debugUnlockables, startingUnlockbles: [])
    
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
        return unlockables.filter { $0.isPurchased }.count
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case player
        case currentRun
        case randomRune
        case stats
        case unlockables
        case startingUnlockables
        case bossWins

    }
    
    init(name: String, player: EntityModel, currentRun: RunModel?, stats: [Statistics], unlockables: [Unlockable], startingUnlockbles: [Unlockable]) {
        self.name = name
        self.player = player
        self.currentRun = currentRun
        self.stats = stats
        self.unlockables = unlockables
        self.startingUnlockbles = startingUnlockbles
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(player, forKey: .player)
        try container.encode(currentRun, forKey: .currentRun)
        try container.encode(randomRune, forKey: .randomRune)
        try container.encode(stats, forKey: .stats)
        try container.encode(unlockables, forKey: .unlockables)
        try container.encode(startingUnlockbles, forKey: .startingUnlockables)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        player = try container.decode(EntityModel.self, forKey: .player)
        currentRun = try? container.decode(RunModel.self, forKey: .currentRun)
        randomRune = try? container.decode(Rune.self, forKey: .randomRune)
        
        if let stats = try? container.decode([Statistics].self, forKey: .stats) {
            var updatedStates = Statistics.startingStats
            for stat in stats {
                if let index = updatedStates.firstIndex(of: stat) {
                    updatedStates[index] = stat
                }
            }
            self.stats = updatedStates
            
        } else {
            stats = Statistics.startingStats
        }
        
        if let unlockables = try? container.decode([Unlockable].self, forKey: .unlockables) {
            self.unlockables = unlockables
        } else {
            self.unlockables = Unlockable.unlockables()
        }
        
        if let startingUnlockbles = try? container.decode([Unlockable].self, forKey: .startingUnlockables) {
            self.startingUnlockbles = startingUnlockbles
        } else {
            self.startingUnlockbles = Unlockable.startingUnlockedUnlockables
        }
    }

    
    // TODO: apply the unlockables that affect the base player
    var runPlayer: EntityModel {
        let newPlayer = player.update(pickaxe: Pickaxe(runeSlots: 1, runes: []))
//        let newPlayer = player.update(pickaxe: Pickaxe(runeSlots: 2, runes: [Rune.rune(for: .fireball), Rune.rune(for: .vortex)]))
//        return applyUnlockables(to: newPlayer).revive()
        
        let testPlayer = applyUnlockables(to: newPlayer).revive()
//        guard let rune = randomRune else {
//            return testPlayer.update(pickaxe: Pickaxe(runeSlots: 1, runes: []))
//        }
        return testPlayer
    }
    
    //dont save this
    func applyUnlockables(to player: EntityModel) -> EntityModel {
        var newPlayer = player
        for unlockable in unlockables {
            if unlockable.applysToBasePlayer && unlockable.isUnlocked && unlockable.isPurchased {
                newPlayer = newPlayer.applyEffect(unlockable.item.effect)
            }
        }
        return newPlayer
    }
    
    func updatePlayer(_ entityModel: EntityModel) -> Profile {
        return Profile(name: name, player: entityModel, currentRun: currentRun, stats: stats, unlockables: unlockables, startingUnlockbles: startingUnlockbles)
    }
    
    func updateBossWins() -> Profile {
        return Profile(name: name, player: player, currentRun: currentRun, stats: stats, unlockables: unlockables, startingUnlockbles: startingUnlockbles)
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
        else {
            print("couln't find stat \(stat.debugDescription())")
            return self
        }
        
        var newStats = stats
        newStats[statIndex] = newStats[statIndex].updateStatAmount(amount, overwrite: overwriteIfLarger)
        
        return Profile(name: name, player: player, currentRun: currentRun, stats: newStats, unlockables: unlockables, startingUnlockbles: startingUnlockbles)
    }
    
    func firstStat(_ stat: Statistics) -> Statistics? {
        return stats.first(where: { playerStat in
            playerStat.statType == stat.statType
            && playerStat.rockColor == stat.rockColor
            && playerStat.gemColor == stat.gemColor
            && playerStat.runeType == stat.runeType
            && playerStat.monsterType == stat.monsterType
            
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
    
    func updateAllUnlockables(_ newUnlockables: [Unlockable], startingUnlockables: [Unlockable]? = nil) -> Profile {
        let newStartingUnlockables = startingUnlockables ?? startingUnlockbles
        return Profile(name: name, player: player, currentRun: currentRun, stats: stats, unlockables: newUnlockables, startingUnlockbles: newStartingUnlockables)
        
    }
    
    func didTapOnUnlockable(_ unlockable: Unlockable) -> Profile {
        guard let index = unlockables.firstIndex(of: unlockable) else { preconditionFailure("Unlockable must be in the array") }
        var newUnlockables = unlockables
        newUnlockables[index] = unlockable.didTapOn()
        
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
    public func givePlayerARandomRune() {
        let runeType = RuneType.allCases.randomElement()!
        randomRune = Rune.rune(for: runeType)
    }
    
    
    public func updateUnlockables() -> Profile {
        var newUnlockables = Unlockable.unlockables()
        for oldUnlockable in unlockables {
            if let index = newUnlockables.firstIndex(of: oldUnlockable) {
                print(newUnlockables[index].id)
                let newUnlockable = newUnlockables[index]
                let updatedUnlockable = oldUnlockable.update(stat: newUnlockable.stat,
                                                             item: newUnlockable.item,
                                                             purchaseAmount: newUnlockable.purchaseAmount,
                                                             isPurchased: oldUnlockable.isPurchased,
                                                             isUnlocked: oldUnlockable.isUnlocked,
                                                             applysToBasePlayer: newUnlockable.applysToBasePlayer,
                                                             recentlyPurchasedAndHasntSpawnedYet: oldUnlockable.recentlyPurchasedAndHasntSpawnedYet,
                                                             hasBeenTappedOnByPlayer: oldUnlockable.hasBeenTappedOnByPlayer)
                newUnlockables[index] = updatedUnlockable
                
            }
        }
        
#if DEBUG
        /// print this shit so we can debug
        print("---------UNLOCKABLES--------")
        print("---------START--------")
        print(newUnlockables.count)
        var count = 1
        newUnlockables.forEach { updatedUnlockable in
            print(count)
            count += 1
            updatedUnlockable.debugDescription()
        }
        print("---------END--------")
#endif
        let newStartingUnlockable = Unlockable.startingUnlockedUnlockables
        
        return self.updateAllUnlockables(newUnlockables, startingUnlockables: newStartingUnlockable)
    }
    
    public func updateUnlockablesHasSpawn(offers: [StoreOffer]) -> Profile {
        var newUnlockables: [Unlockable] = []
        for unlockable in self.unlockables {
            var newUnlock = unlockable
            if offers.contains(unlockable.item) {
                newUnlock.recentlyPurchasedAndHasntSpawnedYet = false
            }
            newUnlockables.append(newUnlock)
        }
        
        return self.updateAllUnlockables(newUnlockables)
    }
}
