//
//  AttackModel+Extensions.swift
//  DownFallTests
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

@testable import Shift_Shaft

extension AttackSlope {
    static var south: AttackSlope {
        return AttackSlope(over: 0, up: -1)
    }
    
    static var sideways: [AttackSlope] {
        return [AttackSlope(over: -1, up: 0), AttackSlope(over: 1, up: 0)]
    }
    
    static var diagonals: [AttackSlope] {
        return [AttackSlope(over: -1, up: 1),
                AttackSlope(over: 1, up: 1),
                AttackSlope(over: -1, up: -1),
                AttackSlope(over: 1, up: -1)]
    }
}
