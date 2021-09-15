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
                newStat = stat.updateStatAmount(amount)
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
            let new = Unlockable(stat: unlockable.stat, item: unlockable.item, purchaseAmount: unlockable.purchaseAmount, isPurchased: unlockable.isPurchased, isUnlocked: isUnlocked(unlockableStat: unlockable.stat, playerStats: profile.stats))
            
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
    
    // ju
    func givePlayerARandomRune() {
        profileSubject.value.givePlayerARandomRune()
        saveProfile(profileSubject.value)
    }
    
    func finishRun(playerData updatedPlayerData: EntityModel, currentRun: RunModel) {
        /// update the profile to show
        /// the player's gems
        let currentRun: RunModel? = updatedPlayerData.isDead ? nil : currentRun
        /// update run
        let profileWithCurrentRun = profile.updateRunModel(currentRun)
        /// update player gem carry
        let playerUpdated = profileWithCurrentRun.player.updateCarry(carry: updatedPlayerData.carry).update(pickaxe: updatedPlayerData.pickaxe)
        
        /// update profile with new player
        let profileWithUpdatedPlayer = profileWithCurrentRun.updatePlayer(playerUpdated)
        
        //update profile with current depth
        saveProfile(profileWithUpdatedPlayer.updateDepth(currentRun?.depth ?? 0))
    }
}
