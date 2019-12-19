//
//  Difficulty.swift
//  DownFall
//
//  Created by William Katz on 12/24/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

enum Difficulty: Int, CaseIterable {
    case easy = 1
    case normal = 2
    case hard = 3
    case tutorial1 = 4
    case tutorial2 = 5
    
    func maxExpectedMonsters(for boardSize: Int) -> Int {
        return max(Int(boardSize * self.rawValue / 2), 1)
    }
}

