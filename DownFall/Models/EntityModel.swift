//
//  Monster.swift
//  DownFall
//
//  Created by William Katz on 5/18/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

protocol ResetsAttacks {
    func resetAttacks() -> EntityModel
}

struct EntityModel: Equatable, Decodable {
        
    enum EntityType: String, Decodable {
        case dragon
        case monster
        case player
    }
    
    static let zero: EntityModel = EntityModel(hp: 0, name: "null", attack: .zero, type: .monster, carry: .zero, animations: .zero)
    
    let hp: Int
    let name: String
    let attack: AttackModel
    let type: EntityType
    let carry: CarryModel
    let animations: AllAnimationsModel
    
    
}

extension EntityModel: ResetsAttacks {
    func resetAttacks() -> EntityModel {
        let newAttackModel = AttackModel(frequency: self.attack.frequency,
                                         range: self.attack.range,
                                         damage: self.attack.damage,
                                         directions: self.attack.directions,
                                         hasAttacked: false)
        
        return EntityModel(hp: self.hp,
                           name: self.name,
                           attack: newAttackModel,
                           type: self.type,
                           carry: self.carry,
                           animations: self.animations)
    }
}

extension EntityModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(hp)
        hasher.combine(name)
    }
}

struct EntitiesModel: Equatable, Decodable {
    let entities: [EntityModel]
}
