//
//  StoreHUDViewModel.swift
//  DownFall
//
//  Created by Katz, Billy on 5/3/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol StoreHUDViewModelInputs {
    mutating func selected(offer: StoreOffer, deselected: StoreOffer?)
}

protocol StoreHUDViewModelOutputs {
    var currentHealth: Int { get }
    var totalHealth: Int { get }
    var totalGems: Int { get }
    var pickaxe: Pickaxe? { get }
    var healthText: String { get }
    
    var updateHUD: () -> () { get set }
}

protocol StoreHUDViewModelable: StoreHUDViewModelOutputs, StoreHUDViewModelInputs {}

class StoreHUDViewModel: StoreHUDViewModelable {
    var updateHUD: () -> () = {  }
    
    func selected(offer: StoreOffer, deselected: StoreOffer?) {
        
        currentPlayerData = pastPlayerData
        
        switch offer.type {
        case .fullHeal:
            // save the state so we can animate the difference
            pastPlayerData = currentPlayerData
            // set the state so we can have the most up to date information
            currentPlayerData = currentPlayerData.healFull()
        case .plusTwoMaxHealth:
            // save the state so we can animate the difference
            pastPlayerData = currentPlayerData
            
            // set the state so we can have the most up to date information
            currentPlayerData = currentPlayerData.gainMaxHealth(amount: 2)
        }
        
        /// tell whoever is listening to update their hud
        updateHUD()
    }
    
    
    var currentHealth: Int {
        return currentPlayerData.hp
    }
    
    var totalHealth: Int {
        return currentPlayerData.originalHp
    }
    
    var healthText: String {
        return "\(currentHealth)/\(totalHealth)"
    }
    
    var totalGems: Int {
        return currentPlayerData.carry.total(in: .gem)
    }
    
    var pickaxe: Pickaxe? {
        return currentPlayerData.pickaxe
    }
    
    var maxHealthWasUpdate: Bool {
        return pastPlayerData.originalHp != currentPlayerData.originalHp
    }
    
    var healthWasUpdated: Bool {
        return pastPlayerData.hp != currentPlayerData.hp
    }
    
    var healthDifference: Int {
        return currentPlayerData.hp - pastPlayerData.hp 
    }
    
    var originalHealthDifference: Int {
        return currentPlayerData.originalHp - pastPlayerData.originalHp
    }
    
    var pastHealth: Int {
        return pastPlayerData.hp
    }
    
    var pastOriginalHealth: Int {
        return pastPlayerData.originalHp
    }
    
    /// playerData that can update
    var currentPlayerData: EntityModel
    var pastPlayerData: EntityModel
    
    init(currentPlayerData: EntityModel, pastPlayerData: EntityModel) {
        self.currentPlayerData = currentPlayerData
        self.pastPlayerData = pastPlayerData
    }
}
