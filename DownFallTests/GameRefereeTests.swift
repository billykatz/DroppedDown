//
//  GameRefereeTests.swift
//  DownFallTests
//
//  Created by William Katz on 12/29/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall

class GameRefereeTests: XCTestCase {
    
    let mockBoard = Board.build(size: 10)
    var allBlack: Builder!
    var allGreen: Builder!
    var player: Builder!
    var exit: Builder!
    
    override func setUp() {
        super.setUp()
        
        allBlack = all(.blackRock, mockBoard)
        allGreen = all(.greenRock, mockBoard)
        player = xTiles(1, .player(), mockBoard)
        exit = xTiles(1, .exit, mockBoard)
    }
    
    func initRef(_ tiles: [[TileType]]) -> Referee {
        let board = Board(tiles: tiles)
        return Referee(board)
    }
    
    func testGameRefereeInitsWithBoard() {
        let tiles: [[TileType]] = [[.blueRock, .blackRock], [.blueRock, .blackRock]]
        let board = Board.init(tiles: tiles)
        let ref = Referee(board)
        XCTAssertNotNil(ref, "Referee inits with Board instance")
    }
    
    func testRefereeGameWin() {
        
        //same for all tests in this function
        let expectedOutput = [Input.gameWin]
        
        let gameWin = allBlack >>> win(mockBoard)
        let gameBoard = gameWin(mockBoard)
        let actualOutput = Referee(gameBoard).enforceRules()
        XCTAssertEqual(expectedOutput, actualOutput)
        
        
        let gameWin2 = (allGreen >>> player) >>> win(mockBoard)
        let gameBoard2 = gameWin2(mockBoard)
        let actualOutput2 = Referee(gameBoard2).enforceRules()
        XCTAssertEqual(expectedOutput, actualOutput2)

        let gameWin3 = (allGreen >>> exit) >>> win(mockBoard)
        let gameBoard3 = gameWin3(mockBoard)
        let actualOutput3 = Referee(gameBoard3).enforceRules()
        XCTAssertEqual(expectedOutput, actualOutput3)
    }
    
    
    func testRefereeGameLoses() {
        
        let gameLose = lose(mockBoard)
        let gameBoard = gameLose(mockBoard)
        var ref = initRef([[.exit, .blackRock], [.blackRock, .player()]])
        
        let expectedOutput = [Input.gameLose]
        let actualOutput = Referee(gameBoard).enforceRules()
        
        XCTAssertEqual(expectedOutput, actualOutput)
        
        ref = initRef([[.greenRock, .blueRock, .blueRock],
                 [.blueRock, .blackRock, .exit],
                 [.greenRock, .player(), .greenRock]])
        
        let actualOutput2 = ref.enforceRules()
        
        XCTAssertEqual(expectedOutput, actualOutput2)
        
        
        ref = initRef([[.greenRock, .blueRock, .blueRock, .greenRock],
                 [.blueRock, .blackRock, .exit, .greenRock],
                 [.greenRock, .player(), .blueRock, .blackRock],
                 [.blueRock, .blackRock, .greenRock, .greenRock]])
        
        let actualOutput3 = ref.enforceRules()
        
        XCTAssertEqual(expectedOutput, actualOutput3)
    }
    
    func testRefereeNonGameLose() {
        
        // If the player can attack we dont lose (yet)
        var ref = initRef([[.greenRock, .blueRock, .blueRock, .greenRock],
                 [.blueRock, .greenMonster(CombatTileData.monster()), .exit, .greenRock],
                 [.greenRock, .player(), .blueRock, .blackRock],
                 [.blueRock, .blackRock, .greenRock, .greenRock]])
        let actualOutput = ref.enforceRules()
        
        XCTAssertFalse(actualOutput.contains(Input.gameLose))
        
        //the player can rotate once to win, this is not a lose
        ref = initRef([[.greenRock, .blueRock, .blueRock, .greenRock],
                 [.blueRock, .blackRock, .blackRock, .greenRock],
                 [.greenRock, .player(), .exit, .blackRock],
                 [.blueRock, .blackRock, .greenRock, .greenRock]])
        let actualOutput2 = ref.enforceRules()
        XCTAssertFalse(actualOutput2.contains(Input.gameLose))
        
        //the player can rotate to win twice to win, this is not a lose
        ref = initRef([[.greenRock, .blueRock, .blueRock, .greenRock],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.greenRock, .player(), .blueRock, .blackRock],
                       [.blueRock, .exit, .greenRock, .greenRock]])
        let actualOutput3 = ref.enforceRules()
        XCTAssertFalse(actualOutput3.contains(Input.gameLose))
        
        //the player can rotate to win once to win, this is not a lose
        ref = initRef([[.greenRock, .blueRock, .blueRock, .greenRock],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.exit, .player(), .blueRock, .blackRock],
                       [.blueRock, .blueRock, .greenRock, .greenRock]])
        let actualOutput4 = ref.enforceRules()
        XCTAssertFalse(actualOutput4.contains(Input.gameLose))
        
        //the player can rotate to kill a monster
        ref = initRef([[.greenRock, .blueRock, .blueRock, .exit],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.greenRock, .player(), .greenMonster(), .blackRock],
                       [.blueRock, .blueRock, .greenRock, .greenRock]])
        let actualOutput5 = ref.enforceRules()
        XCTAssertFalse(actualOutput5.contains(Input.gameLose))
        
        //the player can rotate to kill a monster
        ref = initRef([[.greenRock, .blueRock, .blueRock, .exit],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.greenRock, .player(), .blueRock, .blackRock],
                       [.blueRock, .greenMonster(), .greenRock, .greenRock]])
        let actualOutput6 = ref.enforceRules()
        XCTAssertFalse(actualOutput6.contains(Input.gameLose))
        
        //the player can rotate to kill a monster
        ref = initRef([[.greenRock, .blueRock, .blueRock, .exit],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.greenMonster(), .player(), .blueRock, .blackRock],
                       [.blueRock, .blueRock, .greenRock, .greenRock]])
        let actualOutput7 = ref.enforceRules()
        XCTAssertFalse(actualOutput7.contains(Input.gameLose))

        
    }
    
    func testRefereePlayerAttacks() {
        let playerAttack = all(.blackRock, mockBoard) >>> playerAttacks(mockBoard)
        let expectedOutput = [Input.playerAttack]
        let actualOutput = Referee(playerAttack(mockBoard)).enforceRules()
        
        XCTAssertEqual(expectedOutput, actualOutput)
        
        
        let playerAttackBigMonster = all(.greenRock, mockBoard) >>> playerAttacks(mockBoard, .greenMonster(CombatTileData(hp:2, attackDamage: 3)))
        let actualOutput2 = Referee(playerAttackBigMonster(mockBoard)).enforceRules()
        
        XCTAssertEqual(expectedOutput, actualOutput2)
        
    }
    
    func testRefereeMonsterAttacks() {
        var ref = initRef([[.player(), .blueRock, .blueRock],
                          [.greenMonster(), .exit, .blueRock],
                          [.greenRock, .greenRock, .greenRock]])
        var expectedOutput = [Input.monsterAttack(TileCoord(1, 0))]
        let actualOutput = ref.enforceRules()
        XCTAssertEqual(expectedOutput, actualOutput)
        
        ref = initRef([[.blackRock, .blueRock, .blueRock],
                       [.exit, .blueRock, .player()],
                       [.greenRock, .greenRock, .greenMonster(CombatTileData(hp:2, attackDamage: 3))]])
        expectedOutput = [Input.monsterAttack(TileCoord(2, 2))]
        let actualOutput2 = ref.enforceRules()
        XCTAssertEqual(expectedOutput, actualOutput2)
    }
    
    func testRefereeMonsterDies() {
        let dyingMonster = TileType.greenMonster(CombatTileData(hp: 0, attackDamage: 1))
        
        var ref = initRef([[.greenRock, .blueRock, .greenRock, .greenRock],
                           [.blueRock, dyingMonster, .exit, .greenRock],
                           [.greenRock, .player(), .blueRock, .blackRock],
                           [.blueRock, .blackRock, .greenRock, .greenRock]])
        let expectedOutput = [Input.monsterDies(TileCoord(1, 1))]
        let actualOutput = ref.enforceRules()
        
        XCTAssertEqual(expectedOutput, actualOutput, "Monster dies when hp reaches 0")
        
        ref = initRef([[.greenRock, .blueRock, .greenRock, .greenRock],
                       [.blueRock, dyingMonster, .exit, .greenRock],
                       [.greenRock, .player(), .blueRock, .blackRock],
                       [.blueRock, .blackRock, dyingMonster, .greenRock]])
        let expectedSet: Set = [Input.monsterDies(TileCoord(3, 2)), Input.monsterDies(TileCoord(1, 1))]
        let actualSet = Set(ref.enforceRules())
        
        XCTAssertEqual(expectedSet, actualSet, "Multiple monsters can die when hp reachs 0")
    }
}
