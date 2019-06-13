//
//  TileTypeTest+Extensions.swift
//  DownFallTests
//
//  Created by William Katz on 6/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
@testable import DownFall

extension TileType {
    static var deadMonster: TileType {
        return TileType.monster(EntityModel(hp: 0, name: "Gloop", attack: AttackModel(frequency: 0, range: .one, damage: 1, directions: [.east, .west], animationPaths: [], hasAttacked: false), type: .monster, carry: .zero))
    }
    
    
    static var deadPlayer: TileType {
        return TileType.monster(EntityModel(hp: 0, name: "player2", attack: AttackModel(frequency: 0, range: .one, damage: 1, directions: [.east, .west], animationPaths: [], hasAttacked: false), type: .player, carry: .zero))
    }

    
    static var monsterThatHasAttacked: TileType {
        return TileType.monster(EntityModel(hp: 2, name: "Gloop", attack: AttackModel(frequency: 0, range: .one, damage: 1, directions: [.east, .west], animationPaths: [], hasAttacked: true), type: .monster, carry: .zero))
    }
    
    
    static var strongMonster: TileType {
        return TileType.monster(EntityModel(hp: 2, name: "Gloop", attack: AttackModel(frequency: 0, range: .one, damage: 1, directions: [.east, .west], animationPaths: [], hasAttacked: false), type: .monster, carry: .zero))
    }
    
    static var normalMonster: TileType {
        return TileType.monster(EntityModel(hp: 1, name: "Gloop", attack: AttackModel(frequency: 0, range: .one, damage: 1, directions: [.east, .west], animationPaths: [], hasAttacked: false), type: .monster, carry: .zero))
    }
    
    static var  healthyMonster: TileType {
        return TileType.monster(EntityModel(hp: 5, name: "Gloop", attack: AttackModel(frequency: 0, range: .one, damage: 1, directions: [.east, .west], animationPaths: [], hasAttacked: false), type: .monster, carry: .zero))
    }
    
    
    static var strongPlayer: TileType {
        return TileType.monster(EntityModel(hp: 2, name: "playe2", attack: AttackModel(frequency: 0, range: .one, damage: 2, directions: [.south], animationPaths: [], hasAttacked: false), type: .player, carry: .zero))
    }
}
