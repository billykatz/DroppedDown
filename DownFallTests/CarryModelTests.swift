//
//  CarryModelTests.swift
//  DownFallTests
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import Shift_Shaft

class CarryModelTests: XCTestCase {
    func testTotal() {
        let goldTotal = 30
        let goldItem = Item(type: .gold, amount: goldTotal)
        let gemTotal = 3
        let gemItem = Item(type: .gem, amount: gemTotal)
        let playerCarry = CarryModel(items: [goldItem, gemItem])
        
        XCTAssertEqual(playerCarry.total(in: .gold), goldTotal)
        XCTAssertEqual(playerCarry.total(in: .gem), gemTotal)
    }
    
    func testPay() {
        let goldTotal = 30
        let goldItem = Item(type: .gold, amount: goldTotal)
        let gemTotal = 3
        let gemItem = Item(type: .gem, amount: gemTotal)
        let playerCarry = CarryModel(items: [goldItem, gemItem])

        var newCarry = playerCarry.pay(25, inCurrency: .gold)
        XCTAssertEqual(newCarry.total(in: .gold), 5)
        
        newCarry = newCarry.pay(2, inCurrency: .gem)
        XCTAssertEqual(newCarry.total(in: .gem), 1)
        
    }
    
    func testEarn() {
        let goldTotal = 30
        let goldItem = Item(type: .gold, amount: goldTotal)
        let gemTotal = 3
        let gemItem = Item(type: .gem, amount: gemTotal)
        let playerCarry = CarryModel(items: [goldItem, gemItem])

        var newCarry = playerCarry.earn(45, inCurrency: .gold)
        XCTAssertEqual(newCarry.total(in: .gold), 75)
        
        newCarry = newCarry.earn(9, inCurrency: .gem)
        XCTAssertEqual(newCarry.total(in: .gem), 12)
        
    }
}
