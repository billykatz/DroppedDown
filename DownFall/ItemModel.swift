//
//  ItemModel.swift
//  DownFall
//
//  Created by William Katz on 6/29/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct Item: Codable, Hashable {
    
    enum ItemType: String, Codable {
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
    var color: ShiftShaft_Color?
    
    var humanReadable: String {
        switch type {
        case .gold:
            return "Gold piece"
        case .gem:
            if let color = color {
                return "\(color.humanReadable) gem"
            } else {
                return "Gem"
            }
        }
    }
    
    static var randomColorGem: String {
        let options = ["blueCrystal", "purpleCrystal", "redCrystal"]
        return options.randomElement()!
    }
    
    var textureName: String {
        switch type {
        case .gold:
            return goldTextureName()
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
        return Item(type: .gold, amount: 0, color: nil)
    }
    
    static var gem: Item{
        return Item(type: .gem, amount: 1, color: nil)
    }
    
    static var gold: Item{
        return Item(type: .gold, amount: 1, color: nil)
    }
}
