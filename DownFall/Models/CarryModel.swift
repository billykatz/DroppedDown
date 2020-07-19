//
//  Carry.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct CarryModel: Codable, Equatable {
    let items: [Item]
    
    static let zero = CarryModel(items: [])
    
    var hasGem: Bool {
        return items.contains { $0.type == .gem }
    }
    
    private var totalGold: Int {
        return items.filter({ $0.type == .gold }).first?.amount ?? 0
    }
    
    private var totalGem: Int {
        return items.filter({ $0.type == .gem }).first?.amount ?? 0
    }
    
    func total(in currency: Currency) -> Int {
        switch currency {
        case .gem:
            return totalGem
        case .gold:
            return totalGold
        }
    }
    
    func pay(_ price: Int, inCurrency currency: Currency) -> CarryModel {
        guard price <= total(in: currency) else { fatalError("You need to make sure oyu have enough funds to pay before calling this") }
        let itemType: Item.ItemType = currency == .gold ? .gold : .gem
        
        return CarryModel(items: items.map { item in
                if item.type == itemType {
                    return Item(type: itemType, amount: item.amount - price)
                } else {
                    return item
                }
            }
        )
        
    }
    
    func earn(_ money: Int, inCurrency currency: Currency) -> CarryModel {
        let itemType: Item.ItemType = currency == .gold ? .gold : .gem
        
        return CarryModel(items: items.map { item in
            if item.type == itemType {
                return Item(type: itemType, amount: item.amount + money)
            } else {
                return item
            }
        })
    }

}
