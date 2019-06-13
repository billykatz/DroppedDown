//
//  Carry.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct Item: Decodable, Equatable, Hashable {
    enum ItemType: String, Decodable {
        case gold
        case gem = "gem1"
    }
    
    let type: ItemType
    let range: RangeModel
    
    var textureName: String {
        return type.rawValue
    }
    
    static var zero: Item {
        return Item(type: .gold, range: .zero)
    }
    
    static var gem: Item{
        return Item(type: .gem, range: .zero)
    }
    
    static var gold: Item{
        return Item(type: .gem, range: .zero)
    }
}

struct CarryModel: Decodable, Equatable {
    let item: [Item]
    
    static let zero = CarryModel(item: [])
    
    var hasGem: Bool {
        return item.contains { $0.type == .gem }
    }
}
