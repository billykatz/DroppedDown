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
        let expectedOutput = [Input(.gameWin, false)]
        
        let gameWin = allBlack >>> win(mockBoard)
        let gameBoard = gameWin(mockBoard)
        let actualOutput = Referee.enforceRules(gameBoard)
        XCTAssertEqual(expectedOutput, actualOutput)
        
        
        let gameWin2 = (allGreen >>> player) >>> win(mockBoard)
        let gameBoard2 = gameWin2(mockBoard)
        let actualOutput2 = Referee.enforceRules(gameBoard2)
        XCTAssertEqual(expectedOutput, actualOutput2)

        let gameWin3 = (allGreen >>> exit) >>> win(mockBoard)
        let gameBoard3 = gameWin3(mockBoard)
        let actualOutput3 = Referee.enforceRules(gameBoard3)
        XCTAssertEqual(expectedOutput, actualOutput3)
    }
    
    
    func testRefereeGameLoses() {
        
        let gameLose = lose(mockBoard)
        let gameBoard = gameLose(mockBoard)
        
        let expectedOutput = [Input(.gameLose, false)]
        let actualOutput = Referee.enforceRules(gameBoard)
        
        XCTAssertEqual(expectedOutput, actualOutput)
        
        var board = Board(tiles: [[.greenRock, .blueRock, .blueRock],
                 [.blueRock, .blackRock, .exit],
                 [.greenRock, .player(), .greenRock]])
        
        let actualOutput2 = Referee.enforceRules(board)
        
        XCTAssertEqual(expectedOutput, actualOutput2)
        
        
        board = Board(tiles: [[.greenRock, .blueRock, .blueRock, .greenRock],
                 [.blueRock, .blackRock, .exit, .greenRock],
                 [.greenRock, .player(), .blueRock, .blackRock],
                 [.blueRock, .blackRock, .greenRock, .greenRock]])
        
        let actualOutput3 = Referee.enforceRules(board)
        
        XCTAssertEqual(expectedOutput, actualOutput3)
    }
    
    func testRefereeNonGameLose() {
        
        let gameLose = Input(.gameLose, false)
        // If the player can attack we dont lose (yet)
        var board = Board(tiles: [[.greenRock, .blueRock, .blueRock, .greenRock],
                 [.blueRock, .greenMonster(CombatTileData.monster()), .exit, .greenRock],
                 [.greenRock, .player(), .blueRock, .blackRock],
                 [.blueRock, .blackRock, .greenRock, .greenRock]])
        let actualOutput = Referee.enforceRules(board)
        
        XCTAssertFalse(actualOutput.contains(gameLose))
        
        //the player can rotate once to win, this is not a lose
        board = Board(tiles: [[.greenRock, .blueRock, .blueRock, .greenRock],
                 [.blueRock, .blackRock, .blackRock, .greenRock],
                 [.greenRock, .player(), .exit, .blackRock],
                 [.blueRock, .blackRock, .greenRock, .greenRock]])
        let actualOutput2 = Referee.enforceRules(board)
        XCTAssertFalse(actualOutput2.contains(gameLose))
        
        //the player can rotate to win twice to win, this is not a lose
        board = Board(tiles: [[.greenRock, .blueRock, .blueRock, .greenRock],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.greenRock, .player(), .blueRock, .blackRock],
                       [.blueRock, .exit, .greenRock, .greenRock]])
        let actualOutput3 = Referee.enforceRules(board)
        XCTAssertFalse(actualOutput3.contains(gameLose))
        
        //the player can rotate to win once to win, this is not a lose
        board = Board(tiles: [[.greenRock, .blueRock, .blueRock, .greenRock],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.exit, .player(), .blueRock, .blackRock],
                       [.blueRock, .blueRock, .greenRock, .greenRock]])
        let actualOutput4 = Referee.enforceRules(board)
        XCTAssertFalse(actualOutput4.contains(gameLose))
        
        //the player can rotate to kill a monster
        board = Board(tiles: [[.greenRock, .blueRock, .blueRock, .exit],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.greenRock, .player(), .greenMonster(), .blackRock],
                       [.blueRock, .blueRock, .greenRock, .greenRock]])
        let actualOutput5 = Referee.enforceRules(board)
        XCTAssertFalse(actualOutput5.contains(gameLose))
        
        //the player can rotate to kill a monster
        board = Board(tiles: [[.greenRock, .blueRock, .blueRock, .exit],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.greenRock, .player(), .blueRock, .blackRock],
                       [.blueRock, .greenMonster(), .greenRock, .greenRock]])
        let actualOutput6 = Referee.enforceRules(board)
        XCTAssertFalse(actualOutput6.contains(gameLose))
        
        //the player can rotate to kill a monster
        board = Board(tiles: [[.greenRock, .blueRock, .blueRock, .exit],
                       [.blueRock, .blackRock, .blackRock, .greenRock],
                       [.greenMonster(), .player(), .blueRock, .blackRock],
                       [.blueRock, .blueRock, .greenRock, .greenRock]])
        let actualOutput7 = Referee.enforceRules(board)
        XCTAssertFalse(actualOutput7.contains(gameLose))

        
    }
    
    func testRefereePlayerAttacks() {
        let playerAttack = all(.blackRock, mockBoard) >>> playerAttacks(mockBoard)
        let expectedOutput = [Input(.playerAttack, false)]
        let actualOutput = Referee.enforceRules(playerAttack(mockBoard))
        
        XCTAssertEqual(expectedOutput, actualOutput)
        
        
        let playerAttackBigMonster = all(.greenRock, mockBoard) >>> playerAttacks(mockBoard, .greenMonster(CombatTileData(hp:2, attackDamage: 3)))
        let actualOutput2 = Referee.enforceRules(playerAttackBigMonster(mockBoard))
        
        XCTAssertEqual(expectedOutput, actualOutput2)
        
    }
    
    func testRefereeMonsterAttacks() {
        var board = Board(tiles: [[.player(), .blueRock, .blueRock],
                          [.greenMonster(), .exit, .blueRock],
                          [.greenRock, .greenRock, .greenRock]])
        var expectedOutput = [Input(.monsterAttack(TileCoord(1, 0)), false)]
        let actualOutput = Referee.enforceRules(board)
        XCTAssertEqual(expectedOutput, actualOutput)
        
        board = Board(tiles: [[.blackRock, .blueRock, .blueRock],
                       [.exit, .blueRock, .player()],
                       [.greenRock, .greenRock, .greenMonster(CombatTileData(hp:2, attackDamage: 3))]])
        expectedOutput = [Input(.monsterAttack(TileCoord(2, 2)), false)]
        let actualOutput2 = Referee.enforceRules(board)
        XCTAssertEqual(expectedOutput, actualOutput2)
    }
    
    func testRefereeMonsterDies() {
        let dyingMonster = TileType.greenMonster(CombatTileData(hp: 0, attackDamage: 1))
        
        var board = Board(tiles: [[.greenRock, .blueRock, .greenRock, .greenRock],
                           [.blueRock, dyingMonster, .exit, .greenRock],
                           [.greenRock, .player(), .blueRock, .blackRock],
                           [.blueRock, .blackRock, .greenRock, .greenRock]])
        let expectedOutput = [Input(.monsterDies(TileCoord(1, 1)), false)]
        let actualOutput = Referee.enforceRules(board)
        
        XCTAssertEqual(expectedOutput, actualOutput, "Monster dies when hp reaches 0")
        
        board = Board(tiles: [[.greenRock, .blueRock, .greenRock, .greenRock],
                       [.blueRock, dyingMonster, .exit, .greenRock],
                       [.greenRock, .player(), .blueRock, .blackRock],
                       [.blueRock, .blackRock, dyingMonster, .greenRock]])
        let expectedSet: Set = [Input(.monsterDies(TileCoord(3, 2)), false), Input(.monsterDies(TileCoord(1, 1)), false)]
        let actualSet = Set<Input>(Referee.enforceRules(board))
        
        XCTAssertEqual(expectedSet, actualSet, "Multiple monsters can die when hp reachs 0")
    }
}
