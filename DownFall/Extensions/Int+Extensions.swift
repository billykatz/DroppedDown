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
     Returns a random integer between 0 and n-1 that is not in a set of Ints
     */
    static func random(_ n: Int, notInSet set: Set<Int>) -> Int {
        var retVal = random(n)
        while set.contains(retVal) {
            retVal = random(n)
        }
        return retVal
    }

    
    
    /**
     Returns a random integer between between the lower and upper bound.
     */
    static func random(lower: Int, upper: Int) -> Int {
        return Int(arc4random_uniform(UInt32(lower))) + lower
    }
    
    /**
     Returns a random integer between the lower and upper bound rounded to the nearest interval
     */
    static func random(lower: Int, upper: Int, interval: Int) -> Int {
        let randomInt = Int(arc4random_uniform(UInt32(lower))) + lower
        let multipleOfInterval = randomInt / interval
        return multipleOfInterval * interval
    }
    

}
