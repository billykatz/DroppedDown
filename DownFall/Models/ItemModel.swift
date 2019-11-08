//
//  ItemModel.swift
//  DownFall
//
//  Created by William Katz on 6/29/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

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
        return Item(type: .gold, range: .zero)
    }
}
