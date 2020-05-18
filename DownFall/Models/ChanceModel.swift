//
//  ChanceModel.swift
//  DownFall
//
//  Created by Katz, Billy on 5/18/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

struct TileTypeChanceModel {
    /// Assume that we are working with chances based on 100 outcomes
    let outcomes: Int
    let chances: [TileType: Int]
    
    init(chances: [TileType: Int]) {
        self.outcomes = chances.reduce(0, { prev, element in return prev + element.value })
        self.chances = chances
    }
    
    init(tileTypes: [TileType]) {
        let calculatedOutcomes = 100
        let calculatedChances = tileTypes.reduce([:], { (prev, tileType) -> [TileType: Int] in
            var newDict = prev
            newDict[tileType] = calculatedOutcomes/tileTypes.count
            return newDict
        })
        self.init(chances: calculatedChances)
    }
    
    func increaseChances(basedOn neighbors: [TileType]) -> TileTypeChanceModel {
        let baseIncrease = outcomes/20
        var newChances: [TileType: Int] = [:]
        var totalIncreasedChances = 0
        
        // create a new dictionary with types that exist in the neighbors
        // and increase their chance by 5%
        for neighbor in neighbors {
            let newChance = (chances[neighbor] ?? 0) + baseIncrease
            
            /// keep track of the outcomes we have claimed for the increased cases
            if newChances[neighbor] == nil {
                totalIncreasedChances += newChance
                newChances[neighbor] = (chances[neighbor] ?? 0) + baseIncrease
            } else {
                totalIncreasedChances += baseIncrease
                newChances[neighbor] = (newChances[neighbor] ?? 0) + baseIncrease
            }
            
        }
        
        
        var leftoverChances = 0
        
        for (tileType, chance) in chances {
            // this tileType did not get increased chances
            // re-evaluate their chance based on the total chance left and its original share of the pie
            if !newChances.contains(where: { $0.key == tileType }) {
                leftoverChances += chance
            }
        }
        
        for (tileType, chance) in chances {
            // this tileType did not get increased chances
            // re-evaluate their chance based on the total chance left and its original share of the pie
            if !newChances.contains(where: { $0.key == tileType }) {
                
                /// This is the percentage of shares leftover ratio'd to account for the leftover tile types
                /// Eg. if blue and red had a chance of 25 and brown had a chance of 10
                /// Now, blue gets 25/60 and red gets 25/60 and brown gets 10/60
                let newSharePercentage = min(1.0, Float(chance)/Float(leftoverChances))
                
                /// Now multiply that share by the actual outcomes that we have left
                let newShare = newSharePercentage * Float(outcomes - totalIncreasedChances)
                newChances[tileType] = Int(newShare)
            }
        }
        
        return TileTypeChanceModel(chances: newChances)
    }
}
