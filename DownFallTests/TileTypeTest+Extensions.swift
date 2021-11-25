//
//  TileTypeTest+Extensions.swift
//  DownFallTests
//
//  Created by William Katz on 6/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
@testable import Shift_Shaft

extension AttackModel {
    static var pickaxe = AttackModel(type: .targets,
                                     frequency: 1,
                                     range: .one,
                                     damage: 1,
                                     attacksThisTurn: 0,
                                     turns: 1,
                                     attacksPerTurn: 1,
                                     attackSlope: [AttackSlope.south])
    
    
    static var swipe = AttackModel(type: .targets,
                                   frequency: 1,
                                   range: .one,
                                   damage: 1,
                                   attacksThisTurn: 0,
                                   turns: 1,
                                   attacksPerTurn: 1,
                                   attackSlope: AttackSlope.sideways)
    
    static var scream = AttackModel(type: .areaOfEffect,
                                    frequency: 3,
                                    range: .init(lower: 1, upper: 10),
                                    damage: 1,
                                    attacksThisTurn: 0,
                                    turns: 1,
                                    attacksPerTurn: 1,
                                    attackSlope: AttackSlope.diagonals)
}

extension TileType {
    static var deadRat: TileType {
        return TileType.monster(EntityModel(originalHp:0,
                                            hp: 0,
                                            name: "Gloop",
                                            attack: .zero,
                                            type: .rat,
                                            carry: .zero,
                                            animations: [],
                                            effects: [],
                                            dodge:0,
                                            luck: 0,
                                            killedBy: nil)
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
                                                 attacksThisTurn: 1,
                                                 turns: 1,
                                                 attacksPerTurn: 1,
                                                 attackSlope: AttackSlope.sideways))
    }
    
    static func createMonster(originalHp: Int = 1,
                              hp: Int = 1,
                              name: String = "Rat",
                              attack: AttackModel = AttackModel(type: .targets,
                                                                frequency: 1,
                                                                range: .one,
                                                                damage: 1,
                                                                attacksThisTurn: 0,
                                                                turns: 1,
                                                                attacksPerTurn: 1,
                                                                attackSlope: AttackSlope.sideways),
                              type: EntityModel.EntityType = .rat,
                              carry: CarryModel = .zero,
                              animations: [AnimationModel] = []) -> TileType {
        return TileType.monster(EntityModel(originalHp: originalHp,
                                            hp: hp,
                                            name: name,
                                            attack: attack,
                                            type: type,
                                            carry: carry,
                                            animations: animations,
                                            effects: [],
                                            dodge:0,
                                            luck: 0,
                                            killedBy: nil)
        )
    }
    
    static func createPlayer(originalHp: Int = 1,
                             hp: Int = 1,
                             name: String = "player2",
                             attack: AttackModel = AttackModel.pickaxe,
                             type: EntityModel.EntityType = .player,
                             carry: CarryModel = .zero,
                             animations: [AnimationModel] = []) -> TileType {
        return TileType.player(EntityModel(originalHp: originalHp,
                                           hp: hp,
                                           name: name,
                                           attack: attack,
                                           type: type,
                                           carry: carry,
                                           animations: animations,
                                           pickaxe: Pickaxe(runeSlots: 0, runes: []),
                                           effects: [],
                                           dodge:0,
                                           luck: 0,
                                           killedBy: nil)
        )
        
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
                                                attacksThisTurn: 0,
                                                turns: 1,
                                                attacksPerTurn: 1,
                                                attackSlope: [AttackSlope.south]))
    }
}
