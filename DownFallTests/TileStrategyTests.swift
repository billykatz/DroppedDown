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
        player = xTiles(1, .player(), board)
        emptyButOnePlayer = empty >>> player
        testBoardSize = board.boardSize
    }
        
    func testTileStrategyCreatesTheCorrectAmountOfTiles() {
        let allBlack = all(.blackRock, board)
        
        for i in testBoardSize+1 { // 0,1,2,3
            let compose =  allBlack >>> xRows(i, .empty, board)
            let composedBoard = compose(board)
            let newTiles = TileCreator.tiles(for: composedBoard)
            XCTAssertEqual(newTiles.count, i*testBoardSize, "TileGod adds \(i) tiles if there are \(i) empty")
        }
        
    }
    
    func testTileStrategyAddsCorrectNumberExtraExit() {
        let exit = xTiles(1, .exit, board)
        let emptyButOne = empty >>> exit
        
        var newTiles = TileCreator.tiles(for: emptyButOne(board))
        XCTAssertFalse(newTiles.contains(.exit), "Tile God should not suggest adding another exit")
        
        newTiles = TileCreator.tiles(for: empty(board))
        XCTAssertEqual(newTiles.filter { $0 == .exit }.count, 1, "Tile God suggest adding only 1 exit")
    }
    
    func testTileStrategyAddsCorrectNumberExtraPlayer() {
        var newTiles = TileCreator.tiles(for: emptyButOnePlayer(board))
        XCTAssertFalse(newTiles.contains(.player()), "Tile God should not suggest adding another player")
        
        newTiles = TileCreator.tiles(for: empty(board))
        XCTAssertEqual(newTiles.filter{ $0 == .player() }.count, 1, "Tile God should suggest adding 1 player")
    }
    
    func testTileStrategyAddsCorrectNumberOfMonstersForDifferentDifficulties() {
        for _ in 0..<3 { //repeat these test so can be more confident that not too many monsters are being added
            [Difficulty.easy, Difficulty.normal, Difficulty.hard].forEach { difficulty in
                let newTiles = TileCreator.tiles(for: emptyButOnePlayer(board), difficulty: difficulty)
                let monsterCount = newTiles.filter { $0 == .greenMonster() }.count
                let maxExpectedMonsters = difficulty.maxExpectedMonsters(for: emptyButOnePlayer(board))
                //TODO: fix test when we add back monsters
//                XCTAssertTrue(monsterCount <= TileCreator.maxMonsters, "Tile God should add some monsters")
                XCTAssertTrue(monsterCount <= maxExpectedMonsters, "Tile God added \(monsterCount), that's \(monsterCount - maxExpectedMonsters) too many")
            }
        }
    }
    
    

}
