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
    
    var goldMultiplier: Int {
        switch self {
        case .easy:
            return 3
        case .normal:
            return 2
        case .hard:
            return 1
        }
    }
}

