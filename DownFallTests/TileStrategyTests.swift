//
//  TileStrategyTests.swift
//  DownFallTests
//
//  Created by William Katz on 1/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
import GameplayKit
@testable import Shift_Shaft

class TileStrategyTests: XCTestCase {
    
    var testBoardSize: Int!
    let board = Board.build(size: 10)
    var empty: Builder!
    var player: Builder!
    var emptyButOnePlayer: Builder!
    
    override func setUp() {
        empty = all(.empty, board)
        player = xTiles(1, Tile(type: .player(.zero)), board)
        emptyButOnePlayer = empty >>> player
        testBoardSize = board.boardSize
    }
  
    /// This test is no longer relevant right now.  The board starts with a exit, so thre is never a need for the tile creator to create one
//    func testTileStrategyAddsCorrectNumberExtraExit() {
//        let exit = xTiles(1, .exit, board)
//        let emptyButOne = empty >>> exit
//
//        var newTiles = TileCreator(entities(),
//                                   difficulty: .normal,
//                                   level: .test)
//            .tiles(for: emptyButOne(board).tiles)
//
//        var exitCount = typeCount(for: newTiles, of: .exit).count
//        XCTAssertEqual(exitCount, 1, "Tile God should not suggest adding another exit")
//
//        newTiles = TileCreator(entities(),
//                               difficulty: .normal,
//                               level: .test)
//            .tiles(for: empty(board).tiles)
//        exitCount = typeCount(for: newTiles, of: .exit).count
//        XCTAssertEqual(exitCount, 1, "Tile God suggest adding only 1 exit")
//    }
    
    
    func testTileStrategyAddsCorrectNumberOfMonstersForDifferentDifficulties() {
        for _ in 0..<3 { //repeat these test so can be more confident that not too many monsters are being added
            [Difficulty.easy, .normal, .hard].forEach { difficulty in
                let newTiles = TileCreator(entities(),
                                           difficulty: difficulty,
                                           level: .test, randomSource: GKLinearCongruentialRandomSource())
                    .tiles(for: emptyButOnePlayer(board).tiles).reduce([], +)
                let monsterCount = newTiles.filter { $0 == Tile(type: .monster(.zero)) }.count
                let maxExpectedMonsters = 10
                XCTAssertTrue(monsterCount <= maxExpectedMonsters, "Difficulty \(difficulty) - Tile God added \(monsterCount), we expected at most \(maxExpectedMonsters)")
            }
        }
    }
    
    

}
