//
//  MonsterDiesModel.swift
//  DownFall
//
//  Created by Billy on 12/3/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

enum MonsterDeathType: String, Codable, Hashable {
    case player
    case rune
    case dynamite
    case mineralSpirits
}

struct MonsterDies: Codable, Hashable {
    let tileType: TileType
    let tileCoord: TileCoord
    let deathType: MonsterDeathType
}
