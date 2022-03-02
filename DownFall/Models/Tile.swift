//
//  Tile.swift
//  DownFall
//
//  Created by William Katz on 5/11/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import UIKit

struct DynamiteFuse: Codable, Hashable {
    let count: Int
    var hasBeenDecremented: Bool
    
    static var standardFuse: DynamiteFuse {
        return .init(count: 3, hasBeenDecremented: false)
    }
}

struct PillarData: Codable, Hashable {
    let color: ShiftShaft_Color
    let health: Int
    
    static var random: PillarData {
        let availableColors: [ShiftShaft_Color] = [.red, .blue, .purple]
        return PillarData(color: availableColors.randomElement()!, health: 3)
    }
}

enum ShiftShaft_Color: String, Codable, CaseIterable, Hashable {
    case blue
    case brown
    case purple
    case red
    case green
    case blood
    
    var humanReadable: String{
        switch self {
        case .blue: return "Blue"
        case .brown: return "Brown"
        case .purple: return "Purple"
        case .red: return "Red"
        case .green: return "Green"
        case .blood: return "Blood"
        }
    }
    
    static var pillarCases: [ShiftShaft_Color] {
        return [.blue, .purple, .red]
    }
    
    var forUI: UIColor {
        switch self {
        case .blue: return .lightBarBlue
        case .brown: return .lightBarMonster
        case .purple: return .lightBarPurple
        case .red: return .lightBarRed
        case .green: return .lightBarGem
        case .blood: return .lightBarBlood
        }

    }
    
    static var randomColor: ShiftShaft_Color {
        return [ShiftShaft_Color.red, .purple, .blue].randomElement()!
    }
    
    static var randomCrystalColor: ShiftShaft_Color {
        return [ShiftShaft_Color.red, .purple, .blue, .green, .brown].randomElement()!
    }
}

struct Tile: Hashable, Codable {
    let type: TileType
    var bossTargetedToEat: Bool?
    
    init(type: TileType,
         bossTargetedToEat: Bool? = false
         ) {
        self.type = type
        self.bossTargetedToEat = bossTargetedToEat
    }
    
    static var exit: Tile {
        return Tile(type: .exit(blocked: false))
    }
    
    static var blockedExit: Tile {
        return Tile(type: .exit(blocked: true))
    }

    
    static var empty: Tile {
        return Tile(type: .empty)
    }
    
    static var player: Tile {
        return Tile(type: .player(.zero))
    }
    
    static var redRock: Tile {
        return Tile(type: .rock(color: .red, holdsGem: false, groupCount: 0))
    }
    
    static var blueRock: Tile {
        return Tile(type: .rock(color: .blue, holdsGem: false, groupCount: 0))
    }
    
    static var greenRock: Tile {
        return Tile(type: .rock(color: .green, holdsGem: false, groupCount: 0))
    }
    
    static var purpleRock: Tile {
        return Tile(type: .rock(color: .purple, holdsGem: false, groupCount: 0))
    }
    
    static var brownRock: Tile {
        return Tile(type: .rock(color: .brown, holdsGem: false, groupCount: 0))
    }
    
    static var purplePillar: Tile {
        return Tile(type: .pillar(PillarData(color: .purple, health: 3)))
    }
    
    static var bluePillar: Tile {
        return Tile(type: .pillar(PillarData(color: .blue, health: 3)))
    }
    
    static var redPillar: Tile {
        return Tile(type: .pillar(PillarData(color: .red, health: 3)))
    }
    
    static var gem: Tile {
        let gem = TileType.item(Item(type: .gem, amount: 10))
        return Tile(type: gem)
    }
    
    static func monster(_ model: EntityModel) -> Tile {
        return Tile(type: TileType.monster(model))
    }
    
    static var ratTileTestOnly: Tile {
        return Tile(type: .monster(.ratZero))
    }
}

extension Tile: Equatable {
    static func ==(lhs: Tile, rhs: Tile) -> Bool {
        return lhs.type == rhs.type
    }
}

enum TileType: Hashable, CaseIterable, Codable {
    
    case player(EntityModel)
    case monster(EntityModel)
    case empty
    case emptyGem(ShiftShaft_Color, amount: Int)
    case exit(blocked: Bool)
    case item(Item)
    case offer(StoreOffer)
    case pillar(PillarData)
    case rock(color: ShiftShaft_Color, holdsGem: Bool, groupCount: Int)
    case dynamite(DynamiteFuse)
    
    var entityType: EntityModel.EntityType? {
        switch self {
        case .player(let model): return model.type
        case .monster(let model): return model.type
        default: return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case base
        case entityData
        case exitBlocked
        case item
        case color
        case amount
        case dynamiteFuse
        case pillarData
        case holdsGem
        case storeOffer
        case groupCount

    }
    
    private enum Base: String, Codable {
        
        case player
        case monster
        case empty
        case emptyGem
        case exit
        case item
        case pillar
        case rock
        case dynamite
        case offer
    }
    
    /// This implementation is written about in https://medium.com/@hllmandel/codable-enum-with-associated-values-swift-4-e7d75d6f4370
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case .empty:
            self = .empty
        case .emptyGem:
            let data = try container.decode(ShiftShaft_Color.self, forKey: .color)
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .emptyGem(data, amount: amount)
        case .player:
            let data = try container.decode(EntityModel.self, forKey: .entityData)
            self = .player(data)
        case .monster:
            let data = try container.decode(EntityModel.self, forKey: .entityData)
            self = .monster(data)
        case .dynamite:
            let dynamiteFuse = try container.decode(DynamiteFuse.self, forKey: .dynamiteFuse)
            self = .dynamite(dynamiteFuse)
        case .exit:
            let blocked = try container.decode(Bool.self, forKey: .exitBlocked)
            self = .exit(blocked: blocked)
        case .rock:
            let color = try container.decode(ShiftShaft_Color.self, forKey: .color)
            let holdsGem = try container.decode(Bool.self, forKey: .holdsGem)
            let groupCount = try container.decode(Int.self, forKey: .groupCount)
            self = .rock(color: color, holdsGem: holdsGem, groupCount: groupCount)
        case .pillar:
            let pillarData = try container.decode(PillarData.self, forKey: .pillarData)
            self = .pillar(pillarData)
        case .item:
            let item = try container.decode(Item.self, forKey: .item)
            self = .item(item)
        case .offer:
            let offerData = try container.decode(StoreOffer.self, forKey: .storeOffer)
            self = .offer(offerData)
        }
    }
    
    /// This implementation is written about in https://medium.com/@hllmandel/codable-enum-with-associated-values-swift-4-e7d75d6f4370
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .player(let data):
            try container.encode(Base.player, forKey: .base)
            try container.encode(data, forKey: .entityData)
        case .monster(let data):
            try container.encode(Base.monster, forKey: .base)
            try container.encode(data, forKey: .entityData)
        case .empty:
            try container.encode(Base.empty, forKey: .base)
        case .emptyGem(let color, let amount):
            try container.encode(Base.emptyGem, forKey: .base)
            try container.encode(color, forKey: .color)
            try container.encode(amount, forKey: .amount)
        case .exit(blocked: let blocked):
            try container.encode(Base.exit, forKey: .base)
            try container.encode(blocked, forKey: .exitBlocked)
        case .item(let item):
            try container.encode(Base.item, forKey: .base)
            try container.encode(item, forKey: .item)
        case .pillar(let pillarData):
            try container.encode(Base.pillar, forKey: .base)
            try container.encode(pillarData, forKey: .pillarData)
        case .rock(let rock, let holdsGem, let groupCount):
            try container.encode(Base.rock, forKey: .base)
            try container.encode(rock, forKey: .color)
            try container.encode(holdsGem, forKey: .holdsGem)
            try container.encode(groupCount, forKey: .groupCount)
        case .dynamite(let fuseCount):
            try container.encode(Base.dynamite, forKey: .base)
            try container.encode(fuseCount, forKey: .dynamiteFuse)
        case .offer(let storeOffer):
            try container.encode(Base.offer, forKey: .base)
            try container.encode(storeOffer, forKey: .storeOffer)
        }
    }
    
    var isARock: Bool {
        if case .rock = self {
            return true
        }
        return false
    }
    
    
    var isAPillar: Bool {
        if case .pillar = self {
            return true
        }
        return false
    }
    
    
    var isDestructible: Bool {
        return isARock || isAPillar
    }
    
    var color: ShiftShaft_Color? {
        if case TileType.rock(let color, _, _) = self {
            return color
        } else if case TileType.pillar(let data) = self {
            return data.color
        }
        return nil
    }
    
    var isInspectable: Bool {
        switch self {
        case .monster, .player, .item, .exit:
            return true
        default: return false
        }
    }
    
    func turnsUntilAttack() -> Int? {
        if case let .monster(data) = self {
            return data.attack.turnsUntilNextAttack()
        }
        return nil
        
    }
    
    func attackFrequency() -> Int? {
        if case let .monster(data) = self {
            return data.attack.frequency
        }
        return nil
    }
    
    var offer: StoreOffer? {
        switch self {
        case .offer(let offer):
            return offer
        default:
             return nil
        }
    }
    
    static var gem: TileType {
        return TileType.item(.gem)
    }
    
    var gemAmount: Int? {
        if case TileType.item(let item) = self {
            return item.amount
        } else if case TileType.offer(let offer) = self {
            switch offer.type {
            case .gems(amount: let amount):
                return amount
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    var pillarHealth: Int? {
        if case TileType.pillar(let data) = self {
            return data.health
        } else {
            return nil
        }
    }
    
    private var isRock: Bool {
        if case TileType.rock = self { return true }
        return false
    }
    
    public var isPlayer: Bool {
        if case TileType.player = self { return true }
        return false
    }
    
    public var sparkleSheetName: SpriteSheet? {
        precondition(self.isRock, "Only call this for rocks")
        
        switch self {
        case .rock(color: let color, holdsGem: let hasGem, groupCount: let groupCount):
            guard hasGem else { return nil }
            let gemTier = numberOfGemsPerRockForGroup(size: groupCount)
            let spriteSheet = "\(color.humanReadable.lowercased())-rock-\(gemTier)-sparkle"
            let numberOfColumns: Int
            switch (color, gemTier) {
            case (.blue, 1):
                numberOfColumns = 6
                
            case (.blue, 2), (.blue, 3):
                numberOfColumns = 13
                
            case (.red, 1):
                numberOfColumns = 6
                
            case (.red, 2), (.red, 3):
                numberOfColumns = 11
                
            case (.purple, 1):
                numberOfColumns = 7
                
            case (.purple, 2), (.purple, 3):
                numberOfColumns = 11
                
            default:
                numberOfColumns = 1
            }
            
            return SpriteSheet(textureName: spriteSheet, columns: numberOfColumns)
            
        default:
            return nil
        }
    }
    
    var amountInGroup: Int {
        switch self {
            case .rock(_, _, let groupCount):
                return groupCount
        default:
            return 0
        }
    }
    
    var fuseTiming: Int? {
        switch self {
        case .dynamite(let fuse):
            return fuse.count
        default:
            return nil
        
        }
    }
    
    private var textureName: String {
        switch self {
        case .rock(let color, let withGem, let groupCount):
            let gemTier = numberOfGemsPerRockForGroup(size: groupCount)
            let withGemSuffix = withGem ? "WithGem" : ""
            let gemTierSuffix = (gemTier > 0 && withGem) ? "\(gemTier)" : ""
            switch color {
            case .blue:
                return "blueRock\(withGemSuffix)\(gemTierSuffix)"
            case .purple:
                return "purpleRock\(withGemSuffix)\(gemTierSuffix)"
            case .brown:
                return "brownRock\(withGemSuffix)\(gemTierSuffix)"
            case .red:
                return "redRock\(withGemSuffix)\(gemTierSuffix)"
            case .green:
                return "greenRock\(withGemSuffix)\(gemTierSuffix)"
            case .blood:
                fatalError()
            }
        case .pillar(let data):
            switch data.color {
            case .blue:
                return "bluePillar\(data.health)Health"
            case .purple:
                return "purplePillar\(data.health)Health"
            case .brown:
                return "brownPillar\(data.health)Health"
            case .red:
                return "redPillar\(data.health)Health"
            case .green:
                preconditionFailure("Shouldnt be here")
            case .blood:
                fatalError()
            }
            
        default:
            return ""
        }
    }
    
    /// Return a string representing the texture's file name
    func textureString() -> String {
        switch self {
        case .player:
            return TextureName.player.rawValue
        case .empty, .emptyGem:
            return TextureName.empty.rawValue
        case .exit(let blocked):
            return blocked ? "blockedExit" : "mineshaft"
        case .monster(let data):
            return data.name
        case .item(let item):
            return item.textureName
        case .rock, .pillar:
            return self.textureName
        case .dynamite:
            return TextureName.dynamite.rawValue
        case .offer(let storeOffer):
            return storeOffer.textureName
        }
    }
    
    static func fuzzyEquals(_ lhs: TileType, _ rhs: TileType) -> Bool {
        switch (lhs, rhs) {
        case (.player, player):
            return true
        case (.monster, monster):
            return true
        case (.empty, empty):
            return true
        case (.emptyGem, emptyGem):
            return true
        case (.exit, exit):
            return true
        case (.item, item):
            return true
        case (.offer, offer):
            return true
        case (.pillar, pillar):
            return true
        case (.rock(let lhsColor, _, _), rock(let rhsColor, _, _)):
            return lhsColor == rhsColor
        case (.dynamite, dynamite):
            return true
        default:
            return false
        }
    }
    
    
    enum TextureName: String {
        case player = "player"
        case empty
        case exit
        case greenMonster
        case gem1 = "gem2"
        case dynamite
    }
}

extension TileType {
    var humanReadable: String {
        switch self {
        case .rock(let color, _, _):
            //TODO: this might have some consequences
            return "\(color.humanReadable) rock"
        case .pillar(let data):
            return "\(data.color.humanReadable) pillar"
        case .player(let data):
            return data.type.humanReadable
        case .exit(let blocked):
            if blocked {
                return "Blocked Mineshaft"
            } else {
                return "Mineshaft"
            }
        case .item(let item):
            return item.humanReadable
        case .monster(let data):
            return data.type.humanReadable
        case .gem:
            return "gem"
        case .dynamite:
            return "dynamite"
        case .offer(let offer):
            return offer.description
        default:
            preconditionFailure("We probably shouldnt be here. Investigate")
        }
    }
}

extension TileType {
    static var rockCases: [TileType] = [.rock(color: .blue, holdsGem: false, groupCount: 0), .rock(color: .green, holdsGem: false, groupCount: 0), .rock(color: .red, holdsGem: false, groupCount: 0), .rock(color: .purple, holdsGem: false, groupCount: 0), .rock(color: .brown, holdsGem: false, groupCount: 0)]
    static var allCases: [TileType] = [.player(.zero), .exit(blocked: false), .empty, .monster(.zero), .item(.zero), .rock(color: .red, holdsGem: false, groupCount: 0), .pillar(PillarData(color: .red, health: 3))]
    static var randomCases = [TileType.monster(.zero), .rock(color: .red, holdsGem: false, groupCount: 0)]
    typealias AllCases = [TileType]
    
    static func == (lhs: TileType, rhs: TileType) -> Bool {
        switch (lhs, rhs) {
        case (.player, .player):
            return true
        case (.empty, .empty):
            return true
        case (.exit, .exit):
            return true
        case (.monster, .monster):
            return true
        case (.item(let lhsItem), .item(let rhsItem)):
            return lhsItem.type == rhsItem.type
        case let (.pillar(leftData), .pillar(rightData)):
            return leftData.color == rightData.color
        case let (.rock(leftColor, leftHoldsGem, _), .rock(rightColor, rightHoldsGem, _)):
            return leftColor == rightColor && leftHoldsGem == rightHoldsGem 
        case let (.dynamite(lhsFuse), .dynamite(rhsFuse)):
            return lhsFuse.hasBeenDecremented == rhsFuse.hasBeenDecremented
        case let (.offer(lhsOffer), .offer(rhsOffer)):
            return lhsOffer == rhsOffer
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .player(let data):
            hasher.combine(data)
        case .empty:
            hasher.combine(self.textureString())
        case .exit:
            hasher.combine(self.textureString())
        case .monster(let data):
            hasher.combine(data)
        case .item(let data):
            hasher.combine(data)
        case .pillar(let data):
            hasher.combine(data)
        case .dynamite(let data):
            hasher.combine(data)
        case .rock(let color, _,_):
            hasher.combine(color)
        case .offer(let offer):
            hasher.combine(offer)
        case .emptyGem(let color, amount: let amount):
            hasher.combine(color)
            hasher.combine(amount)
        }
    }

}
