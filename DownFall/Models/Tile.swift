//
//  Tile.swift
//  DownFall
//
//  Created by William Katz on 5/11/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

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
    
    static var blackRock: Tile {
        return Tile(type: .blackRock)
    }
    
    static var blueRock: Tile {
        return Tile(type: .blueRock)
    }
    
    static var greenRock: Tile {
        return Tile(type: .greenRock)
    }
    
    static var purpleRock: Tile {
        return Tile(type: .purpleRock)
    }
    
    static var brownRock: Tile {
        return Tile(type: .brownRock)
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
    
    static var rockCases: [TileType] = [.blueRock, .greenRock, .purpleRock, .brownRock, .redRock]
    static var allCases: [TileType] = [.blueRock, .blackRock,.greenRock, .player(.zero), .exit, .empty, .monster(.zero), .item(.zero), .fireball, .redRock]
    typealias AllCases = [TileType]

    static func == (lhs: TileType, rhs: TileType) -> Bool {
        switch (lhs, rhs) {
        case (.blueRock, .blueRock):
            return true
        case (.blackRock, .blackRock):
            return true
        case (.greenRock, .greenRock):
            return true
        case (.brownRock, .brownRock):
            return true
        case (.purpleRock, .purpleRock):
            return true
        case (.redRock, .redRock):
            return true
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
        default:
            return false
        }
    }
    
    case blueRock
    case blackRock
    case greenRock
    case purpleRock
    case brownRock
    case redRock
    case player(EntityModel)
    case monster(EntityModel)
    case empty
    case exit
    case item(Item)
    case fireball
    
    func isARock() -> Bool {
        return TileType.rockCases.contains(self)
    }
    
    var isInspectable: Bool {
        switch self {
        case .monster, .player, .item, .exit:
            return true
        default: return false
        }
    }
    
//    func willAttackNextTurn() -> Bool {
//        if case let .monster(data) = self {
//            return data.willAttackNextTurn()
//        }
//        return false
//    }
    
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
    
    /// Return a string representing the texture's file name
    func textureString() -> String {
        switch self {
        case .blueRock:
            return TextureName.blueRock.rawValue
        case .blackRock:
            return TextureName.blackRock.rawValue
        case .greenRock:
            return TextureName.greenRock.rawValue
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
        case .purpleRock:
            return TextureName.purpleRock.rawValue
        case .brownRock:
            return TextureName.brownRock.rawValue
        case .redRock:
            return TextureName.redRock.rawValue
        }
    }
    
    
    enum TextureName: String {
        case blueRock = "blueRockv2"
        case blackRock
        case greenRock = "greenRockv2"
        case purpleRock
        case brownRock
        case redRock = "redRockv2"
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
        case .blackRock, .blueRock, .brownRock, .greenRock, .purpleRock, .redRock:
            return "rock"
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
