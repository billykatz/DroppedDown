//
//  Carry.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct CarryModel: Decodable, Equatable {
    let item: [Item]
    
    static let zero = CarryModel(item: [])
    
    var hasGem: Bool {
        return item.contains { $0.type == .gem }
    }
    
    var totalGold: Int {
        return item.filter({ $0.type == .gold }).count
    }
}
