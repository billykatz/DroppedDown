//
//  Difficulty.swift
//  DownFall
//
//  Created by William Katz on 12/24/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

enum Difficulty: Double {
    case easy = 1
    case normal = 1.5
    case hard = 2.0
    
    func maxExpectedMonsters(for boardSize: Int) -> Int {
        return max(Int(Double(boardSize) * self.rawValue / 2.0), 1)
    }
}

