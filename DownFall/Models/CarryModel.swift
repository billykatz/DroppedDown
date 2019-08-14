//
//  Carry.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct CarryModel: Decodable, Equatable {
    let items: [Item]
    
    static let zero = CarryModel(items: [])
    
    var hasGem: Bool {
        return items.contains { $0.type == .gem }
    }
    
    var totalGold: Int {
        return items.filter({ $0.type == .gold }).count
    }
    
    func pay(_ price: Int) -> CarryModel {
        var newItems: [Item] = []
        var pricePaid = 0
        for item in items {
            if item.type == .gold && pricePaid < price {
                pricePaid += 1
            } else {
                newItems.append(item)
            }
        }
        
        return CarryModel(items: newItems)
    }
    
    func earn(_ money: Int) -> CarryModel {
        var newItems = items
        for _ in 0..<money {
            newItems.append(Item(type: .gold, range: .one))
        }
        return CarryModel(items: newItems)
    }

}
