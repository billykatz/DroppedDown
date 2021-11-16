//
//  BossController.swift
//  DownFall
//
//  Created by Billy on 11/16/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

enum BossStateType {
    case targetEat
}

struct BossState {
    let bossStateType: BossStateType
}

class BossController {
    
    var state: BossState
    let level: Level
    
    var isBossLevel: Bool {
        // 9 is actually 10
        return level.depth == 9
    }
    
    init(level: Level) {
        self.state = BossState(bossStateType: .targetEat)
        self.level = level
        // only listen for inputs if this is the boss level
        guard level.depth == 9 else { return }
        
        Dispatch.shared.register { [weak self] input in
            self?.handleInput(input)
        }
    }
    
    func handleInput(_ input: Input) {
        
    }
}
