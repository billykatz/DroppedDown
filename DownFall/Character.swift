//
//  Character.swift
//  DownFall
//
//  Created by Billy on 10/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

enum Character: String, Codable {
    case teri
    
    var textureName: String {
        return "\(rawValue)-character"
    }
    
    var humanReadable: String {
        switch self {
        case .teri:
            return "Teri"
        }
    }
}
