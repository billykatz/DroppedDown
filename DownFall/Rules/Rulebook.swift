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
        switch GameScope.shared.difficulty {
        case .easy, .normal, .hard:
            return Win()
        case .tutorial1, .tutorial2:
            return Tutorial1Win()
        }
    }
}
