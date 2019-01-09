//
//  DownFallTests.swift
//  DownFallTests
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall

/* Example board
                                (0,0)   (0,1)   (0,2)
 let tiles: [[MockTile]] = [[.player2, .exit, .blueRock],
 
                                (1,0)       (1,1)       (1,2)
                            [.greenRock, .blueRock, .blackRock],
 
                                (2,0)       (2,1)       (2,2)
                            [.blueRock, .greenRock, .blueRock]]
 
 
 */

class DownFallTests: XCTestCase {
    
    var tiles: [[TileType]]!
    var board: Board!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.tiles = [[.player, .exit, .blueRock],
                  [.blueRock, .blueRock, .blueRock],
                  [.blueRock, .blueRock, .blueRock]]
        self.board = Board.init(tiles: tiles,
                                playerPosition: TileCoord(0,0),
                                exitPosition: TileCoord(0,1))
    }
    
    //TODO add clicking on player and or exit does nothing

    func testFindNeighbors () {
        let expectedNeighbors: [TileCoord] = [(0,2), (1,2), (2,2), (1,1), (1,0), (2,0), (2,1)].map { TileCoord($0.0, $0.1) }
        guard let actualNeighbors = board.findNeighbors(1, 1) else { XCTFail("Unable to find neighbors"); return }
        XCTAssertEqual(Set(actualNeighbors), Set(expectedNeighbors), "Neighbors found do not match")
        
    }
    
    func testFindNoNeighbots() {
        let tiles: [[TileType]] = [[.player, .exit, .blueRock],
                                   [.blackRock, .greenRock, .blackRock],
                                   [.blueRock, .blackRock, .blueRock]]
        
        let board = Board.init(tiles: tiles,
                               playerPosition: TileCoord(0,0),
                               exitPosition: TileCoord(0,1))
        let actualFoundNeighbors = board.findNeighbors(1,1)
        XCTAssertTrue(actualFoundNeighbors?.count ?? nil == 1, "No neighbors found, inital and after board should be equal")
    }
    
    func testInvalidInputFindNeighbors() {
        let actualFoundNeighbors = board.findNeighbors(-1,-1)
        XCTAssertNil(actualFoundNeighbors, "Invalid input, inital and after board should be equal")
    }
    
    func testRotateLeft() {
        
        let tiles: [[TileType]] = [[.player, .exit, .blueRock],
                                   [.greenRock, .blueRock, .blackRock],
                                   [.blueRock, .greenRock, .blueRock]]
        
        let rotatedTiles: [[TileType]] = [[.blueRock, .greenRock, .player],
                                          [.greenRock, .blueRock, .exit],
                                          [.blueRock, .blackRock, .blueRock]]
        
        let initalBoard = Board.init(tiles: tiles,
                                     playerPosition: TileCoord(0,0),
                                     exitPosition: TileCoord(0,1))
        
        let expectedRotatedBoard = Board.init(tiles: rotatedTiles,
                                              playerPosition: TileCoord(0,2),
                                              exitPosition: TileCoord(1,2))
        
        let acutalRotatedBoard = initalBoard.rotate(.left).endBoard
        XCTAssert(acutalRotatedBoard == expectedRotatedBoard, "Inital board should match expected result board after 90 degree rotate left")
        
        
    }
    
    func testRotateRight() {
        let tiles: [[TileType]] = [[.player, .exit, .blueRock],
                                   [.greenRock, .blueRock, .blackRock],
                                   [.blueRock, .greenRock, .blueRock]]
        
        let rotatedTiles: [[TileType]] = [[.blueRock, .blackRock, .blueRock],
                                          [.exit, .blueRock, .greenRock],
                                          [.player, .greenRock, .blueRock]]
        
        let initalBoard = Board.init(tiles: tiles,
                                     playerPosition: TileCoord(0,0),
                                     exitPosition: TileCoord(0,1))
        
        let expectedRotatedBoard = Board.init(tiles: rotatedTiles,
                                              playerPosition: TileCoord(2,0),
                                              exitPosition: TileCoord(1,0))
        
        let acutalRotatedBoard = initalBoard.rotate(.right).endBoard
        XCTAssert(acutalRotatedBoard == expectedRotatedBoard, "Inital board should match expected result board after 90 degree rotate right")
    }
    
    func testTapPlayerDoesNotResultTransformation() {
        let expectedBoard = board
        let actualBoard = board.handle(input: Input.touch(TileCoord(0,0))).endBoard
        XCTAssertEqual(expectedBoard, actualBoard, "Tapping player should not result in a board transformation")
    }
    
    func testTapExitDoesNotResultTransformation() {
        let expectedBoard = board
        let actualBoard = board.handle(input: Input.touch(TileCoord(0,1))).endBoard
        XCTAssertEqual(expectedBoard, actualBoard, "Tapping exit should not result in a board transformation")
    }
}
