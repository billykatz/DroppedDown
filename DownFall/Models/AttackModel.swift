//
//  Attack.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct AttackModel: Equatable, Decodable {
    let frequency: Int
    let range: RangeModel
    let damage: Int
    let directions: [Direction]
    var hasAttacked: Bool = false
    
    static let zero = AttackModel(frequency: 0, range: RangeModel(lower: 0, upper: 0), damage: 0, directions: [], hasAttacked: false)
    
    var canAttack: Bool { return !hasAttacked }
}
