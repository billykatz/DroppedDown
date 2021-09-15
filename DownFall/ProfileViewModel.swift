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
    
    lazy var profilePublisher: AnyPublisher<Profile, Never> = profileSubject.eraseToAnyPublisher()
    private lazy var profileSubject = CurrentValueSubject<Profile, Never>(.zero)
    
    var profile: Profile {
        profileSubject.value
    }
    
    init(profile: Profile) {
        profileSubject.send(profile)
    }
    
    func saveProfile(_ profile: Profile) {
        GameScope.shared.profileManager.saveProfile(profile)
        profileSubject.send(profile)
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
