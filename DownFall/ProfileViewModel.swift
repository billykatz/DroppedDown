//
//  ProfileViewModel.swift
//  DownFall
//
//  Created by Billy on 9/13/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import Combine

// This class is meant to interact with the Profile model
// It is also responsible for making sure we save the Profile after every major update.
class ProfileViewModel {
//    let profileLoadingManger: ProfileLoadingManager
    lazy var profilePublisher: AnyPublisher<Profile, Never> = profileSubject.eraseToAnyPublisher()
    private lazy var profileSubject = CurrentValueSubject<Profile, Never>(.zero)
    
    private var cancellables = Set<AnyCancellable>()
    
    var profile: Profile {
        profileSubject.value
    }
    
    var gemAmount: Int {
        return profile.player.carry.total(in: .gem)
    }
    
    init(profile: Profile) {
        profileSubject.send(profile)
        
        GameScope
            .shared
            .profileManager
            .loadedProfile
            .sink(receiveCompletion: { _ in }) { [weak self] (profile) in
                guard let profile = profile else { return }
                self?.profileSubject.send(profile)
            }.store(in: &cancellables)
    }
    
    func saveProfile(_ profile: Profile) {
        GameScope.shared.profileManager.saveProfile(profile)
    }
    
    func updateStat(amount: Int, stat: Statistics) {
        var newStatistics: [Statistics] = []
        for playerStat in profile.stats {
            var newStat = playerStat
            if (stat == playerStat) {
                newStat = stat.updateStatAmount(amount, overwrite: stat.statType.overwriteIfLarger)
            }
            
            newStatistics.append(newStat)
        }
        
        let newProfile = profile.updateStatistics(newStatistics)
        profileSubject.send(newProfile)
//        saveProfile(newProfile)
        
//        checkUnlockables()
    }
    
    func updateGems(amount: Int) {
        let newProfile = profile.updatePlayer(profile.player.earn(amount: amount))
        profileSubject.send(newProfile)
    }
    
    func isUnlocked(unlockableStat: Statistics, playerStats: [Statistics]) -> Bool {
        for stat in playerStats {
            if stat.statType == unlockableStat.statType
                && stat.rockColor == unlockableStat.rockColor
                && stat.gemColor == unlockableStat.gemColor
                && stat.monsterType == unlockableStat.monsterType
                && stat.runeType == unlockableStat.runeType {
                
                return stat.amount >= unlockableStat.amount
                
            }
        }
        return false
    }

    
    func checkUnlockables() {
        var newUnlockables : [Unlockable] = []
        for unlockable in profile.unlockables {
            let new = Unlockable(stat: unlockable.stat, item: unlockable.item, purchaseAmount: unlockable.purchaseAmount, isPurchased: unlockable.isPurchased, isUnlocked: isUnlocked(unlockableStat: unlockable.stat, playerStats: profile.stats), applysToBasePlayer: unlockable.applysToBasePlayer)
            
            newUnlockables.append(new)
        }

        saveProfile(profile.updateAllUnlockables(newUnlockables))
    }
    
    
    func updateUnlockables(_ unlockable: Unlockable) {
        saveProfile(profile.updateUnlockables(unlockable))
    }
    
    func updatePlayerData(_ updatedPlayerData: EntityModel) {
        saveProfile(profile.updatePlayer(updatedPlayerData))
    }
    
    func nilCurrenRun() {
        profileSubject.value.currentRun = nil
    }
    
    func deletePlayerData() {
        GameScope.shared.profileManager.deleteLocalProfile()
        GameScope.shared.profileManager.deleteAllRemoteProfile()
        GameScope.shared.profileManager.resetUserDefaults()
    }
    
    // just for debugging purposes
    func givePlayerARandomRune() {
        profileSubject.value.givePlayerARandomRune()
        saveProfile(profileSubject.value)
    }
    
    func playerHasPurchasableUnlockables() -> Bool {
        for unlockable in profile.unlockables {
            if unlockable.isUnlocked && !unlockable.isPurchased {
                if profile.player.canAfford(unlockable.purchaseAmount, inCurrency: .gem) {
                    return true
                }
            }
        }
        return false
    }
    
    func finishRun(playerData updatedPlayerData: EntityModel, currentRun: RunModel) {
        /// update the player
        var newPlayerData = updatedPlayerData.update(pickaxe: Pickaxe(runeSlots: 1, runes: []))
        
        /// update player gem carry
        newPlayerData = newPlayerData.updateCarry(carry: updatedPlayerData.carry)

        // reset to base stat of 3 hp
        newPlayerData = newPlayerData.update(originalHp: 3, dodge: 0, luck: 0)
        
        // revive
        newPlayerData = newPlayerData.revive()
        
        
        /// Update Profile
        /// update profile with new player
        var newProfile = profile.updatePlayer(newPlayerData)
        
        // update stats
        for stat in currentRun.stats {
            let overwrite = stat.statType.overwriteIfLarger
            newProfile = newProfile.updateStatistic(stat, amount: stat.amount, overwriteIfLarger: overwrite)
        }
        
        /// update run
        newProfile = newProfile.updateRunModel(updatedPlayerData.isDead ? nil : currentRun)
        
        // update lowest depth if needed
        newProfile = newProfile.updateStatistic(.lowestDepthReached, amount: currentRun.depth, overwriteIfLarger: true)
        
        // save profile
        saveProfile(newProfile)
    }
}
