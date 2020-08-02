//
//  RunManaging.swift
//  DownFall
//
//  Created by Katz, Billy on 8/1/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

struct Area: Codable {
    enum AreaType: Codable {
        case level(Level)
        case store([StoreOffer])
        
        enum CodingKeys: String, CodingKey {
            case base
            case levelData
            case storeOffers
        }
        
        private enum Base: String, Codable {
            case level
            case store
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let base = try container.decode(Base.self, forKey: .base)
            
            switch base {
            case  .level:
                let data = try container.decode(Level.self, forKey: .levelData)
                self = .level(data)
            case .store:
                let data = try container.decode([StoreOffer].self, forKey: .storeOffers)
                self = .store(data)
            }
        }
        
        /// This implementation is written about in https://medium.com/@hllmandel/codable-enum-with-associated-values-swift-4-e7d75d6f4370
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .level(let levelData):
                try container.encode(Base.level, forKey: .base)
                try container.encode(levelData, forKey: .levelData)
            case .store(let offers):
                try container.encode(Base.store, forKey: .base)
                try container.encode(offers, forKey: .storeOffers)
            }
        }

    }
    
    let depth: Int
    let type: AreaType
    
        
}

class RunModel: Codable {
    let player: EntityModel
    var depth: Int
    
    init(player: EntityModel, depth: Int) {
        self.player = player
        self.depth = depth
    }
 
    /// Keep track of levels
    private var levels: [Level] = []
    
    /// Keep track of areas
    private var areas: [Area] = []
    
    var goalTracking: [GoalTracking] = []
    
    func saveGoalTracking(_ goalTracking: [GoalTracking]) {
        self.goalTracking = goalTracking
    }
    
    /// Return the level that corresponds with the depth
    /// If that level has not been built yet, then build it, append it to our private level store, and return the newly built level
    func currentArea() -> Area {
        guard areas.count > 0, let currentArea = areas.last else {
            return nextArea()
        }
        return currentArea
    }
    
    
    /// Creates a new area and appends to the internal array of Areas
    /// If the last area was a level, it returns a store, and we increment the depth
    /// Else if the last level was a store, it returns a level
    /// If there was no last level, it is a fresh run, so we return a store, for now.
    func nextArea() -> Area {
        if let lastArea = areas.last {
            switch lastArea.type {
            case .level(_):
                let newDepth = lastArea.depth + 1
                let newOffers = StoreOffer.storeOffer(depth: newDepth)
                let newArea = Area(depth: newDepth, type: .store(newOffers))
                areas.append(newArea)
                return newArea
            case .store(_):
                let sameDepth = lastArea.depth
                let newLevel = LevelConstructor.buildLevel(depth: sameDepth)
                let newArea = Area(depth: sameDepth, type: .level(newLevel))
                areas.append(newArea)
                return newArea
            }
        } else {
            /// Fresh run!
            let newDepth = 0
            let newOffers = StoreOffer.storeOffer(depth: newDepth)
            let newArea = Area(depth: newDepth, type: .store(newOffers))
            areas.append(newArea)
            return newArea
        }
    }
}
