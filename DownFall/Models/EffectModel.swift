//
//  Effect.swift
//  DownFall
//
//  Created by Katz, Billy on 5/4/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

enum EffectType: String, Hashable, Codable {
    case buff
    case debuff
    case refill
    case rune
}

enum StatType: String, Hashable, Codable {
    case health
    case maxHealth
    case gems
    case pickaxe
}

struct EffectModel: Equatable, Hashable, Decodable {
    let kind: EffectType
    let stat: StatType
    let amount: Int
    let duration: Int
    var rune: Rune?
    var wasApplied: Bool = false
}
