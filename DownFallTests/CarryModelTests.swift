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
        let gemTotal = 3
        let gemItem = Item(type: .gem, amount: gemTotal)
        let playerCarry = CarryModel(items: [gemItem])
        
        XCTAssertEqual(playerCarry.total(in: .gem), gemTotal)
    }
    
    func testPay() {
        let gemTotal = 3
        let gemItem = Item(type: .gem, amount: gemTotal)
        let playerCarry = CarryModel(items: [gemItem])
        let newCarry = playerCarry.pay(2, inCurrency: .gem)
        
        XCTAssertEqual(newCarry.total(in: .gem), 1)
    }
    
    func testEarn() {
        let gemTotal = 3
        let gemItem = Item(type: .gem, amount: gemTotal)
        let playerCarry = CarryModel(items: [gemItem])
        let newCarry = playerCarry.earn(9, inCurrency: .gem)
        
        XCTAssertEqual(newCarry.total(in: .gem), 12)
    }
}
