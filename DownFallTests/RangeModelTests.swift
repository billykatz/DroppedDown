//
//  RangeModelTests.swift
//  DownFallTests
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

import XCTest
@testable import DownFall

class RangeModelTests: XCTestCase {

    func testDivideSubRange() {
        let normalRange = RangeModel(lower: 0, upper: 90)
        for idx in 1..<5 {
            var array = Array(repeating: false, count: 90)
            for subrange in normalRange.divivdedIntoSubRanges(idx) {
                for number in 0..<90 {
                    if subrange.contains(number) {
                        array[number] = true
                    }
                }
            }
            
            XCTAssertFalse(array.contains(false), "Every number between lower and upper of original range is contained within the subranges. Subranges \(idx) \(normalRange.divivdedIntoSubRanges(idx))")
            
            for subRange in normalRange.divivdedIntoSubRanges(idx) {
                
                XCTAssertFalse(subRange.contains(-1))
                XCTAssertFalse(subRange.contains(90))
            }
        }
        
    }
    
    func testNext() {
        for _ in 0..<5 {
            let randomLower = Int.random(60)
            let randomUpper = Int.random(60) + randomLower
            let normalRange = RangeModel(lower: randomLower, upper: randomUpper)
            
            let randomNext = Int.random(15)
            let nextRange = normalRange.next(randomNext)
            let expectedNextRange = RangeModel(lower: randomUpper, upper: randomUpper+randomNext-1)
            XCTAssertEqual(nextRange, expectedNextRange)
        }
        
        
    }
}
