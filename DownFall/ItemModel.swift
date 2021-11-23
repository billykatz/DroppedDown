//
//  ItemModel.swift
//  DownFall
//
//  Created by William Katz on 6/29/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct Item: Codable, Hashable {
    
    enum ItemType: String, Codable {
        case gem
        
        var currencyType: Currency {
            switch self {
            case .gem:
                return Currency.gem
            }
        }
    }
    
    let type: ItemType
    let amount: Int
    var color: ShiftShaft_Color?
    
    var humanReadable: String {
        switch type {
        case .gem:
            if let color = color {
                return "\(color.humanReadable) gem"
            } else {
                return "Gem"
            }
        }
    }
    
    static var randomColorGem: String {
        let options = ["blueCrystal", "purpleCrystal", "redCrystal", "greenCrystal", "brownCrystal"]
        return options.randomElement()!
    }
    
    var textureName: String {
        switch type {
        case .gem:
            switch color {
            case .blue:
                return "blueCrystal"
            case .red:
                return "redCrystal"
            case .brown:
                return "brownCrystal"
            case .purple:
                return "purpleCrystal"
            case .green:
                return "greenCrystal"
            case .blood:
                return ""
            case .none:
                return "crystals"
            }
        }
    }
    
    static var zero: Item {
        return Item(type: .gem, amount: 0, color: nil)
    }
    
    static var gem: Item{
        return Item(type: .gem, amount: 1, color: nil)
    }

}
