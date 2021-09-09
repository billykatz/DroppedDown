//
//  StoreOfferType.swift
//  DownFall
//
//  Created by Billy on 7/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

enum StoreOfferType: Codable, Hashable, CaseIterable {
    static var allCases: [StoreOfferType] = {
        let runeCases = RuneType.allCases.map {
            return StoreOfferType.rune(Rune.rune(for: $0))
        }
        var values: [StoreOfferType] = [
            .greaterHeal,
            .plusOneMaxHealth,
            .plusTwoMaxHealth,
            .runeSlot,
            .killMonsterPotion,
            .luck(amount: 5),
            .dodge(amount: 5),
            .gems(amount: 5),
            .runeUpgrade,
            .transmogrifyPotion,
            .lesserHeal,
        ]
        
        values.append(contentsOf: runeCases)
        
        return values
    }()
    
    static func ==(lhs: StoreOfferType, rhs: StoreOfferType) -> Bool {
        switch (lhs, rhs) {
        case (.plusOneMaxHealth, .plusOneMaxHealth): return true
        case (.plusTwoMaxHealth, .plusTwoMaxHealth): return true
            
        case (.runeUpgrade, .runeUpgrade): return true
        case (.runeSlot, .runeSlot): return true
        case (.rune(let lhsRune), .rune(let rhsRune)): return lhsRune == rhsRune
            
        case (.gems(_), .gems(_)): return true
        case (.dodge(_), .dodge(_)): return true
        case (.luck(_), .luck(_)): return true
            
        case (.greaterHeal, .greaterHeal): return true
        case (.lesserHeal, .lesserHeal): return true
            
        case (.killMonsterPotion, killMonsterPotion): return true
        case (.transmogrifyPotion, .transmogrifyPotion): return true
            
        // default cases to catch and return false for any other comparisons
        case (.plusOneMaxHealth, _): return false
        case (.plusTwoMaxHealth, _): return false
        case (.runeUpgrade, _): return false
        case (.runeSlot, _): return false
        case (.rune(_), _): return false
        case (.gems(_), _): return false
        case (.dodge(_), _): return false
        case (.luck(_), _): return false
        case (.greaterHeal, _): return false
        case (.lesserHeal, _): return false
        case (.killMonsterPotion,_): return false
        case (.transmogrifyPotion, _): return false
    
        }
    }
    
    case plusTwoMaxHealth
    case plusOneMaxHealth
    case rune(Rune)
    case runeUpgrade
    case runeSlot
    case gems(amount: Int)
    case dodge(amount: Int)
    case luck(amount: Int)
    case lesserHeal
    case greaterHeal
    case killMonsterPotion
    case transmogrifyPotion
    
    enum CodingKeys: String, CodingKey {
        case base
        case runeModel
        case gemAmount
        case dodgeAmount
        case luckAmount
    }
    
    private enum Base: String, Codable {
        case plusTwoMaxHealth
        case rune
        case runeUpgrade
        case runeSlot
        case gems
        case dodge
        case luck
        case plusOneMaxHealth
        case lesserHeal
        case greaterHeal
        case killMonsterPotion
        case transmogrifyPotion
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case .plusTwoMaxHealth:
            self = .plusTwoMaxHealth
        case .rune:
            let data = try container.decode(Rune.self, forKey: .runeModel)
            self = .rune(data)
        case .runeUpgrade:
            self = .runeUpgrade
        case .runeSlot:
            self = .runeSlot
        case .gems:
            let amount = try container.decode(Int.self, forKey: .gemAmount)
            self = .gems(amount: amount)
        case .dodge:
            let amount = try container.decode(Int.self, forKey: .dodgeAmount)
            self = .dodge(amount: amount)
        case .luck:
            let amount = try container.decode(Int.self, forKey: .luckAmount)
            self = .luck(amount: amount)
        case .plusOneMaxHealth:
            self = .plusOneMaxHealth
        case .lesserHeal:
            self = .lesserHeal
        case .greaterHeal:
            self = .greaterHeal
        case .transmogrifyPotion:
            self = .transmogrifyPotion
        case .killMonsterPotion:
            self = .killMonsterPotion
        }
    }
    
    /// This implementation is written about in https://medium.com/@hllmandel/codable-enum-with-associated-values-swift-4-e7d75d6f4370
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .plusTwoMaxHealth:
            try container.encode(Base.plusTwoMaxHealth, forKey: .base)
        case .rune(let runeModel):
            try container.encode(Base.rune, forKey: .base)
            try container.encode(runeModel, forKey: .runeModel)
        case .runeUpgrade:
            try container.encode(Base.runeUpgrade, forKey: .base)
        case .runeSlot:
            try container.encode(Base.runeSlot, forKey: .base)
        case .gems(let amount):
            try container.encode(Base.gems, forKey: .base)
            try container.encode(amount, forKey: .gemAmount)
        case .dodge(let amount):
            try container.encode(Base.dodge, forKey: .base)
            try container.encode(amount, forKey: .dodgeAmount)
        case .luck(let amount):
            try container.encode(Base.luck, forKey: .base)
            try container.encode(amount, forKey: .luckAmount)
        case .lesserHeal:
            try container.encode(Base.lesserHeal, forKey: .base)
        case .greaterHeal:
            try container.encode(Base.greaterHeal, forKey: .base)
        case .plusOneMaxHealth:
            try container.encode(Base.plusOneMaxHealth, forKey: .base)
        case .killMonsterPotion:
            try container.encode(Base.killMonsterPotion, forKey: .base)
        case .transmogrifyPotion:
            try container.encode(Base.transmogrifyPotion, forKey: .base)
        }
    }
    
}
