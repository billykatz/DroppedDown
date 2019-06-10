//
//  Carry.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct Item: Decodable, Equatable {
    enum ItemType: String, Decodable {
        case gold
        case gem
    }
    
    let type: ItemType
    let range: RangeModel
}

struct CarryModel: Decodable, Equatable {
    let item: [Item]
    
    static let zero = CarryModel(item: [])
    
    var hasGem: Bool {
        return item.contains { $0.type == .gem }
    }
}
