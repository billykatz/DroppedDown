//
//  GameSceneTests.swift
//  DownFallTests
//
//  Created by Katz, Billy-CW on 12/20/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation

//    func testNoMoreGameMovesResultInLost() {
//        let tiles: [[TileType]] = [[.player, .greenRock, .blueRock],
//                                   [.greenRock, .blueRock, .blackRock],
//                                   [.blueRock, .exit, .blueRock]]
//
//        let board = Board.init(tiles: tiles,
//                               playerPosition: TileCoord(0,0),
//                               exitPosition:   TileCoord(2,1))
//        XCTAssertTrue(board.boardHasMoreMoves(), "The board should know there are no more moves")
//    }
//
//    func testBoardRecognizesRotateAsValidMoveLeft() {
//        let tiles: [[TileType]] = [[.player, .exit, .blueRock],
//                                   [.greenRock, .blueRock, .blackRock],
//                                   [.blueRock, .greenRock, .blueRock]]
//
//        let board = Board.init(tiles: tiles,
//                               playerPosition: TileCoord(0,0),
//                               exitPosition:   TileCoord(0,1))
//        XCTAssertTrue(board.boardHasMoreMoves(), "The board should know there are no more groups of tiles with 3 or more, however the player can rotate to win")
//
//    }
