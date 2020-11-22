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
}

struct PillarData: Codable, Hashable {
    let color: Color
    let health: Int
}

enum Color: String, Codable, CaseIterable, Hashable {
    case blue
    case brown
    case purple
    case red
    case green
    
    var humanReadable: String{
        switch self {
        case .blue: return "Blue"
        case .brown: return "Brown"
        case .purple: return "Purple"
        case .red: return "Red"
        case .green: return "Green"
        }
    }
    
    var forUI: UIColor {
        switch self {
        case .blue: return .lightBarBlue
        case .brown: return .lightBarMonster
        case .purple: return .lightBarPurple
        case .red: return .lightBarRed
        case .green: return .lightBarGem
        }

    }
}

struct Tile: Hashable {
    let type: TileType
    var tutorialHighlight: Bool
    
    init(type: TileType,
         tutorialHighlight: Bool = false) {
        self.type = type
        self.tutorialHighlight = tutorialHighlight
    }
    
    static var exit: Tile {
        return Tile(type: .exit(blocked: false))
    }
    
    static var empty: Tile {
        return Tile(type: .empty)
    }
    
    static var player: Tile {
        return Tile(type: .player(.zero))
    }
    
    static var redRock: Tile {
        return Tile(type: .rock(color: .red, holdsGem: false))
    }
    
    static var blueRock: Tile {
        return Tile(type: .rock(color: .blue, holdsGem: false))
    }
    
    static var greenRock: Tile {
        return Tile(type: .rock(color: .green, holdsGem: false))
    }
    
    static var purpleRock: Tile {
        return Tile(type: .rock(color: .purple, holdsGem: false))
    }
    
    static var brownRock: Tile {
        return Tile(type: .rock(color: .brown, holdsGem: false))
    }
    
    static var gold: Tile {
        return Tile(type: .gold)
    }
    
    static var gem: Tile {
        let gem = TileType.item(Item(type: .gem, amount: 1))
        return Tile(type: gem)
    }
    
    static func monster(_ model: EntityModel) -> Tile {
        return Tile(type: TileType.monster(model))
    }
}

extension Tile: Equatable {
    static func ==(lhs: Tile, rhs: Tile) -> Bool {
        return lhs.type == rhs.type
    }
}

enum TileType: Hashable, CaseIterable, Codable {
    
    static var rockCases: [TileType] = [.rock(color: .blue, holdsGem: false), .rock(color: .green, holdsGem: false), .rock(color: .red, holdsGem: false), .rock(color: .purple, holdsGem: false), .rock(color: .brown, holdsGem: false)]
    static var allCases: [TileType] = [.player(.zero), .exit(blocked: false), .empty, .monster(.zero), .item(.zero), .rock(color: .red, holdsGem: false), .pillar(PillarData(color: .red, health: 3))]
    static var randomCases = [TileType.monster(.zero), .rock(color: .red, holdsGem: false), .item(Item.gem)]
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
        case let (.rock(leftColor, leftHoldsGem), .rock(rightColor, rightHoldsGem)):
            return leftColor == rightColor && leftHoldsGem == rightHoldsGem
        case let (.dynamite(lhsFuse), .dynamite(rhsFuse)):
            return lhsFuse.hasBeenDecremented == rhsFuse.hasBeenDecremented
        case let (.offer(lhsOffer), .offer(rhsOffer)):
            return lhsOffer == rhsOffer
        default:
            return false
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case base
        case entityData
        case exitBlocked
        case item
        case color
        case dynamiteFuse
        case pillarData
        case holdsGem
        case storeOffer

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
            let data = try container.decode(Color.self, forKey: .color)
            self = .emptyGem(data)
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
            let color = try container.decode(Color.self, forKey: .color)
            let holdsGem = try container.decode(Bool.self, forKey: .holdsGem)
            self = .rock(color: color, holdsGem: holdsGem)
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
        case .emptyGem(let color):
            try container.encode(Base.emptyGem, forKey: .base)
            try container.encode(color, forKey: .color)
        case .exit(blocked: let blocked):
            try container.encode(Base.exit, forKey: .base)
            try container.encode(blocked, forKey: .exitBlocked)
        case .item(let item):
            try container.encode(Base.item, forKey: .base)
            try container.encode(item, forKey: .item)
        case .pillar(let pillarData):
            try container.encode(Base.pillar, forKey: .base)
            try container.encode(pillarData, forKey: .pillarData)
        case .rock(let rock, let holdsGem):
            try container.encode(Base.rock, forKey: .base)
            try container.encode(rock, forKey: .color)
            try container.encode(holdsGem, forKey: .holdsGem)
        case .dynamite(let fuseCount):
            try container.encode(Base.dynamite, forKey: .base)
            try container.encode(fuseCount, forKey: .dynamiteFuse)
        case .offer(let storeOffer):
            try container.encode(Base.offer, forKey: .base)
            try container.encode(storeOffer, forKey: .storeOffer)
        }
    }

    
    case player(EntityModel)
    case monster(EntityModel)
    case empty
    case emptyGem(Color)
    case exit(blocked: Bool)
    case item(Item)
    case offer(StoreOffer)
    case pillar(PillarData)
    case rock(color: Color, holdsGem: Bool)
    case dynamite(DynamiteFuse)
    
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
    
    var color: Color? {
        if case TileType.rock(let color, _) = self {
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
    
    static var gold: TileType {
        return TileType.item(.gold)
    }
    
    private var textureName: String {
        switch self {
        case .rock(let color, let withGem):
            let withGemSuffix = withGem ? "WithGem" : ""
            switch color {
            case .blue:
                return "blueRock\(withGemSuffix)"
            case .purple:
                return "purpleRock\(withGemSuffix)"
            case .brown:
                return "brownRock\(withGemSuffix)"
            case .red:
                return "redRock\(withGemSuffix)"
            case .green:
                return "greenRock\(withGemSuffix)"
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
    
    
    enum TextureName: String {
        case player = "player2"
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
        case .rock(let color, _ ):
            //TODO: this might have some consequences
            return "\(color.humanReadable) rock"
        case .pillar(let data):
            return "\(data.color.humanReadable) pillar"
        case .player(let data):
            return data.type.humanReadable
        case .exit:
            return "mineshaft"
        case .item(let item):
            return item.humanReadable
        case .monster(let data):
            return data.type.humanReadable
        case .gem:
            return "gem"
        case .gold:
            return "gold"
        case .dynamite:
            return "dynamite"
        case .offer(let offer):
            return offer.description
        default:
            preconditionFailure("We probably shouldnt be here. Investigate")
        }
    }
}
