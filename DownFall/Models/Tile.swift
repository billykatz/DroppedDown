//
//  Tile.swift
//  DownFall
//
//  Created by William Katz on 5/11/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

enum Color {
    case blue
    case brown
    case purple
    case red
    case green
}

struct Tile: Hashable {
    let type: TileType
    var shouldHighlight: Bool
    var tutorialHighlight: Bool
    
    init(type: TileType,
         shouldHighlight: Bool = false,
         tutorialHighlight: Bool = false) {
        self.type = type
        self.shouldHighlight = shouldHighlight
        self.tutorialHighlight = tutorialHighlight
    }
    
    static var exit: Tile {
        return Tile(type: .exit)
    }
    
    static var empty: Tile {
        return Tile(type: .empty)
    }
    
    static var player: Tile {
        return Tile(type: .player(.zero))
    }
    
    static var redRock: Tile {
        return Tile(type: .rock(.red))
    }
    
    static var blueRock: Tile {
        return Tile(type: .rock(.blue))
    }
    
    static var greenRock: Tile {
        return Tile(type: .rock(.green))
    }
    
    static var purpleRock: Tile {
        return Tile(type: .rock(.purple))
    }
    
    static var brownRock: Tile {
        return Tile(type: .rock(.brown))
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
        return lhs.type == rhs.type && lhs.shouldHighlight == rhs.shouldHighlight
    }
}

enum TileType: Equatable, Hashable, CaseIterable {
    
    static var rockCases: [TileType] = [.rock(.blue), .rock(.green), .rock(.red), .rock(.blue), .rock(.brown)]
    static var allCases: [TileType] = [.player(.zero), .exit, .empty, .monster(.zero), .item(.zero), .fireball, .rock(.red), .pillar(.red, 3)]
    static var randomCases = [TileType.monster(.zero), .rock(.red)]
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
            return lhsItem == rhsItem
        case let (.pillar(leftColor), .pillar(rightColor)):
            return leftColor == rightColor
        case let (.rock(leftColor), .rock(rightColor)):
            return leftColor == rightColor
        default:
            return false
        }
    }
    
    case player(EntityModel)
    case monster(EntityModel)
    case empty
    case exit
    case item(Item)
    case fireball
    case pillar(Color, Int)
    case rock(Color)
    
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
        if case TileType.rock(let color) = self {
            return color
        } else if case TileType.pillar(let color, _) = self {
            return color
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
    
    static var gem: TileType {
        return TileType.item(.gem)
    }
    
    static var gold: TileType {
        return TileType.item(.gold)
    }
    
    var textureName: String {
        switch self {
        case .rock(let color):
            switch color {
            case .blue:
                return "blueRockv2"
            case .purple:
                return "purpleRock"
            case .brown:
                return "brownRock"
            case .red:
                return "redRockv2"
            case .green:
                return "greenRockv2"
            }
        case let .pillar(color, health):
            switch color {
            case .blue:
                return "bluePillar\(health)Health"
            case .purple:
                return "purplePillar\(health)Health"
            case .brown:
                return "brownPillar\(health)Health"
            case .red:
                return "redPillar\(health)Health"
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
        case .empty:
            return TextureName.empty.rawValue
        case .exit:
            return TextureName.exit.rawValue
        case .monster(let data):
            return data.name
        case .item(let item):
            return item.textureName
        case .fireball:
            return TextureName.fireball.rawValue
        case .rock, .pillar:
            return self.textureName
        }
    }
    
    
    enum TextureName: String {
        case player = "player2"
        case empty
        case exit
        case greenMonster
        case gem1 = "gem2"
        case fireball
    }
}

extension TileType {
    var humanReadable: String {
        switch self {
        case .rock:
            return "rock"
        case .pillar:
            return "pillar"
        case .player:
            return "player"
        case .exit:
            return "mineshaft"
        case .item:
            return "item"
        case .monster:
            return "monster"
        case .gem:
            return "gem"
        case .gold:
            return "gold"
        default:
            preconditionFailure("We probably shouldnt be here. Investigate")
        }
    }
}
