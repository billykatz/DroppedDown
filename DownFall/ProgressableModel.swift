//
//  CodexViewModel.swift
//  DownFall
//
//  Created by Billy on 9/3/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import Combine


/*
 There are a few different types of items in the game:
   - permanent upgrades: these are things like upgrades to health, dodge, and luck, extra rune slots, and the ability to unlock a 3rd goal
     - health upgrade, level 1-4
     - dodge upgrade, level 1-4
     - luck upgrade, level 1-4
     - runes slots, level 1-4
     - unlock a 3rd level goal
   - one-time use potions: these are things like the transmogrify.  they can appear in levels
     - each item can be unlcok
   - runes: some runes are in the starting game pool but others can be unlocked and purchased so they appear in future runs
 
 Items introduced into the game need to be represented in multiple UIs:
   - In the Progress view
   - Some need to  the game view
 
 Items can be in multiple states:
    - locked or unlocked
    - not purchased or purchased
 
 In the progress view players can:
    - view unlocked items
    - view locked items
    - buy unlocked items

 */

class CodexViewModel: ObservableObject {
    
    @Published var unlockables: [Unlockable] = []
    @Published var gemAmount: Int = 0
    
    private let profileViewModel: ProfileViewModel
    private let profile: Profile
    private let profilePublisher: AnyPublisher<Profile, Never>
    private var profileCancellable = Set<AnyCancellable>()
    private weak var codexCoordinator: CodexCoordinator?
    
    private var playerData: EntityModel {
        return profile.player
    }
    private var statData: [Statistics] {
        return profile.stats
    }

    init(profileViewModel: ProfileViewModel, codexCoordinator: CodexCoordinator) {
        self.profileViewModel = profileViewModel
        self.profile = profileViewModel.profile
        self.unlockables = profile.unlockables
        self.codexCoordinator = codexCoordinator
        self.profilePublisher = profileViewModel.profilePublisher
        
        profilePublisher.sink { [weak self] newProfile in
            self?.unlockables = newProfile.unlockables
            self?.gemAmount = newProfile.player.carry.total(in: .gem)
        }.store(in: &profileCancellable)
        
        var newUnlockable : [Unlockable] = []
        for unlockable in unlockables {
            let new = Unlockable(stat: unlockable.stat, item: unlockable.item, purchaseAmount: unlockable.purchaseAmount, isPurchased: unlockable.isPurchased, isUnlocked: isUnlocked(unlockableStat: unlockable.stat, playerStats: statData))
            newUnlockable.append(new)
        }

        self.unlockables = newUnlockable
    }
    
    func isUnlocked(unlockableStat: Statistics, playerStats: [Statistics]) -> Bool {
        for stat in playerStats {
            if unlockableStat.statType == stat.statType {
                switch unlockableStat.statType {
                case .rocksDestroyed:
                    return unlockableStat.rockColor == stat.rockColor && stat.amount >= unlockableStat.amount
                case .gemsCollected:
                    return unlockableStat.gemColor == stat.gemColor && stat.amount >= unlockableStat.amount
                case .monstersKilled:
                    return unlockableStat.monsterType == stat.monsterType && stat.amount >= unlockableStat.amount
                case .runeUses:
                    return unlockableStat.runeType == stat.runeType && stat.amount >= unlockableStat.amount
                default:
                    return stat.amount >= unlockableStat.amount
                }
            }
        }
        return false
    }
    
    
    //API
    func purchaseUnlockable(unlockable: Unlockable) {
        guard let index = unlockables.firstIndex(of: unlockable) else { preconditionFailure("Unlockable must be in the array") }
        unlockables[index] = unlockable.purchase()
        codexCoordinator?.updateUnlockable(unlockables)
    }
    
    func playerCanAfford(unlockable: Unlockable) -> Bool {
        return playerData.canAfford(unlockable.purchaseAmount, inCurrency: .gem)
    }
    
    
}
