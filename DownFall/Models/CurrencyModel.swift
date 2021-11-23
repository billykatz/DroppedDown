//
//  CurrencyModel.swift
//  DownFall
//
//  Created by Katz, Billy on 7/20/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

enum Usage {
    case once
    case oneRun
    case permanent
    
    var message: String {
        switch self {
        case .once:
            return "One time use"
        case .oneRun:
            return "Passive ability for one run"
        case .permanent:
            return "Permanent upgrade"
        }
    }
}

enum Currency: String, CaseIterable, Codable, Hashable  {
    case gem = "crystals"
    
    var itemType: Item.ItemType {
        switch self {
        case .gem:
            return Item.ItemType.gem
        }
    }
}
