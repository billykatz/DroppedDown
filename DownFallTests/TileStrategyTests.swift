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
    
    
    static let tenEmptyTiles: [TileType] = [.empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty]
    static let nineEmptyOneExitTiles: [TileType] = [.empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .exit]
    
    static let nineEmptyOnePlayerTiles: [TileType] = [.empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .player()]

    static let threeBlackRocks: [TileType] = [.blackRock, .blackRock, .blackRock]
    static let twoBlackOneExit: [TileType] = [.blackRock, .blackRock, .exit]
    static let threeEmptyTiles: [TileType] = [.empty, .empty, .empty]
    let playerAttacksBoard = Board.init(tiles: [[.blackRock, .greenMonster(), .blackRock],
                                                       [.blackRock, .player(), .blackRock],
                                                       threeBlackRocks])
    
    
    
    override func setUp() {
        super.setUp()
        //maybe reset the random source on our static tile god
    }
    
    func testTileStrategyCreatesTheCorrectAmountOfTiles() {
        
        var board = Board.init(tiles:[TileStrategyTests.threeBlackRocks,
                                           TileStrategyTests.threeBlackRocks,
                                           TileStrategyTests.threeBlackRocks])
        var newTiles = TileCreator.tiles(for: board)
        XCTAssertEqual(newTiles.count, 0, "TileGod does not add tiles if there is nothing empty")
        
        board = Board.init(tiles:[TileStrategyTests.threeEmptyTiles,
                                      TileStrategyTests.threeBlackRocks,
                                      TileStrategyTests.threeBlackRocks])
        newTiles = TileCreator.tiles(for: board)
        XCTAssertEqual(newTiles.count, 3, "TileGod adds 3 tiles if there are 3 empty")
        
        board = Board.init(tiles:[TileStrategyTests.threeEmptyTiles,
                                  TileStrategyTests.threeEmptyTiles,
                                  TileStrategyTests.threeBlackRocks])
        newTiles = TileCreator.tiles(for: board)
        XCTAssertEqual(newTiles.count, 6, "TileGod adds 6 tiles if there are 6 empty")
        
        board = Board.init(tiles:[TileStrategyTests.threeEmptyTiles,
                                  TileStrategyTests.threeEmptyTiles,
                                  TileStrategyTests.threeEmptyTiles])
        newTiles = TileCreator.tiles(for: board)
        XCTAssertEqual(newTiles.count, 9, "TileGod adds 9 tiles if there are 9 empty")
        
    }
    
    func testTileStrategAddsCorrectNumberExtraExit() {
        var emptyBoard = Board.init(tiles: [TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.nineEmptyOneExitTiles])
        
        for _ in 0..<1 {
            let newTiles = TileCreator.tiles(for: emptyBoard)
            XCTAssertFalse(newTiles.contains(.exit), "Tile God should not suggest adding another exit")
        }
        
        emptyBoard = Board.init(tiles: [TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles])
        
        for _ in 0..<1 {
            let newTiles = TileCreator.tiles(for: emptyBoard)
            XCTAssertEqual(newTiles.filter { $0 == .exit }.count, 1, "Tile God suggest adding only 1 exit")
        }
    }
    
    func testTileStrategyAddsCorrectNumberExtraPlayer() {
        var emptyBoard = Board.init(tiles: [TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.nineEmptyOnePlayerTiles])
        
        for _ in 0..<1 {
            let newTiles = TileCreator.tiles(for: emptyBoard)
            XCTAssertFalse(newTiles.contains(.player()), "Tile God should not suggest adding another player")
        }
        
        emptyBoard = Board.init(tiles: [TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles])
        
        for _ in 0..<1 {
            let newTiles = TileCreator.tiles(for: emptyBoard)
            XCTAssertEqual(newTiles.filter{ $0 == .player() }.count, 1, "Tile God should suggest adding 1 player")
        }
    }
    
    func testTileStrategyAddsCorrectNumberOfMonstersForDifferentDifficulties() {
        let emptyBoard = Board.init(tiles: [TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.tenEmptyTiles, TileStrategyTests.nineEmptyOnePlayerTiles])
        
        for _ in 0..<3 { //repeat these test so can be more confident that not too many monsters are being added
            [Difficulty.easy, Difficulty.normal, Difficulty.hard].forEach { difficulty in
                let newTiles = TileCreator.tiles(for: emptyBoard, difficulty: difficulty)
                let monsterCount = newTiles.filter { $0 == .greenMonster() }.count
                let maxExpectedMonsters = difficulty.maxExpectedMonsters(for: emptyBoard)
                XCTAssertTrue(monsterCount > 0, "Tile God should add some monsters")
                XCTAssertTrue(monsterCount <= maxExpectedMonsters, "Tile God added \(monsterCount), that's \(monsterCount - maxExpectedMonsters) too many")
            }
        }
    }
    
    

}
