//
//  TestHelpers.swift
//  DownFallTests
//
//  Created by William Katz on 4/1/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
@testable import DownFall

extension TileType {
    static var mouthyMonster: TileType {
        return TileType.greenMonster(CombatTileData(hp: 1, attacksThisTurn: 0, weapon: .mouth, hasGem: false))
    }
    
    static var pickAxeMonster: TileType {
        return TileType.greenMonster(CombatTileData(hp: 1, attacksThisTurn: 0, weapon: .pickAxe, hasGem: false))
    }
    
    static var strongPlayer: TileType {
        return TileType.player(CombatTileData(hp: 3, attacksThisTurn: 0, weapon: .strongPickAxe, hasGem: false))
    }
    
    static var deadPlayer: TileType {
        return TileType.player(CombatTileData(hp: 0, attacksThisTurn: 0, weapon: .strongPickAxe, hasGem: false))
    }
    
    static var strongMonster: TileType {
        return TileType.player(CombatTileData(hp: 3, attacksThisTurn: 0, weapon: .mouth, hasGem: false))
    }
    
    static var normalMonster: TileType {
        return TileType.player(CombatTileData(hp: 2, attacksThisTurn: 0, weapon: .mouth, hasGem: false))
    }
    
    static var monsterThatHasAttacked: TileType {
        return TileType.greenMonster(CombatTileData(hp: 1, attacksThisTurn: 1, weapon: .mouth, hasGem: false))
    }

}

extension CombatTileData {
    func subtractHP(_ amount: Int) -> CombatTileData {
        return CombatTileData(hp: self.hp - amount, attacksThisTurn: self.attacksThisTurn, weapon: self.weapon, hasGem: self.hasGem)
    }
}

extension Weapon {
    static var strongPickAxe: Weapon {
        return Weapon(range: 1, damage: 3, direction: [.south], attackType: .melee, durability: .unlimited, chargeTime: 0, currentCharge: 0)
    }
}
