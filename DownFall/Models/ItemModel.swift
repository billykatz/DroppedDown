//
//  ItemModel.swift
//  DownFall
//
//  Created by William Katz on 6/29/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct Item: Decodable, Hashable {
    enum ItemType: String, Decodable {
        case gold
        case gem
        
        var currencyType: Currency {
            switch self {
            case .gold:
                return Currency.gold
            case .gem:
                return Currency.gem
            }
        }
    }
    
    let type: ItemType
    let amount: Int
    
    var textureName: String {
        switch type {
        case .gold:
            return goldTextureName()
        case .gem:
            return "gem2"
        }
    }
    
    func goldTextureName() -> String {
        switch amount {
        case 1...5:
            return "1-5gold"
        case 6...10:
            return "6-10gold"
        case 10...15:
            return "11-15gold"
        case 16...Int.max:
            return "16-20gold"
        default:
            fatalError("You messed up. Gold must more than 0")
        }
    }
    
    static var zero: Item {
        return Item(type: .gold, amount: 0)
    }
    
    static var gem: Item{
        return Item(type: .gem, amount: 1)
    }
    
    static var gold: Item{
        return Item(type: .gold, amount: 1)
    }
}
