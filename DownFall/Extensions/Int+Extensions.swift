//
//  Int+Extensions.swift
//  DownFall
//
//  Created by William Katz on 5/19/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation


public extension Int {
    
    /**
     * Returns a random integer between 0 and n-1.
     */
    static func random(_ n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    /**
     Returns a random integer between 0 and n-1 that is not the given number
     */
    static func random(_ n: Int, not: Int) -> Int {
        var retVal = random(n)
        while retVal == not {
            retVal = random(n)
        }
        return retVal
    }
    
    
    /**
     Returns a random integer between 0 and n-1 that is not the given number
     */
    static func random(lower: Int, upper: Int) -> Int {
        return Int(arc4random_uniform(UInt32(lower))) + lower
    }

}
