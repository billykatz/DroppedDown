//
//  Monster.swift
//  DownFall
//
//  Created by William Katz on 5/18/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

protocol ResetsAttacks {
    func resetAttacks() -> EntityModel
}

struct Pickaxe: Equatable, Codable, Hashable {
    var runeSlots: Int
    var runes: [Rune]
    
    static let maxRuneSlots = 4
    
    func removeRune(_ rune: Rune) -> Pickaxe {
        return Pickaxe(runeSlots: self.runeSlots, runes: self.runes.filter { (haveRune) -> Bool in
            rune != haveRune
        })
    }
    
    func isAtMaxCapacity() -> Bool {
        return runeSlots != Pickaxe.maxRuneSlots && runes.count == runeSlots
    }
}

struct EntityModel: Equatable, Codable {
    
    static let maxPlayerHealth = 5
    static let maxPlayerLuck = 15
    static let maxPlayerDodge = 15
    
    enum EntityType: String, Codable, CaseIterable, Hashable {
        case bat
        case rat
        case dragon
        case alamo
        case wizard
        case lavaHorse
        case player
        case sally
        case spider
        
        static var monstersCases: [EntityType] {
            return [.bat, .rat, .dragon, .alamo, .sally]
        }
        
        var humanReadable: String {
            switch self {
            case .bat:
                return "Guano the Bat"
            case .rat:
                return "Matt the Rat"
            case .dragon:
                return "Draz the Dragon"
            case .alamo:
                return "Alamo the Tree"
            case .sally:
                return "Sally the Salamander"
            case .player:
                return "Player"
            case .spider:
                return "Spider Minion"
            default:
                return self.rawValue
            }
        }
        
        var textureString: String {
            return self.rawValue
        }
    }
    
    static let playerCases: [EntityType] = [.player]
    
    static let zero: EntityModel = EntityModel(originalHp: 0, hp: 0, name: "null", attack: .zero, type: .rat, carry: .zero, animations: [], effects: [], dodge: 0, luck: 0, killedBy: nil)
    
    static let ratZero: EntityModel = EntityModel(originalHp: 1, hp: 1, name: "ratTest", attack: .zero, type: .rat, carry: .zero, animations: [], effects: [], dodge: 0, luck: 0, killedBy: nil)
    
    static let lotsOfCash: EntityModel = EntityModel(originalHp: 0, hp: 0, name: "null", attack: .zero, type: .rat, carry: CarryModel(items: [Item(type: .gem, amount: 1000, color: .blue)]), animations: [], effects: [], dodge: 0, luck: 0, killedBy: nil)
    
    static let playerZero: EntityModel = EntityModel(originalHp: 0, hp: 0, name: "null", attack: .zero, type: .player, carry: .zero, animations: [], pickaxe: Pickaxe(runeSlots: 0, runes: []), effects: [], dodge: 0, luck: 0, killedBy: nil)
    
    static func zeroedEntity(type: EntityType) -> EntityModel {
        return EntityModel(originalHp: 0, hp: 0, name: "", attack: .zero, type: type, carry: .zero, animations: [], effects: [], dodge: 0, luck: 0, killedBy: nil)
    }
    
    let originalHp: Int
    let hp: Int
    let name: String
    let attack: AttackModel
    let type: EntityType
    let carry: CarryModel
    let animations: [AnimationModel]
    var pickaxe: Pickaxe?
    var effects: [EffectModel]
    let dodge: Int
    let luck: Int
    let killedBy: EntityType?
    
    private enum CodingKeys: String, CodingKey {
        case originalHp
        case hp
        case name
        case attack
        case type
        case carry
        case animations
        case pickaxe
        case effects
        case dodge
        case luck
        case killedBy
    }
    
    public func update(originalHp: Int? = nil,
                       hp: Int? = nil,
                       name: String? = nil,
                       attack: AttackModel? = nil,
                       type: EntityType? = nil,
                       carry: CarryModel? = nil,
                       animations: [AnimationModel]? = nil,
                       pickaxe: Pickaxe? = nil,
                       effects: [EffectModel]? = nil,
                       dodge: Int? = nil,
                       luck: Int? = nil,
                       killedBy: EntityType? = nil
    ) -> EntityModel {
        let updatedOriginalHp = originalHp ?? self.originalHp
        let updatedHp = hp ?? self.hp
        let updatedName = name ?? self.name
        let updatedAttack = attack ?? self.attack
        let updatedType = type ?? self.type
        let updatedCarry = carry ?? self.carry
        let updatedAnimations = animations ?? self.animations
        let pickaxe = pickaxe ?? self.pickaxe
        let effects = effects ?? self.effects
        let dodge = dodge ?? self.dodge
        let luck = luck ?? self.luck
        let killedBy = killedBy ?? self.killedBy
        
        return EntityModel(originalHp: updatedOriginalHp,
                           hp: updatedHp,
                           name: updatedName,
                           attack: updatedAttack,
                           type: updatedType,
                           carry: updatedCarry,
                           animations: updatedAnimations,
                           pickaxe: pickaxe,
                           effects: effects,
                           dodge: dodge,
                           luck: luck,
                           killedBy: killedBy
                           
        )
        
        
        
    }
    
    var isDead: Bool {
        return hp <= 0
    }
    
    var runeSlots: Int? {
        return pickaxe?.runeSlots
    }
    
    var runes: [Rune]? {
        return pickaxe?.runes
    }
    
    var canAttack: Bool {
        return attack.attacksPerTurn - attack.attacksThisTurn > 0
    }
    
    //TODO: Fix hack that hard codes player animations because the player entity modal is not updated with new animations
    func animation(of animationType: AnimationType) -> [SKTexture]? {
        switch self.type {
        case .player:
            switch animationType {
            case .attack:
                return SpriteSheet(textureName: "player-attack-11", columns: 11).animationFrames()
            case .hurt:
                return SpriteSheet(textureName: "player-hurt-7", columns: 7).animationFrames()
            case .dying:
                return SpriteSheet(textureName: "player-dying-11", columns: 11).animationFrames()
            case .dodge:
                return SpriteSheet(textureName: "player-dodge-11", columns: 11).animationFrames()
            case .fall, .idle, .projectileStart, .projectileMid, .projectileEnd:
                return nil
            }
        default:
            guard let animations = animations.first(where: { $0.animationType == animationType })?.animationTextures else { return nil }
            return animations
        }
        
        
    }
    
    func keyframe(of animationType: AnimationType) -> Int? {
        return animations.first(where: { $0.animationType == animationType })?.keyframe
    }
    
    
    func revive() -> EntityModel {
        return self.update(hp: originalHp)
    }
    
    func didAttack() -> EntityModel {
        return update(attack: attack.didAttack())
    }
    
    func wasAttacked(for damage: Int, from direction: Direction) -> EntityModel {
        return update(hp: hp - damage)
    }
    
    func doesDodge() -> Bool {
        if self.type == .player {
            return (1...dodge+1).contains(Int.random(100))
        }
        return false
    }
    
    func buy(_ ability: Ability) -> EntityModel {
        return update(carry: carry.pay(ability.cost, inCurrency: ability.currency))
    }
    
    func sell(_ ability: Ability) -> EntityModel {
        return update(carry: carry.earn(ability.cost, inCurrency: ability.currency))
    }
    
    func canAfford(_ cost: Int, inCurrency currency: Currency) -> Bool {
        let totalAmount = carry.total(in: currency)
        return totalAmount >= cost
    }
    
    func heal(for amount: Int) -> EntityModel {
        return update(hp: min(originalHp, self.hp + amount))
    }
    
    func healFull() -> EntityModel {
        return update(hp: originalHp)
    }
    
    func gainMaxHealth(amount: Int) -> EntityModel {
        return update(originalHp: originalHp + amount)
    }
    
    func hasEffect(_ effect: EffectModel) -> Bool {
        return effects.contains(effect)
    }
    
    func removeEffect(_ effect: EffectModel) -> EntityModel {
        var effectsCopy = self.effects
        effectsCopy.removeFirst { $0 == effect }
        return update(effects: effectsCopy)
    }
    
    func spend(amount inGems: Int) -> EntityModel {
        return updateCarry(carry: carry.pay(inGems, inCurrency: .gem))
    }
    
    func earn(amount inGems: Int) -> EntityModel {
        return updateCarry(carry: carry.earn(inGems, inCurrency: .gem))
    }
    
    func addEffect(_ effect: EffectModel) -> EntityModel {
        var effectsCopy = self.effects
        effectsCopy.append(effect)
        return update(effects: effectsCopy)
    }
    
    func addRuneSlot() -> EntityModel {
        guard let pickaxe = pickaxe, pickaxe.runeSlots <= Pickaxe.maxRuneSlots else { return self }
        let newPickaxe = Pickaxe(runeSlots: pickaxe.runeSlots + 1, runes: pickaxe.runes)
        return update(pickaxe: newPickaxe)
    }
    
    func addRune(_ rune: Rune?) -> EntityModel {
        guard let rune = rune else { return self }
        var pickaxe = self.pickaxe
        pickaxe?.runes.append(rune)
        return update(pickaxe: pickaxe)
    }
    
    func removeRune(_ rune: Rune) -> EntityModel {
        var pickaxe = self.pickaxe
        pickaxe?.runes.removeFirst(where: { $0 == rune })
        return update(pickaxe: pickaxe)
    }
    
    func updateCarry(carry: CarryModel) -> EntityModel {
        return self.update(carry: carry)
    }
    
    func previewAppliedEffects() -> EntityModel {
        var newModel = self
        var appliedEffects: [EffectModel] = []
        for effect in effects {
            var updatedEffect = effect
            if !effect.wasApplied {
                newModel = newModel.applyEffect(effect)
                updatedEffect.wasApplied = true
            }
            appliedEffects.append(updatedEffect)
        }
        return newModel.update(effects: appliedEffects)
    }
    
    func applyEffect(_ effect: EffectModel) -> EntityModel {
        switch (effect.kind, effect.stat) {
        case (.refill, .health):
            return update(hp: originalHp)
        case (.buff, .health):
            return heal(for: effect.amount)
        case (.buff, .maxHealth):
            return update(originalHp: originalHp + effect.amount, hp: min(originalHp + effect.amount, hp + effect.amount))
        case (.buff, .gems):
            return update(carry: self.carry.earn(effect.amount, inCurrency: .gem))
        case (.rune, .pickaxe):
            guard let rune = effect.rune else { return self }
            var pickaxe = self.pickaxe
            pickaxe?.runes.append(rune)
            return update(pickaxe: pickaxe)
        case (.buff, .runeSlot):
            guard let pickaxe = pickaxe else { return self }
            let newPickaxe = Pickaxe(runeSlots: pickaxe.runeSlots + 1, runes: pickaxe.runes)
            return update(pickaxe: newPickaxe)
        case (.buff, .luck):
            return update(luck: luck + effect.amount)
        case (.buff, .dodge):
            return update(dodge: dodge + effect.amount)
        case (.killMonster, _), (.transmogrify, _), (.gemMagnet, _), (.infusion, _), (.item, _):
            return self
        default:
            preconditionFailure("Youll want to implement future cases here")
        }
    }
    
    func numberOfEffects(_ effect: EffectModel) -> Int {
        return effects.filter( { $0 == effect }).count
    }
    
    /// Record the runes progress if there is one
    func progressRunes(tileType: TileType, count: Int) -> EntityModel {
        var newRunes: [Rune] = []
        for rune in self.runes ?? [] {
            var newRune = rune
            if rune.rechargeType.contains(where: { TileType.fuzzyEquals($0, tileType)} ) {
                newRune = rune.progress(count)
            }
            newRunes.append(newRune)
        }
        return self.update(pickaxe: Pickaxe(runeSlots: pickaxe?.runeSlots ?? 0, runes: newRunes))
    }
    
    func useRune(_ rune: Rune) -> EntityModel {
        var newRunes: [Rune] = []
        for currRune in self.runes ?? [] {
            var newRune = currRune
            if rune == currRune {
                newRune = rune.resetProgress()
            }
            newRunes.append(newRune)
        }
        return self.update(pickaxe: Pickaxe(runeSlots: pickaxe?.runeSlots ?? 0, runes: newRunes))
    }
    
    
    static let bossMonsters: [EntityType] = [.rat, .alamo, .bat, .dragon, .sally]
    
    static func monsterWithRandomType() -> EntityModel {
        let randomMonsterTypes: [EntityType] = EntityModel.bossMonsters
        let randomMonster: EntityType = randomMonsterTypes.randomElement()!
        return EntityModel(originalHp: 1, hp: 1, name: randomMonster.textureString, attack: .zero, type: randomMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
    }
    
}

extension EntityModel: ResetsAttacks {
    func resetAttacks() -> EntityModel {
        return update(attack: attack.resetAttack())
    }
}

extension EntityModel {
    func incrementsAttackTurns() -> EntityModel {
        return update(attack: attack.incrementTurns())
    }
}

extension EntityModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(hp)
        hasher.combine(name)
    }
}

struct EntitiesModel: Equatable, Decodable {
    let entities: [EntityModel]
    
    func entity(with type: EntityModel.EntityType) -> EntityModel? {
        return entities.first(where: { $0.type == type})
    }
}

extension EntityModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "That is a \(self.type), it has \(self.hp)\n \(self.attack)"
    }
}

extension AttackModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Attacks \(String(describing: self.attackSlope)) for \(self.damage)"
    }
}

