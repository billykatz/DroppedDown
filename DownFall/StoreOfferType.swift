//
//  StoreOfferType.swift
//  DownFall
//
//  Created by Billy on 7/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

enum StoreOfferType: Codable, Hashable, CaseIterable {
    
    struct Constants {
        static let sandalsDodgeAmount = 3
        static let runningShoesDodgeAmount = 5
        static let wingedBootsDodgeAmount = 10
        
        static let fourLeafCloverLuckAmount = 3
        static let horseshoeLuckAMount = 7
        static let luckyCatLuckAmount = 14
    }
    
    case plusTwoMaxHealth
    case plusOneMaxHealth
    case rune(Rune)
    case runeSlot
    case gems(amount: Int)
    case dodge(amount: Int)
    case luck(amount: Int)
    case lesserHeal
    case greaterHeal
    case killMonsterPotion
    case transmogrifyPotion
    case sandals
    case runningShoes
    case wingedBoots
    case fourLeafClover
    case horseshoe
    case luckyCat
    case gemMagnet
    case infusion
    case snakeEyes
    case liquifyMonsters
    case chest
    case escape
    
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
        case runeSlot
        case gems
        case dodge
        case luck
        case plusOneMaxHealth
        case lesserHeal
        case greaterHeal
        case killMonsterPotion
        case transmogrifyPotion
        case sandals
        case runningShoes
        case wingedBoots
        case fourLeafClover
        case horseshoe
        case luckyCat
        case gemMagnet
        case infusion
        case snakeEyes
        case liquifyMonsters
        case chest
        case escape
    }
    
    var luckAmount: Int {
        switch self {
        case .fourLeafClover:
            return Constants.fourLeafCloverLuckAmount
        case .horseshoe:
            return Constants.horseshoeLuckAMount
        case .luckyCat:
            return Constants.luckyCatLuckAmount
        case .luck(amount: let amt):
            return amt
        default:
            return 0
        }
    }
    
    var dodgeAmount: Int {
        switch self {
        case .sandals:
            return Constants.sandalsDodgeAmount
        case .runningShoes:
            return Constants.runningShoesDodgeAmount
        case .wingedBoots:
            return Constants.wingedBootsDodgeAmount
        case .dodge(amount: let amt):
            return amt
        default:
            return 0
        }
    }
    
    var numberOfTargets: Int {
        switch self {
        case .liquifyMonsters:
            return 5
        default:
            return 0
        }
    }
    
    var effectAmount: Int {
        switch self {
        case .liquifyMonsters:
            return 10
        case .transmogrifyPotion:
            return 50
        default:
            return 0
        }
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
        case .sandals:
            self = .sandals
        case .runningShoes:
            self = .runningShoes
        case .wingedBoots:
            self = .wingedBoots
        case .fourLeafClover:
            self = .fourLeafClover
        case .horseshoe:
            self = .horseshoe
        case .luckyCat:
            self = .luckyCat
        case .gemMagnet:
            self = .gemMagnet
        case .infusion:
            self = .infusion
        case .snakeEyes:
            self = .snakeEyes
        case .liquifyMonsters:
            self = .liquifyMonsters
        case .chest:
            self = .chest
        case .escape:
            self = .escape

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
        case .sandals:
            try container.encode(Base.sandals, forKey: .base)
        case .runningShoes:
            try container.encode(Base.runningShoes, forKey: .base)
        case .wingedBoots:
            try container.encode(Base.wingedBoots, forKey: .base)
        case .fourLeafClover:
            try container.encode(Base.fourLeafClover, forKey: .base)
        case .horseshoe:
            try container.encode(Base.horseshoe, forKey: .base)
        case .luckyCat:
            try container.encode(Base.luckyCat, forKey: .base)
        case .gemMagnet:
            try container.encode(Base.gemMagnet, forKey: .base)
        case .infusion:
            try container.encode(Base.infusion, forKey: .base)
        case .snakeEyes:
            try container.encode(Base.snakeEyes, forKey: .base)
        case .liquifyMonsters:
            try container.encode(Base.liquifyMonsters, forKey: .base)
        case .chest:
            try container.encode(Base.chest, forKey: .base)
        case .escape:
            try container.encode(Base.escape, forKey: .base)
        }
    }
    
}

extension StoreOfferType {
    
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
            .transmogrifyPotion,
            .lesserHeal,
            .sandals,
            .runningShoes,
            .wingedBoots,
            .fourLeafClover,
            .horseshoe,
            .luckyCat,
            .gemMagnet,
            .infusion,
            .snakeEyes,
            .liquifyMonsters,
            .chest,
            .escape,
            
        ]
        
        values.append(contentsOf: runeCases)
        
        return values
    }()
    
    static func ==(lhs: StoreOfferType, rhs: StoreOfferType) -> Bool {
        switch (lhs, rhs) {
        case (.plusOneMaxHealth, .plusOneMaxHealth): return true
        case (.plusTwoMaxHealth, .plusTwoMaxHealth): return true
            
        case (.runeSlot, .runeSlot): return true
        case (.rune(let lhsRune), .rune(let rhsRune)): return lhsRune == rhsRune
            
        case (.gems(_), .gems(_)): return true
        case (.dodge(_), .dodge(_)): return true
        case (.luck(_), .luck(_)): return true
            
        case (.greaterHeal, .greaterHeal): return true
        case (.lesserHeal, .lesserHeal): return true
            
        case (.killMonsterPotion, killMonsterPotion): return true
        case (.transmogrifyPotion, .transmogrifyPotion): return true
            
        case (.sandals, .sandals): return true
        case (.runningShoes, .runningShoes): return true
        case (.wingedBoots, .wingedBoots): return true
        case (.fourLeafClover, .fourLeafClover): return true
        case (.horseshoe, .horseshoe): return true
        case (.luckyCat, .luckyCat): return true
            
        case (.gemMagnet, .gemMagnet): return true
        case (.infusion, .infusion): return true
        case (.snakeEyes, .snakeEyes): return true
        case (.liquifyMonsters, .liquifyMonsters): return true
        case (.chest, .chest): return true
        case (.escape, .escape): return true
            
        // default cases to catch and return false for any other comparisons
        default:
            return false
    
        }
    }
}
