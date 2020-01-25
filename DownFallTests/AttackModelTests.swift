//
//  AttackModelTests.swift
//  DownFallTests
//
//  Created by Katz, Billy on 1/15/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall

class AttackModelTests: XCTestCase {
    
    func testIsCharged() {
        //Given
        let frequency = 5
        var attackModel = AttackModel(type: .charges, frequency: frequency, range: .one, damage: 1, attacksThisTurn: 0, turns: 0, attacksPerTurn: 1, attackSlope: AttackSlope.diagonals, lastAttackTurn: 0)
        
        for turn in 0..<(frequency*2) {
            //When
            attackModel = attackModel.incrementTurns()
            
            
            //Verify
            // After "turn 4" (0,1,2,3,4), 5 turns have passed and this attack is charged
            // Only after an attackmodel attacks, do we reset the counter
            let expectedCharged = turn >= 4
            XCTAssertEqual(attackModel.isCharged, expectedCharged)
        }
        
        attackModel = attackModel.didAttack()
        XCTAssertFalse(attackModel.isCharged)
    }
    
    func testTurnsUntilNextAttack() {
        //Given
        var frequency = 1
        while (frequency < 10) {
            var attackModel = AttackModel(type: .charges, frequency: frequency, range: .one, damage: 1, attacksThisTurn: 0, turns: 0, attacksPerTurn: 1, attackSlope: AttackSlope.diagonals, lastAttackTurn: 0)
            
            for turn in 0..<frequency {
                //When
                attackModel = attackModel.incrementTurns()
                
                
                //Verify
                let actualTurnsUntilNextAttack = attackModel.turnsUntilNextAttack()
                let expectedTurnsUntilNextAttack = frequency - (turn+1)
                XCTAssertEqual(actualTurnsUntilNextAttack, expectedTurnsUntilNextAttack)
                
                // Example
                // AttackModels charges every 5 turns
                // Turn 0, before anything happens, there are 5 turns left
                // Turn 1, there are 4 turns left
                // Turn 2, 3 turns left
                // Turn 3, 2 turns left
                // Turn 4, 1 turn left
                // Turn 5, it is charged
                // there are technically 6 turns here, 0...5, but only 5 increments of turns
            }
            
            
            frequency += 1
        }
    }
    
    func testAttackModelAttacks() {
        //Given
        (4...6).forEach { frequency in
            var attackModel = AttackModel(type: .charges, frequency: frequency, range: .one, damage: 1, attacksThisTurn: 0, turns: 0, attacksPerTurn: 1, attackSlope: AttackSlope.diagonals, lastAttackTurn: 0)
            
            //When
            (0...7).forEach { _ in
                attackModel = attackModel.incrementTurns()
            }
            
            //Verify
            attackModel = attackModel.didAttack()
            XCTAssertEqual(attackModel.turnsUntilNextAttack(), frequency)
            XCTAssertFalse(attackModel.isCharged)
            
            
            //When
            (0...6).forEach { _ in
                attackModel = attackModel.incrementTurns()
            }
            
            //Verify
            attackModel = attackModel.didAttack()
            XCTAssertEqual(attackModel.turnsUntilNextAttack(), frequency)
            XCTAssertFalse(attackModel.isCharged)
            
            //When
            (0...8).forEach { _ in
                attackModel = attackModel.incrementTurns()
            }
            
            //Verify
            attackModel = attackModel.didAttack()
            XCTAssertEqual(attackModel.turnsUntilNextAttack(), frequency)
            XCTAssertFalse(attackModel.isCharged)
            
            //When
            (1..<frequency).forEach { _ in
                attackModel = attackModel.incrementTurns()
            }
            
            //Verify
            XCTAssertFalse(attackModel.isCharged)
            XCTAssertEqual(attackModel.turnsUntilNextAttack(), 1)
            attackModel = attackModel.incrementTurns()
            XCTAssertTrue(attackModel.isCharged)
        
        }
        
    }
}
