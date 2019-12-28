//
//  TileStrategyTests.swift
//  DownFallTests
//
//  Created by William Katz on 1/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
import GameplayKit
@testable import DownFall

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
        
    func testTileStrategyCreatesTheCorrectAmountOfTiles() {
        let allBlack = all(Tile(type: .blackRock), board)
        
        for i in testBoardSize+1 { // 0,1,2,3
            let compose =  allBlack >>> xRows(i, .empty, board)
            let composedBoard = compose(board)
            let newTiles = TileCreator(entities(),
                                       difficulty: .normal,
                                       level: .test)
                .tiles(for: composedBoard.tiles)
            XCTAssertEqual(newTiles.count, i*testBoardSize, "TileGod adds \(i) tiles if there are \(i) empty")
        }
        
    }
    
    func testTileStrategyAddsCorrectNumberExtraExit() {
        let exit = xTiles(1, .exit, board)
        let emptyButOne = empty >>> exit
        
        var newTiles = TileCreator(entities(),
                                   difficulty: .normal,
                                   level: .test)
            .tiles(for: emptyButOne(board).tiles)
        XCTAssertFalse(newTiles.contains(.exit), "Tile God should not suggest adding another exit")
        
        newTiles = TileCreator(entities(),
                               difficulty: .normal,
                               level: .test)
            .tiles(for: empty(board).tiles)
        XCTAssertEqual(newTiles.filter { $0 == .exit }.count, 1, "Tile God suggest adding only 1 exit")
    }
    
    
    func testTileStrategyAddsCorrectNumberOfMonstersForDifferentDifficulties() {
        for _ in 0..<3 { //repeat these test so can be more confident that not too many monsters are being added
            [Difficulty.easy, .normal, .hard].forEach { difficulty in
                let newTiles = TileCreator(entities(),
                                           difficulty: difficulty,
                                           level: .test)
                    .tiles(for: emptyButOnePlayer(board).tiles)
                let monsterCount = newTiles.filter { $0 == Tile(type: .monster(.zero)) }.count
                let maxExpectedMonsters = 10
                //TODO: fix test when we add back monsters
                XCTAssertTrue(monsterCount <= maxExpectedMonsters, "Difficulty \(difficulty) - Tile God added \(monsterCount), we expected at most \(maxExpectedMonsters)")
            }
        }
    }
    
    

}
