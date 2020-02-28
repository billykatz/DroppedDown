//
//  BossController.swift
//  DownFall
//
//  Created by Katz, Billy on 2/27/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

class BossController {
    
    init() {
        
        Dispatch.shared.register { [weak self] (input) in
            self?.handle(input)
        }
    }
    
    func handle(_ input: Input) {
        
    }
    
}
