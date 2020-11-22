//
//  GKLinearCongruentialRandomSource+Extensions.swift
//  DownFall
//
//  Created by Katz, Billy on 11/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import GameplayKit

extension GKLinearCongruentialRandomSource {
    var positiveNextInt: Int {
        return abs(self.nextInt())
    }
}

