//
//  RunManaging.swift
//  DownFall
//
//  Created by Katz, Billy on 8/1/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import GameKit

struct Area: Codable, Equatable {
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
    
    let depth: Int
    let type: AreaType
    
        
}

class RunModel: Codable, Equatable {
    static func == (lhs: RunModel, rhs: RunModel) -> Bool {
        return lhs.seed == rhs.seed
    }
    
    static let zero = RunModel(player: .zero, seed: 0, savedTiles: nil, areas: [], goalTracking: [])
    
    let seed: UInt64
    var player: EntityModel
    // save the tiles
    var savedTiles: [[Tile]]?
    
    /// Keep track of areas
    var areas: [Area] = []
    
    var goalTracking: [GoalTracking] = []
    
    lazy var randomSource: GKLinearCongruentialRandomSource = {
        return GKLinearCongruentialRandomSource(seed: seed)
    }()
    
    var depth: Int {
        return areas.last?.depth ?? 0
    }
    
    
    init(player: EntityModel, seed: UInt64, savedTiles: [[Tile]]?, areas: [Area], goalTracking: [GoalTracking]) {
        self.player = player
        self.seed = seed
        self.savedTiles = savedTiles
        self.areas = areas
        self.goalTracking = goalTracking
    }
    
    func saveGoalTracking(_ goalTracking: [GoalTracking]) {
        self.goalTracking = goalTracking
        
        /// update the last area with the goal tracking
        if let lastArea = areas.last,
           case var Area.AreaType.level(level) = lastArea.type {
            
            /// save the goal progress
            level.goalProgress = goalTracking
            
            // wrap it in a AreaType
            let newAreaType = Area.AreaType.level(level)
            
            /// get rid of the last area
            _ = areas.dropLast()
            
            /// replace it with one with saved goal tracking
            areas.append(Area(depth: lastArea.depth, type: newAreaType))
        }
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
    /// There is no more store so this always returns a level
    /// If there was no last level, it is a fresh run, so we return a store, for now.
    func nextArea() -> Area {
        if let lastArea = areas.last {
            switch lastArea.type {
            case .level(_):
                let newDepth = lastArea.depth + 1
                let newLevel = LevelConstructor.buildLevel(depth: newDepth, randomSource: randomSource)
                let newArea = Area(depth: newDepth, type: .level(newLevel))
                areas.append(newArea)
                return newArea
            }
        } else {
            /// Fresh run!
            let newDepth = 0
            let newLevel = LevelConstructor.buildLevel(depth: newDepth, randomSource: randomSource)
            let newArea = Area(depth: newDepth, type: .level(newLevel))
            areas.append(newArea)
            return newArea
        }
    }
}
