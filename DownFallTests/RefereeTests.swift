//
//  RefereeTests.swift
//  DownFallTests
//
//  Created by William Katz on 12/29/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import XCTest
@testable import Shift_Shaft

class RefereeTests: XCTestCase {
    
    let mockBoard = Board.build(size: 10)
    var allBlack: Builder!
    var allGreen: Builder!
    var player: Builder!
    var exit: Builder!
    
    override func setUp() {
        super.setUp()
        
        allBlack = all(Tile.blueRock, mockBoard)
        allGreen = all(Tile.greenRock, mockBoard)
        player = xTiles(1, Tile(type: .playerWithGem), mockBoard)
        exit = xTiles(1, Tile(type: .exit(blocked: false)), mockBoard)
    }
    
    func testRefereeGameWin() {
        
        //same for all tests in this function
        let expectedOutput = Input(.gameWin(0))
        
        let gameWin = allBlack >>> win(mockBoard)
        let gameBoard = gameWin(mockBoard)
        let actualOutput = Referee().enforceRules(gameBoard.tiles)
        XCTAssertEqual(expectedOutput, actualOutput)
        
        let gameWin2 = (allGreen >>> player) >>> win(mockBoard)
        let gameBoard2 = gameWin2(mockBoard)
        let actualOutput2 = Referee().enforceRules(gameBoard2.tiles)
        XCTAssertEqual(expectedOutput, actualOutput2)

        let gameWin3 = (allGreen >>> exit) >>> win(mockBoard)
        let gameBoard3 = gameWin3(mockBoard)
        let actualOutput3 = Referee().enforceRules(gameBoard3.tiles)
        XCTAssertEqual(expectedOutput, actualOutput3)
    }
    
    func testRefereeNonGameLose() {
        
        let gameLose = Input(.gameLose(killedBy: nil))
        // If the player can attack we dont lose (yet)
        var tiles = [[Tile.greenRock, .blueRock, .blueRock, .greenRock],
                     [.blueRock, Tile(type: .normalMonster), .exit, .greenRock],
                     [.greenRock, Tile(type: .normalPlayer), .blueRock, .blueRock],
                     [.blueRock, .purpleRock, .greenRock, .greenRock]]
        var actualOutput = Referee().enforceRules(tiles)
        
        XCTAssertNotEqual(actualOutput, gameLose, "If the player can attack, we don't lose")
        
        //the player can rotate once to win, this is not a lose
        tiles = [[.greenRock, .blueRock, .blueRock, .greenRock],
                 [.blueRock, .purpleRock, .purpleRock, .greenRock],
                 [.greenRock, Tile(type: .normalPlayer), .exit, .purpleRock],
                 [.blueRock, .purpleRock, .greenRock, .greenRock]]
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertNotEqual(actualOutput, gameLose, "If the player can rotate to win, we don't lose")
        
        //the player can rotate twice to win, this is not a lose
        tiles = [[.greenRock, .blueRock, .blueRock, .greenRock],
                 [.blueRock, .purpleRock, .purpleRock, .greenRock],
                 [.greenRock, Tile(type: .normalPlayer), .blueRock, .purpleRock],
                 [.blueRock, .exit, .greenRock, .greenRock]]
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertNotEqual(actualOutput, gameLose, "If the player can rotate to win, we don't lose")
        
        //the player can rotate to win once to win, this is not a lose
        tiles = [[.greenRock, .blueRock, .blueRock, .greenRock],
                 [.blueRock, .purpleRock, .purpleRock, .greenRock],
                 [.exit, Tile(type: .normalPlayer), .blueRock, .purpleRock],
                 [.blueRock, .blueRock, .greenRock, .greenRock]]
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertNotEqual(actualOutput, gameLose, "If the player can rotate to win, we don't lose")
        
        //the player can rotate to kill a monster
        tiles = [[.greenRock, .blueRock, .blueRock, .exit],
                 [.blueRock, .purpleRock, .purpleRock, .greenRock],
                 [.greenRock, Tile(type: .normalPlayer), Tile(type: .normalMonster), .purpleRock],
                 [.blueRock, .blueRock, .greenRock, .greenRock]]
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertNotEqual(actualOutput, gameLose, "If the player can rotate to attack, we don't lose")
        
        //the player can rotate to kill a monster
        tiles = [[.greenRock, .blueRock, .blueRock, .exit],
                 [.blueRock, .purpleRock, .purpleRock, .greenRock],
                 [.greenRock, Tile(type: .normalPlayer), .blueRock, .purpleRock],
                 [.blueRock, Tile(type: .normalMonster), .greenRock, .greenRock]]
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertNotEqual(actualOutput, gameLose, "If the player can rotate to attack, we don't lose")
        
        //the player can rotate to kill a monster
        tiles = [[.greenRock, .blueRock, .blueRock, .exit],
                 [.blueRock, .purpleRock, .purpleRock, .greenRock],
                 [Tile(type: .normalMonster), Tile(type: .normalPlayer), .blueRock, .purpleRock],
                 [.blueRock, .blueRock, .greenRock, .greenRock]]
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertNotEqual(actualOutput, gameLose, "If the player can rotate to attack, we don't lose")

        
    }

    func testRefereePlayerAttacks() {
        var tiles = [[Tile.blueRock, Tile(type: .normalMonster), .blueRock],
                     [.purpleRock, Tile(type: .normalPlayer), .exit],
                     [.purpleRock, .greenRock, .greenRock]]
        var expectedOutput = Input(.attack(attackType: .targets ,
                                           attacker: TileCoord(1, 1),
                                           defender: TileCoord(0, 1),
                                           affectedTiles: [TileCoord(0,1)], dodged: false, attackerIsPlayer: true))
        let actualOutput = Referee().enforceRules(tiles)
        XCTAssertEqual(expectedOutput, actualOutput)
        
        tiles = [[.purpleRock, .blueRock, .blueRock],
                 [.exit, .blueRock, Tile(type: .normalMonster)],
                 [.greenRock, .greenRock, Tile(type: .normalPlayer)]]
        expectedOutput = Input(.attack(attackType: .targets ,
                      attacker: TileCoord(2, 2),
                      defender: TileCoord(1, 2),
                      affectedTiles: [TileCoord(1,2)], dodged: false, attackerIsPlayer: true))
        let actualOutput2 = Referee().enforceRules(tiles)
        XCTAssertEqual(expectedOutput, actualOutput2)

    }

    func testRefereeMonsterAttacks() {
        var tiles = [[Tile(type: .normalPlayer), .blueRock, .blueRock],
                     [Tile(type: .pickAxeMonster), .exit, .blueRock],
                     [.blueRock, .blueRock, .greenRock]]
        var expectedOutput = Input(.attack(attackType: .targets ,
                      attacker: TileCoord(1, 0),
                      defender: TileCoord(0, 0),
                      affectedTiles: [TileCoord(0, 0)], dodged: false, attackerIsPlayer: false))

        var actualOutput = Referee().enforceRules(tiles)
        XCTAssertEqual(expectedOutput, actualOutput, "Pick axe monsters attack down")
        
        tiles = [[Tile.blueRock, .blueRock, .blueRock],
                 [Tile(type: .pickAxeMonster), .exit, Tile(type: .normalPlayer)],
                 [.greenRock, .greenRock, Tile(type: .pickAxeMonster)]]
        expectedOutput = Input(.attack(attackType: .targets ,
                                           attacker: TileCoord(2, 2),
                                           defender: TileCoord(1, 2),
                                           affectedTiles: [TileCoord(1, 2)], dodged: false, attackerIsPlayer: false))

        actualOutput = Referee().enforceRules(tiles)
        XCTAssertEqual(expectedOutput, actualOutput, "Pick axe monsters attack down")
        
        tiles = [[Tile.exit, .blueRock, .blueRock],
                 [Tile(type: .normalMonster), Tile(type: .normalPlayer), .blueRock],
                 [.greenRock, .greenRock, .greenRock]]
        expectedOutput = Input(.attack(attackType: .targets ,
                                       attacker: TileCoord(1, 0),
                                       defender: TileCoord(1, 1),
                                       affectedTiles: [TileCoord(1, 1)], dodged: false, attackerIsPlayer: false))
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertEqual(expectedOutput, actualOutput, "Mouthy monsters attacked things on it's sides")
        
        tiles = [[Tile.exit, .blueRock, .blueRock],
                 [.greenRock, .greenRock, .greenRock],
                 [Tile(type: .normalPlayer), Tile(type: .normalMonster), .blueRock]]
        expectedOutput = Input(.attack(attackType: .targets ,
                                       attacker: TileCoord(2, 1),
                                       defender: TileCoord(2, 0),
                                       affectedTiles: [TileCoord(2, 0), TileCoord(2, 2)], dodged: false, attackerIsPlayer: false))
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertEqual(expectedOutput, actualOutput, "Mouthy monsters attacked things on it's sides")

        
        // The following do not trigger attacks seeing as they are mouthy monsters
        tiles = [[Tile(type: .normalPlayer), .blueRock, .blueRock],
                     [Tile(type: .normalMonster), .exit, .blueRock],
                     [.greenRock, .greenRock, .greenRock]]
        expectedOutput = Input(.attack(attackType: .targets ,
                                       attacker: TileCoord(1, 0),
                                       defender: TileCoord(0, 0),
                                       affectedTiles: [TileCoord(0, 0)], dodged: false, attackerIsPlayer: false))
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertNotEqual(expectedOutput, actualOutput, "Mouthy monsters attacked things on it's sides")

        tiles = [[.purpleRock, .blueRock, .blueRock],
                 [.exit, .blueRock, Tile(type: .normalPlayer)],
                 [.greenRock, .greenRock, Tile(type: .normalMonster)]]
        expectedOutput = Input(.attack(attackType: .targets ,
                                       attacker: TileCoord(2, 2),
                                       defender: TileCoord(1, 2),
                                       affectedTiles: [TileCoord(1, 2)], dodged: false, attackerIsPlayer: false))
        actualOutput = Referee().enforceRules(tiles)
        XCTAssertNotEqual(expectedOutput, actualOutput, "Mouthy monsters attacked things on it's sides")
    }
    

    func testRefereeMonsterDies() {
        
        var tiles = [[Tile.greenRock, .blueRock, .greenRock, .greenRock],
                     [.blueRock, Tile(type: .deadRat), .exit, .greenRock],
                     [.greenRock, Tile(type: .normalPlayer), .blueRock, .purpleRock],
                     [.blueRock, .purpleRock, .greenRock, .greenRock]]
        var expected = Input(.monsterDies(TileCoord(1, 1), EntityModel.EntityType.rat, deathType: MonsterDeathType.rune))
        var actual = Referee().enforceRules(tiles)
        
        XCTAssertEqual(expected, actual, "Monster dies when hp reaches 0")
        
        tiles = [[.greenRock, .blueRock, .greenRock, .greenRock],
                 [.blueRock, Tile(type: .deadRat), .exit, .greenRock],
                 [.greenRock, Tile(type: .normalPlayer), .blueRock, .purpleRock],
                 [.blueRock, .purpleRock, Tile(type: .deadRat), .greenRock]]
        expected = Input(.monsterDies(TileCoord(1, 1), EntityModel.EntityType.rat, deathType: MonsterDeathType.rune))
        actual = Referee().enforceRules(tiles)
        
        XCTAssertEqual(expected, actual, "Only one monster can die at a time")
    }
    
    func testRefereeRefillsEmpty() {
        
        let tiles = [[Tile.greenRock, .blueRock, .greenRock, .greenRock],
                     [.blueRock, .empty, .exit, .greenRock],
                     [.greenRock, Tile(type: .normalPlayer), .blueRock, .purpleRock],
                     [.blueRock, .purpleRock, .greenRock, .greenRock]]
        let expected = Input(.refillEmpty)
        let actual = Referee().enforceRules(tiles)
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeDoesNotRefillsEmptyWhenPillar() {
        
        let tiles = [[Tile.greenRock, .purplePillar, .greenRock, .greenRock],
                     [.blueRock, .empty, .exit, .greenRock],
                     [.greenRock, Tile(type: .normalPlayer), .blueRock, .purpleRock],
                     [.blueRock, .purpleRock, .greenRock, .greenRock]]
        let expected = Input(.refillEmpty)
        let actual = Referee().enforceRules(tiles)
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeGameOver() {
        
        let tiles = [[.noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock],
                     [.noGroupRock, .noGroupRock, .exit, .noGroupRock],
                     [.noGroupRock, Tile(type: .normalPlayer), .noGroupRock, .noGroupRock],
                     [.noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock]]
        let expected = Input(.noMoreMoves)
        let actual = Referee().enforceRules(tiles)
        
        XCTAssertEqual(expected, actual)
    
    }
    
    // MARK: - No More Moves
    func testRefereeNotGameOverBecauseThereIsAGroupOfRocks() {
        
        let tiles = [[.noGroupRock, .noGroupRock, .noGroupRock, .threeGroupRock],
                     [.noGroupRock, .noGroupRock,  .noGroupRock, .noGroupRock],
                     [.noGroupRock, Tile(type: .normalPlayer), .noGroupRock, .noGroupRock],
                     [.noGroupRock, .exit, .noGroupRock, .noGroupRock]]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeNotGameOverBecauseExit() {
        
        let tiles = [[.noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock],
                     [.noGroupRock, .noGroupRock,  .noGroupRock, .noGroupRock],
                     [.noGroupRock, Tile(type: .normalPlayer), .noGroupRock, .noGroupRock],
                     [.noGroupRock, .exit, .noGroupRock, .noGroupRock]]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeNotGameOverBecausePlayerCanRotateToCollectGems() {
        
        let tiles = [[.noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock],
                     [.noGroupRock, .noGroupRock,  .noGroupRock, .noGroupRock],
                     [.noGroupRock, Tile(type: .normalPlayer), .noGroupRock, .noGroupRock],
                     [.noGroupRock, .tenGems, .noGroupRock, .noGroupRock]]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeNotGameOverBecausePlayerCanRotateToCollectOffer() {
        
        let tiles = [[.noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock],
                     [.noGroupRock, .noGroupRock,  .noGroupRock, .noGroupRock],
                     [.noGroupRock, Tile(type: .normalPlayer), .noGroupRock, .noGroupRock],
                     [.noGroupRock, .offer, .noGroupRock, .noGroupRock]]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeNotGameOverBecauseDynamiteWillExplode() {
        
        let tiles = [[.noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock],
                     [.noGroupRock, .noGroupRock,  .noGroupRock, .noGroupRock],
                     [.noGroupRock, Tile(type: .normalPlayer), .noGroupRock, .noGroupRock],
                     [.noGroupRock, .dynamite, .noGroupRock, .noGroupRock]]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeShouldRecognizeNoMoreMoves() {
        
        let tiles = [[.noGroupRock, .purplePillar, .purplePillar, .noGroupRock],
                     [.purplePillar, .empty,  .purplePillar, .noGroupRock],
                     [.noGroupRock, .purplePillar, .noGroupRock, .noGroupRock],
                     [Tile(type: .normalPlayer), .noGroupRock, .noGroupRock, .noGroupRock]]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeShouldRecognizeNoMoreMoves_ForAPocketOfEmpties() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .purplePillar,  .noGroupRock],
            [.purplePillar,             .empty,         .empty,         .purplePillar],
            [.noGroupRock,              .purplePillar,  .empty,         .purplePillar],
            [Tile(type: .normalPlayer), .purplePillar,  .purplePillar,  .noGroupRock]]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeShouldRecognizeNoMoreMoves_ForTwoPocketsOfEmpties() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .purplePillar,  .noGroupRock],
            [.purplePillar,             .empty,         .purplePillar,  .purplePillar],
            [.noGroupRock,              .purplePillar,  .empty,         .purplePillar],
            [Tile(type: .normalPlayer), .purplePillar,  .purplePillar,  .noGroupRock]]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    }
    
    func testRefereeShouldRecognizeThere_AreNo_MoreMoves_EvenWithRockInPocketOfEmpty() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .purplePillar,  .noGroupRock],
            [.purplePillar,             .noGroupRock,   .empty,         .purplePillar],
            [.purplePillar,             .empty,         .purplePillar,  .purplePillar],
            [Tile(type: .normalPlayer), .purplePillar,  .noGroupRock,   .noGroupRock]]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    }
    
    
    func testRefereeShouldRecognizeThere_Are_MoreMoves_WithAnEmptyWithAJaggedPathToSide() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .purplePillar,  .noGroupRock,   .noGroupRock],
            [.purplePillar,             .noGroupRock,   .empty,         .noGroupRock,   .purplePillar],
            [.purplePillar,             .noGroupRock,   .purplePillar,  .purplePillar,  .noGroupRock],
            [Tile(type: .normalPlayer), .purplePillar,  .noGroupRock,   .noGroupRock,   .noGroupRock],
            [.noGroupRock,              .purplePillar,  .purplePillar,  .noGroupRock,   .noGroupRock],
        ]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    }
    
    func testRefereeShouldRecognizeThere_AreNo_MoreMoves_PillarsOnEntirePerimeter() {
        
        let tiles = [
            [.purplePillar,              .purplePillar,  .purplePillar,  .purplePillar,   .purplePillar],
            [.purplePillar,             .noGroupRock,   .empty,         .noGroupRock,   .purplePillar],
            [.purplePillar,             .noGroupRock,   .purplePillar,  .purplePillar,  .purplePillar],
            [.purplePillar, Tile(type: .normalPlayer), .noGroupRock,   .noGroupRock,   .purplePillar],
            [.purplePillar,              .purplePillar,  .purplePillar,  .purplePillar,   .purplePillar],
        ]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    }
    
    func testRefereeShouldRecognizeThere_AreNo_MoreMoves_PillarsOnEntirePerimeter_ExceptCorners() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .purplePillar,  .purplePillar,   .noGroupRock],
            [.purplePillar,             .noGroupRock,   .empty,         .noGroupRock,   .purplePillar],
            [.purplePillar,             .noGroupRock,   .purplePillar,  .purplePillar,  .purplePillar],
            [.purplePillar, Tile(type: .normalPlayer), .noGroupRock,   .noGroupRock,   .purplePillar],
            [.noGroupRock,              .purplePillar,  .purplePillar,  .purplePillar,   .noGroupRock],
        ]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    }
    
    func testRefereeShouldRecognizeThere_Are_MoreMoves_PillarsOnEntirePerimeter_ExceptOneSpot() {
        
        let tiles = [
            [.purplePillar,              .purplePillar,  .purplePillar,  .purplePillar,   .purplePillar],
            [.purplePillar,             .noGroupRock,   .empty,         .noGroupRock,   .purplePillar],
            [.purplePillar,             .noGroupRock,   .purplePillar,  .purplePillar,  .purplePillar],
            [.purplePillar, Tile(type: .normalPlayer), .noGroupRock,   .noGroupRock,   .purplePillar],
            [.purplePillar,              .noGroupRock,  .purplePillar,  .purplePillar,   .purplePillar],
        ]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    }
    
    func testRefereeShouldRecognizeThere_Are_MoreMoves_BigBoard() {
        
        let tiles = [
            [.purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar],
            [.purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar],
            [.purplePillar, .purplePillar, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .purplePillar],
            [.purplePillar, .purplePillar, .noGroupRock, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.purplePillar, .purplePillar, .noGroupRock, .purplePillar, .empty, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.purplePillar, .purplePillar, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.purplePillar, .purplePillar, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.purplePillar, .purplePillar, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.noGroupRock, .noGroupRock, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [Tile(type: .normalPlayer), .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .purplePillar],
        ]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    }
    
    func testRefereeShouldRecognizeThere_AreNo_MoreMoves_BigBoard() {
        
        let tiles = [
            [.noGroupRock, .purplePillar, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock],
            [.purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar],
            [.purplePillar, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .purplePillar],
            [.noGroupRock, .purplePillar, .noGroupRock, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.purplePillar, .purplePillar, .noGroupRock, .purplePillar, .empty, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.purplePillar, .noGroupRock, .noGroupRock, .noGroupRock, .purplePillar, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.purplePillar, .purplePillar, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.purplePillar, .purplePillar, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [.purplePillar, .noGroupRock, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .purplePillar, .noGroupRock, .purplePillar],
            [Tile(type: .normalPlayer), .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .noGroupRock, .purplePillar, .purplePillar],
        ]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    }


    
    func testRefereeShouldRecognizeThere_Are_MoreMoves_EvenWithRockInPocketOfEmpty_AndAnEmptySomewhereElse() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .purplePillar,  .noGroupRock],
            [.purplePillar,             .noGroupRock,   .empty,         .purplePillar],
            [.purplePillar,             .empty,         .purplePillar,  .purplePillar],
            [Tile(type: .normalPlayer), .purplePillar,  .noGroupRock,   .empty]]
        let expected = Input(.refillEmpty).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    }
    
    // MARK: - No More Moves Teleport
    
    // No moves excet a charged teleport rune
    func testRefereeShouldRecognizeThere_Are_MoreMovesWithRune() {
        
        let tiles = [[.noGroupRock, .purplePillar, .purplePillar, .noGroupRock],
                     [.purplePillar, .exit,  .noGroupRock, .noGroupRock],
                     [.noGroupRock, .purplePillar, .noGroupRock, .noGroupRock],
                     [Tile(type: .normalPlayerWithTeleportation), .noGroupRock, .noGroupRock, .noGroupRock]]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeShouldRecognizeThere_Are_No_MoreMovesEvenWithTeleportBecauseExitIsEncased() {
        
        let tiles = [[.noGroupRock, .purplePillar, .purplePillar, .noGroupRock],
                     [.purplePillar, .exit,  .purplePillar, .noGroupRock],
                     [.noGroupRock, .purplePillar, .noGroupRock, .noGroupRock],
                     [Tile(type: .normalPlayerWithTeleportation), .noGroupRock, .noGroupRock, .noGroupRock]]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    // Ok, the exit is encased which means that teleport doesnt work.  But the palyer has another charged rune as well.
    func testRefereeShouldRecognizeThere_Are_MoreMovesEvenWithTeleportBecauseExitIsEncased_Except_PlayerHasAnotherChargedRune() {
        
        let tiles = [[.noGroupRock, .purplePillar, .purplePillar, .noGroupRock],
                     [.purplePillar, .exit,  .purplePillar, .noGroupRock],
                     [.noGroupRock, .purplePillar, .noGroupRock, .noGroupRock],
                     [Tile(type: .normalPlayerWithTeleportationAndFieryRage), .noGroupRock, .noGroupRock, .noGroupRock]]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    // MARK: - No More Moves Monster Crush
    
    func testRefereeShouldRecognize_AreNo_MoreMoves_WithUncharged_MonsterCrushRune() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .monster(.alamoZero),  .monster(.batZero)],
            [.purplePillar,             .purplePillar,  .noGroupRock,             .monster(.batZero)],
            [.noGroupRock,              .purplePillar,  .noGroupRock,             .purplePillar],
            [Tile(type: .normalPlayerWithUnchargedMonsterCrush), .purplePillar,  .purplePillar,      .noGroupRock]]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeShouldRecognize_Are_MoreMoves_WithCharged_MonsterCrushRune_WithGroupOfThreeMonsters() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .monster(.alamoZero),  .monster(.batZero)],
            [.purplePillar,             .purplePillar,  .noGroupRock,             .monster(.batZero)],
            [.noGroupRock,              .purplePillar,  .noGroupRock,             .purplePillar],
            [Tile(type: .normalPlayerWithChargedMonsterCrush), .purplePillar,  .purplePillar,      .noGroupRock]]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }

    func testRefereeShouldRecognize_Are_MoreMoves_WithCharged_MonsterCrushRune_WithNo_GroupOfThreeMonsters() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .monster(.alamoZero),  .purplePillar],
            [.purplePillar,             .purplePillar,  .noGroupRock,             .monster(.batZero)],
            [.noGroupRock,              .purplePillar,  .noGroupRock,             .purplePillar],
            [Tile(type: .normalPlayerWithChargedMonsterCrush), .purplePillar,  .purplePillar,      .noGroupRock]]
        let expected = Input(.noMoreMoves).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
    
    func testRefereeShouldRecognize_Are_MoreMoves_WithUncharged_MonsterCrushRune_WithNo_GroupOfThreeMonsters_WithChargedFieryRage() {
        
        let tiles = [
            [.noGroupRock,              .purplePillar,  .monster(.alamoZero),  .purplePillar],
            [.purplePillar,             .purplePillar,  .noGroupRock,             .monster(.batZero)],
            [.noGroupRock,              .purplePillar,  .noGroupRock,             .purplePillar],
            [Tile(type: .normalPlayerWithChargedMonsterCrushAndFieryRage), .purplePillar,  .purplePillar,      .noGroupRock]]
        let expected = Input(.reffingFinished(newTurn: false)).type
        let actual = Referee().enforceRules(tiles).type
        
        XCTAssertEqual(expected, actual)
    
    }
}

extension Tile {
    static var ratTileTestOnly: Tile {
        return Tile(type: .monster(.zero))
    }
    
    
    static var purplePillar: Tile {
        return Tile(type: .pillar(PillarData(color: .purple, health: 3)))
    }
    
    static var noGroupRock: Tile {
        return Tile(type: .rock(color: .blue, holdsGem: false, groupCount: 1))
    }
    
    static var threeGroupRock: Tile {
        return Tile(type: .rock(color: .blue, holdsGem: false, groupCount: 13))
    }

    static var tenGems: Tile {
        return Tile(type: .item(Item(type: .gem, amount: 10, color: .blue)))
    }
    
    static var offer: Tile {
        return Tile(type: .offer(.offer(type: .gems(amount: 50), tier: 1)))
    }
    
    static var dynamite: Tile {
        return Tile(type: .dynamite(DynamiteFuse(count: 2, hasBeenDecremented: false)))
    }
}
