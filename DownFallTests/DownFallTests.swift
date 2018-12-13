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

enum MockTile : String {
    case player2
    case exit
    case blueRock
    case blackRock
    case greenRock
}

extension DFTileSpriteNode {
    class func mockInit(_ tile: MockTile) -> DFTileSpriteNode {
        return DFTileSpriteNode.init(type: .rock(RockData.init(textureName: tile.rawValue)), search: .white)
    }
}

extension Board: Equatable {
    public static func ==(_ lhs: Board,_ rhs: Board) -> Bool {
        //TODO: this will break if boards arent squares
        guard lhs.boardSize == rhs.boardSize else { return false }
        for row in 0..<lhs.spriteNodes.count {
            for col in 0..<lhs.spriteNodes[row].count {
                //TODO: if these are not suwares then make sure we are not out of bounds
                guard lhs.spriteNodes[row][col] == rhs.spriteNodes[row][col] else { return false }
            }
        }
        
        return true
    }
}

class DownFallTests: XCTestCase {
    
    var tiles: [[MockTile]]!
    var board: Board!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.tiles = [[.player2, .exit, .blueRock],
                  [.blueRock, .blueRock, .blueRock],
                  [.blueRock, .blueRock, .blueRock]]
        self.board = Board.init(mockTiles(tiles), size: tiles.count, playerPosition: (0,0), exitPosition: (0,1))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func compareTuples <T:Equatable> (_ first:[(T,T)],_ second:[(T,T)]) -> Bool
    {
        guard first.count == second.count else { return false }
        var verifiedTuples = 0
        for tuple in first {
            for innerTuple in second {
                if tuple.0 == innerTuple.0 && tuple.1 == innerTuple.1 {
                    verifiedTuples += 1
                }
            }
        }
        return verifiedTuples == first.count
    }
    
    func mockTiles(_ tiles: [[MockTile]]) -> [[DFTileSpriteNode]] {
        var result : [[DFTileSpriteNode]] = [[]]
        for row in 0..<tiles.count {
            result.append([])
            for col in 0..<tiles[row].count {
                result[row].append(DFTileSpriteNode.mockInit(tiles[row][col]))
            }
        }
        return result
    }
    
    func testFindNeighbors () {
        
        let board = Board.init(mockTiles(tiles),
                               size: 3,
                               playerPosition: (0,0),
                               exitPosition: (0,1))
        
        let expectedNeighbors = [(0,2), (1,2), (2,2), (1,1), (1,0), (2,0), (2,1)]
        guard let actualNeighbors = board.findNeighbors(1, 1) else { XCTFail("UNable to find neighbors"); return }
        XCTAssert(compareTuples(actualNeighbors, expectedNeighbors), "Neighbors found do not match")
        
    }
    
    func testFindNoNeighbots() {
        
        
        let tiles: [[MockTile]] = [[.player2, .exit, .blueRock],
                                   [.blackRock, .greenRock, .blackRock],
                                   [.blueRock, .blackRock, .blueRock]]
        
        let board = Board.init(mockTiles(tiles),
                               size: tiles.count,
                               playerPosition: (0,0),
                               exitPosition: (0,1))
        let actualFoundNeighbors = board.findNeighbors(1,1)
        XCTAssertTrue(actualFoundNeighbors?.count ?? nil == 1, "No neighbors found, inital and after board should be equal")
    }
    
    func testInvalidInputFindNeighbors() {
        let actualFoundNeighbors = board.findNeighbors(-1,-1)
        XCTAssertNil(actualFoundNeighbors, "Invalid input, inital and after board should be equal")
    }
    
    func testRotateLeft() {
        
        let tiles: [[MockTile]] = [[.player2, .exit, .blueRock],
                                   [.greenRock, .blueRock, .blackRock],
                                   [.blueRock, .greenRock, .blueRock]]
        
        let rotatedTiles: [[MockTile]] = [[.blueRock, .greenRock, .player2],
                                          [.greenRock, .blueRock, .exit],
                                          [.blueRock, .blackRock, .blueRock]]
        
        let initalBoard = Board.init(mockTiles(tiles),
                                     size: tiles.count,
                                     playerPosition: (0,0),
                                     exitPosition: (0,1))
        
        let expectedRotatedBoard = Board.init(mockTiles(rotatedTiles),
                                              size: rotatedTiles.count,
                                              playerPosition: (0,2),
                                              exitPosition: (1,2))
        
        let acutalRotatedBoard = initalBoard.rotate(.left).endBoard
        XCTAssert(acutalRotatedBoard == expectedRotatedBoard, "Inital board should match expected result board after 90 degree rotate left")
        
        
    }
    
    func testRotateRight() {
        let tiles: [[MockTile]] = [[.player2, .exit, .blueRock],
                                   [.greenRock, .blueRock, .blackRock],
                                   [.blueRock, .greenRock, .blueRock]]
        
        let rotatedTiles: [[MockTile]] = [[.blueRock, .blackRock, .blueRock],
                                          [.exit, .blueRock, .greenRock],
                                          [.player2, .greenRock, .blueRock]]
        
        let initalBoard = Board.init(mockTiles(tiles),
                                     size: tiles.count,
                                     playerPosition: (0,0),
                                     exitPosition: (0,1))
        
        let expectedRotatedBoard = Board.init(mockTiles(rotatedTiles),
                                              size: rotatedTiles.count,
                                              playerPosition: (2,0),
                                              exitPosition: (1,0))
        
        let acutalRotatedBoard = initalBoard.rotate(.right).endBoard
        XCTAssert(acutalRotatedBoard == expectedRotatedBoard, "Inital board should match expected result board after 90 degree rotate right")
    }
}
