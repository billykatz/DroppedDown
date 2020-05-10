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
    func remove(effect: EffectModel)
    func confirmRuneReplacement(effect: EffectModel, removed rune: Rune)
    func cancelRuneReplacement(effect: EffectModel)
}

protocol StoreHUDViewModelOutputs {
    /// base information
    var baseHealth: Int { get }
    var totalHealth: Int { get }
    var totalGems: Int { get }
    var pickaxe: Pickaxe? { get }
    var healthText: String { get }
    var previewPlayerData: EntityModel { get }
    
    /// hook up to parent
    var effectUseCanceled: (EffectModel) -> () { get }
    var runeRelacedChanged: (Rune) -> () { get }
    
    /// hook up to UI
    var updateHUD: () -> () { get set }
    var removedEffect: (EffectModel) -> () { get set }
    var addedEffect: (EffectModel) -> () { get set }
    var startRuneReplacement: (EffectModel) -> () { get set }
    
    /// accept input
    
    
}

protocol StoreHUDViewModelable: StoreHUDViewModelOutputs, StoreHUDViewModelInputs {}

class StoreHUDViewModel: StoreHUDViewModelable {
    var runeRelacedChanged: (Rune) -> () = { _ in }
    var effectUseCanceled: (EffectModel) -> () = { _ in }
    var updateHUD: () -> () = {  }
    var removedEffect: (EffectModel) -> () = { _ in }
    var addedEffect: (EffectModel) -> () = { _ in }
    var startRuneReplacement: (EffectModel) -> () = { _ in }
    
    var removedRune: Rune?
    
    private func addBackRemovedRuneAndRemoveRuneEffect(_ effect: EffectModel) {
        basePlayerData = basePlayerData.addRune(removedRune)
        removedRune = nil
        
        basePlayerData = basePlayerData.removeEffect(effect)
        removedEffect(effect)
    }
    
    func remove(effect: EffectModel) {
        if effect.kind == .rune {
            /// add back the remove rune
            addBackRemovedRuneAndRemoveRuneEffect(effect)


        } else {
            removedEffect(effect)
            basePlayerData = basePlayerData.removeEffect(effect)
        }
    }
    
    func add(effect: EffectModel, remove otherEffect: EffectModel?) {
        if let otherEffect = otherEffect {
            /// we need to behave differently for runes
            if otherEffect.rune != nil {
                /// this means we have replaced the rune in the staging area with another offer
                /// add back the remove rune
                addBackRemovedRuneAndRemoveRuneEffect(otherEffect)
            }
            /// We need to update the UI first to capture the pre-removed effect player data
            else {
                removedEffect(otherEffect)
                basePlayerData = basePlayerData.removeEffect(otherEffect)
            }
        }
        
        /// trigger a rune replacement flow if there isn't an empty slot in your pickaxe handle
        if let rune = effect.rune,
            basePlayerData.pickaxe?.runeSlots == basePlayerData.pickaxe?.runes.count {
            startRuneReplacement(effect)
        } else {
            /// Call to update the UI after updating the player data so we capture the new state
            basePlayerData = basePlayerData.addEffect(effect)
            addedEffect(effect)
        }
    }
    
    func confirmRuneReplacement(effect: EffectModel, removed rune: Rune) {
        basePlayerData = basePlayerData.addEffect(effect)
        basePlayerData = basePlayerData.removeRune(rune)
        
        removedRune = rune
        
        // tell our parent about what happened
        runeRelacedChanged(rune)
    }
    
    func cancelRuneReplacement(effect: EffectModel) {
        basePlayerData = basePlayerData.removeEffect(effect)
        removedEffect(effect)
        
        effectUseCanceled(effect)
        
        if let rune = removedRune {
            // tell our parent about what happened
            runeRelacedChanged(rune)
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
    
    var previewTotalGems: Int {
        return previewPlayerData.carry.total(in: .gem)
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
