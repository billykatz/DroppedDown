//
//  StoreHUDViewModel.swift
//  DownFall
//
//  Created by Katz, Billy on 5/3/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol StoreHUDViewModelInputs {
    func add(effect: EffectModel, remove otherEffect: EffectModel?)
}

protocol StoreHUDViewModelOutputs {
    var baseHealth: Int { get }
    var totalHealth: Int { get }
    var totalGems: Int { get }
    var pickaxe: Pickaxe? { get }
    var healthText: String { get }
    var previewPlayerData: EntityModel { get }
    
    var updateHUD: () -> () { get set }
    var removedEffect: (EffectModel) -> () { get set }
    var addedEffect: (EffectModel) -> () { get set }
}

protocol StoreHUDViewModelable: StoreHUDViewModelOutputs, StoreHUDViewModelInputs {}

class StoreHUDViewModel: StoreHUDViewModelable {
    
    var updateHUD: () -> () = {  }
    var removedEffect: (EffectModel) -> () = { _ in }
    var addedEffect: (EffectModel) -> () = { _ in }
    var startRuneReplacement: (Rune) -> () = { _ in }
    
    func add(effect: EffectModel, remove otherEffect: EffectModel?) {
        if let otherEffect = otherEffect {
            /// We need to update the UI first to capture the pre-removed effect player data
            removedEffect(otherEffect)
            basePlayerData = basePlayerData.removeEffect(otherEffect)
        }
        
        /// trigger a rune replacement flow if there isn't an empty slot in your pickaxe handle
        if let rune = effect.rune,
            basePlayerData.pickaxe?.runeSlots == basePlayerData.pickaxe?.runes.count {
            startRuneReplacement(rune)
        } else {
            /// Call to update the UI after updating the player data so we capture the new state
            basePlayerData = basePlayerData.addEffect(effect)
            addedEffect(effect)
        }
    }
    
    /// A preview of what the player data will look like when we apply effects
    var previewPlayerData: EntityModel {
        return basePlayerData.previewAppliedEffects()
    }
    
    var baseHealth: Int {
        return basePlayerData.hp
    }
    
    var totalHealth: Int {
        return basePlayerData.originalHp
    }
    
    var healthText: String {
        return "\(baseHealth)/\(totalHealth)"
    }
    
    var totalGems: Int {
        return basePlayerData.carry.total(in: .gem)
    }
    
    var pickaxe: Pickaxe? {
        return basePlayerData.pickaxe
    }
    
    /// base playerData without any effects
    private var basePlayerData: EntityModel
    
    init(currentPlayerData: EntityModel) {
        self.basePlayerData = currentPlayerData
    }
}
