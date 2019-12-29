//
//  LevelType.swift
//  DownFall
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

enum LevelType: Int, Codable, CaseIterable {
    case first
    case second
    case third
    case boss
    case tutorial1
    case tutorial2
    
    static var gameCases: [LevelType] = [.first, .second, .third]
    static var tutorialCases: [LevelType] = [.tutorial1, .tutorial2]
}
