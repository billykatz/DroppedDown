//
//  TileTypeTest+Extensions.swift
//  DownFallTests
//
//  Created by William Katz on 6/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
@testable import DownFall

extension AttackModel {
    static var pickaxe = AttackModel(type: .targets,
                                     frequency: 1,
                                     range: .one,
                                     damage: 1,
                                     directions: [Direction.south],
                                     attacksThisTurn: 0,
                                     turns: 1,
                                     attacksPerTurn: 1)
    
    static var swipe = AttackModel(type: .targets,
                                   frequency: 1,
                                   range: .one,
                                   damage: 1,
                                   directions: [.east, .west],
                                   attacksThisTurn: 0,
                                   turns: 1,
                                   attacksPerTurn: 1)
    
    static var scream = AttackModel(type: .areaOfEffect,
                                    frequency: 3,
                                    range: .init(lower: 1, upper: 10),
                                    damage: 1,
                                    directions: [.northEast, .northWest, .southEast, .southWest],
                                    attacksThisTurn: 0,
                                    turns: 1,
                                    attacksPerTurn: 1)
}

extension TileType {
    static var deadMonster: TileType {
        return TileType.monster(EntityModel(originalHp:0,
                                            hp: 0,
                                            name: "Gloop",
                                            attack: .zero,
                                            type: .monster,
                                            carry: .zero,
                                            animations: .zero,
                                            abilities: [])
        )
    }
    
    
    static var deadPlayer: TileType {
        return createPlayer(originalHp: 1, hp: 0)
    }
    
    
    static var monsterThatHasAttacked: TileType {
        return createMonster(attack: AttackModel(type: .targets,
                                                 frequency: 1,
                                                 range: .one,
                                                 damage: 1,
                                                 directions: [.east, .west],
                                                 attacksThisTurn: 1,
                                                 turns: 1,
                                                 attacksPerTurn: 1))
    }
    
    static func createMonster(originalHp: Int = 1,
                              hp: Int = 1,
                              name: String = "Gloop",
                              attack: AttackModel = AttackModel(type: .targets,
                                                                frequency: 1,
                                                                range: .one,
                                                                damage: 1,
                                                                directions: [.east, .west],
                                                                attacksThisTurn: 0,
                                                                turns: 1,
                                                                attacksPerTurn: 1),
                              type: EntityModel.EntityType = .monster,
                              carry: CarryModel = .zero,
                              animations: AllAnimationsModel = .zero,
                              abilities: [AnyAbility] = []) -> TileType {
        return TileType.monster(EntityModel(originalHp: originalHp,
                                            hp: hp,
                                            name: name,
                                            attack: attack,
                                            type: type,
                                            carry: carry,
                                            animations: animations,
                                            abilities: abilities))
    }
    
    static func createPlayer(originalHp: Int = 1,
                             hp: Int = 1,
                             name: String = "player2",
                             attack: AttackModel = AttackModel.pickaxe,
                             type: EntityModel.EntityType = .player,
                             carry: CarryModel = .zero,
                             animations: AllAnimationsModel = .zero,
                             abilities: [AnyAbility] = []) -> TileType {
        return TileType.player(EntityModel(originalHp: originalHp,
                                           hp: hp,
                                           name: name,
                                           attack: attack,
                                           type: type,
                                           carry: carry,
                                           animations: animations,
                                           abilities: abilities))
        
    }
    
    static var strongMonster: TileType {
        return createMonster(originalHp: 2, hp: 2)
    }
    
    static var normalMonster: TileType {
        return createMonster()
    }
    
    
    static var pickAxeMonster: TileType {
        return createMonster(attack: AttackModel.pickaxe)
    }
    
    static var batMonster: TileType {
        return createMonster(attack: AttackModel.scream)
    }
    
    
    static var  healthyMonster: TileType {
        return createMonster(originalHp: 5, hp: 5)
    }
    
    
    static var normalPlayer: TileType {
        return createPlayer()
    }
    
    
    static var strongPlayer: TileType {
        return createPlayer(originalHp: 2,
                            hp: 2,
                            attack: AttackModel(type: .targets,
                                                frequency: 1,
                                                range: .one,
                                                damage: 2,
                                                directions: [.south],
                                                attacksThisTurn: 0,
                                                turns: 1,
                                                attacksPerTurn: 1))
    }
}
