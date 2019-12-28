//
//  Rulebook.swift
//  DownFall
//
//  Created by William Katz on 11/7/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct Rulebook {
    static var winRule: Rule {
        switch Referee.level.type {
        case .first, .second, .third:
            return Win()
        case .boss:
            ()
        case .tutorial1:
            return Tutorial1Win()
        case .tutorial2:
            return Tutorial2Win()
        }
        
        fatalError("You must implement the win rule")
    }
}
