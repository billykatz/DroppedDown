//
//  RandomTests.swift
//  DownFallTests
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall

class RandomTests: XCTestCase {
    
    func testRandom() {
        for _ in 0..<100 {
            let upperRange = 5
            let randomNumber = Int.random(upperRange)
            let isWithinExpectedRange = randomNumber < upperRange && randomNumber >= 0
            XCTAssert(isWithinExpectedRange, "Random number is within expected range")
        }
    }
    
    func testRandomNot() {
        for _ in 0..<100 {
            let upperRange = 5
            let notNumber = Int.random(upperRange)
            let randomNumber = Int.random(upperRange, not: notNumber)
            let isWithinExpectedRange = randomNumber < upperRange && randomNumber >= 0
            XCTAssertTrue(isWithinExpectedRange, "Random number is within expected range")
            XCTAssertFalse(randomNumber == notNumber, "Random number \(randomNumber) does not equal the \(notNumber)")
        }
    }
    
    func testRandomLowerUpper() {
        for _ in 0..<100 {
            let lowerRange = 10
            let upperRange = 20
            let randomNumber = Int.random(lower: lowerRange, upper: upperRange)
            let isWithinExpectedRange = lowerRange <= randomNumber && randomNumber < upperRange
            XCTAssertTrue(isWithinExpectedRange, "Random number is within expected range")
        }
    }

}
