//
//  Tile.swift
//  DownFall
//
//  Created by William Katz on 5/11/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

struct CombatTileData: Equatable {
    let hp: Int
    let attackDamage: Int
    
    static func monster() -> CombatTileData {
        return CombatTileData(hp: 1, attackDamage: 1)
    }
    
    static func player() -> CombatTileData {
        return CombatTileData(hp: 1, attackDamage: 1)
    }
}

enum TileType: Equatable, CaseIterable {
    
    static var allCases: [TileType] = [.blueRock, .blackRock ,.greenRock, .player(), .exit, .empty, .greenMonster()]
    typealias AllCases = [TileType]

    static func == (lhs: TileType, rhs: TileType) -> Bool {
        switch (lhs, rhs) {
        case (.blueRock, .blueRock):
            return true
        case (.blackRock, .blackRock):
            return true
        case (.greenRock, .greenRock):
            return true
        case (.player(_), .player(_)):
            return true
        case (.empty, .empty):
            return true
        case (.exit, .exit):
            return true
        case (.greenMonster(let lhsData), .greenMonster(let rhsData)):
            return lhsData == rhsData
        default:
            return false
        }
    }
    
    case blueRock
    case blackRock
    case greenRock
    case player(CombatTileData)
    case empty
    case exit
    case greenMonster(CombatTileData)
    
    /// Create a random rock Tile instance
    static func randomRock() -> TileType {
        return [TileType.blueRock, TileType.blackRock, TileType.greenRock].shuffled().first!
    }
    
    /// Create a random monster Tile instance
    static func randomMonster() -> TileType {
        return TileType.greenMonster(CombatTileData.monster())
    }
    
    /// Create default player funcion
    static func player() -> TileType {
        return .player(CombatTileData(hp: 1, attackDamage: 1))
    }
    
    //Create default monster
    static func greenMonster() -> TileType {
        return .greenMonster(CombatTileData.monster())
    }
    
    /// Return a string representing the texture's file name
    func textureString() -> String {
        switch self {
        case .blueRock:
            return TextueName.blueRock.rawValue
        case .blackRock:
            return TextueName.blackRock.rawValue
        case .greenRock:
            return TextueName.greenRock.rawValue
        case .player:
            return TextueName.player.rawValue
        case .empty:
            return TextueName.empty.rawValue
        case .exit:
            return TextueName.exit.rawValue
        case .greenMonster:
            return TextueName.greenMonster.rawValue
        }
    }
    
    
    enum TextueName: String {
        case blueRock
        case blackRock
        case greenRock
        case player = "player2"
        case empty
        case exit
        case greenMonster
    }
}
