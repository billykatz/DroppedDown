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

    static var debugProfile = Profile(name: "debug", player: .lotsOfCash, currentRun: nil, stats: Statistics.startingStats, unlockables: Unlockable.debugUnlockables, startingUnlockbles: [], pastRunSeeds: [])
    
    static var zero = Profile(name: "zero", player: .zero, currentRun: nil, stats: [], unlockables: [], startingUnlockbles: [], pastRunSeeds: [])
    
    let name: String
    let player: EntityModel
    var currentRun: RunModel?
    var randomRune: Rune?
    let stats: [Statistics]
    let unlockables: [Unlockable]
    let startingUnlockbles: [Unlockable]
    var pastRunSeeds: [UInt64]
    
    
    /// for now this is just the number of unlockables unlocked
    var progress: Int {
        return unlockables.filter { $0.isPurchased }.count
    }
    
    var secondaryProgress: Int {
        return pastRunSeeds.count
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
        case pastRunSeeds

    }
    
    init(name: String, player: EntityModel, currentRun: RunModel?, stats: [Statistics], unlockables: [Unlockable], startingUnlockbles: [Unlockable], pastRunSeeds: [UInt64]) {
        self.name = name
        self.player = player
        self.currentRun = currentRun
        self.stats = stats
        self.unlockables = unlockables
        self.startingUnlockbles = startingUnlockbles
        self.pastRunSeeds = pastRunSeeds
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
        try container.encode(pastRunSeeds, forKey: .pastRunSeeds)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        player = try container.decode(EntityModel.self, forKey: .player)
        currentRun = try? container.decode(RunModel.self, forKey: .currentRun)
        randomRune = try? container.decode(Rune.self, forKey: .randomRune)
        pastRunSeeds = (try? container.decode([UInt64].self, forKey: .pastRunSeeds)) ?? []
        
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
            if unlockable.applysToBasePlayer && unlockable.isPurchased {
                newPlayer = newPlayer.applyEffect(unlockable.item.effect)
            }
        }
        return newPlayer
    }
    
    func updatePlayer(_ entityModel: EntityModel) -> Profile {
        return Profile(name: name, player: entityModel, currentRun: currentRun, stats: stats, unlockables: unlockables, startingUnlockbles: startingUnlockbles, pastRunSeeds: pastRunSeeds)
    }
    
    func updateBossWins() -> Profile {
        return Profile(name: name, player: player, currentRun: currentRun, stats: stats, unlockables: unlockables, startingUnlockbles: startingUnlockbles, pastRunSeeds: pastRunSeeds)
    }
    
    func updatePastRunSeeds(_ seed: UInt64) -> Profile {
        var newSeeds = pastRunSeeds
        if !pastRunSeeds.contains(seed) {
            newSeeds.append(seed)
        }
        return Profile(name: name, player: player, currentRun: currentRun, stats: stats, unlockables: unlockables, startingUnlockbles: startingUnlockbles, pastRunSeeds: newSeeds)
    }
    

    
    func updateRunModel(_ currentRun: RunModel?) -> Profile {
        return Profile(name: name, player: player, currentRun: currentRun, stats: stats, unlockables: unlockables, startingUnlockbles: startingUnlockbles, pastRunSeeds: pastRunSeeds)
    }
    
    
    func updateStatistics(_ newStats: [Statistics]) -> Profile {
        return Profile(name: name, player: player, currentRun: currentRun, stats: newStats, unlockables: unlockables, startingUnlockbles: startingUnlockbles, pastRunSeeds: pastRunSeeds)
    }
    
    func updateStatistic(_ stat: Statistics, amount: Int, overwriteIfLarger: Bool = false) -> Profile {
        guard (!overwriteIfLarger || (overwriteIfLarger && amount > firstStat(stat)?.amount ?? 0)),
              let statIndex = firstIndexStat(stat)
        else {
            print("couln't find stat \(stat.debugDescription())")
            return self
        }
        
        var newStats = stats
#if DEBUG
        print("+++++++++++++++++++++")
        print("Stat before \(newStats[statIndex].debugDescription())")
        print("Updating with: \(stat.debugDescription())")
#endif
        newStats[statIndex] = newStats[statIndex].updateStatAmount(amount, overwrite: overwriteIfLarger)
#if DEBUG
        print("State after \(newStats[statIndex].debugDescription())")
        print("+++++++++++++++++++++")
#endif
        return Profile(name: name, player: player, currentRun: currentRun, stats: newStats, unlockables: unlockables, startingUnlockbles: startingUnlockbles, pastRunSeeds: pastRunSeeds)
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
        return Profile(name: name, player: player, currentRun: currentRun, stats: stats, unlockables: newUnlockables, startingUnlockbles: newStartingUnlockables, pastRunSeeds: pastRunSeeds)
        
    }
    
    func didTapOnUnlockable(_ unlockable: Unlockable) -> Profile {
        guard let index = unlockables.firstIndex(of: unlockable) else {
            return self
        }
        var newUnlockables = unlockables
        newUnlockables[index] = unlockable.didTapOn()
        
        return Profile(name: name, player: player, currentRun: currentRun, stats: stats, unlockables: newUnlockables, startingUnlockbles: startingUnlockbles, pastRunSeeds: pastRunSeeds)
        
    }

    
    func updateUnlockables(_ newUnlockable: Unlockable) -> Profile {
        guard let index = unlockables.firstIndex(of: newUnlockable) else {
            return self
        }
        let newPlayer = player.spend(amount: newUnlockable.purchaseAmount)
        var newUnlockables = unlockables
        newUnlockables[index] = newUnlockable.purchase()
        
        return Profile(name: name, player: newPlayer, currentRun: currentRun, stats: stats, unlockables: newUnlockables, startingUnlockbles: startingUnlockbles, pastRunSeeds: pastRunSeeds)
        
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
//                print(newUnlockables[index].id)
                print("---------Unlockable will be carried over--------")
                print(oldUnlockable.item.textureName)
                print("\tisPurchased: \(oldUnlockable.isPurchased)")
                print("\tisUnlocked: \(oldUnlockable.isUnlocked)")
                print("\trecently: \(oldUnlockable.recentlyPurchasedAndHasntSpawnedYet)")
                print("\thasBeenTappedOnByPlayer \(oldUnlockable.hasBeenTappedOnByPlayer)")
                print("Is present and will be updated ")
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
                
            } else {
                print("---------Delete unlockable--------")
                print(oldUnlockable.item.textureName)
                print("is not present in the new unlockables... deleting it ")
            }
        }
        
//#if DEBUG
//        / print this shit so we can debug
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
//#endif
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
