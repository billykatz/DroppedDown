//
//  AreaModel.swift
//  DownFall
//
//  Created by Billy on 9/17/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

enum AreaType: Codable, Equatable {
    case level(Level)
    
    enum CodingKeys: String, CodingKey {
        case base
        case levelData
    }
    
    private enum Base: String, Codable {
        case level
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case  .level:
            let data = try container.decode(Level.self, forKey: .levelData)
            self = .level(data)
        }
    }
    
    /// This implementation is written about in https://medium.com/@hllmandel/codable-enum-with-associated-values-swift-4-e7d75d6f4370
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .level(let levelData):
            try container.encode(Base.level, forKey: .base)
            try container.encode(levelData, forKey: .levelData)
        }
    }

}

struct Area: Codable, Equatable {
    let depth: Int
    let type: AreaType
        
}
