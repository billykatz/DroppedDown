//
//  DownFallTests.swift
//  DownFallTests
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import XCTest
import GameplayKit
@testable import Shift_Shaft

/* Example board
                                (0,0)   (0,1)   (0,2)
 let tiles: [[MockTile]] = [[.player2, .exit, .blueRock],
 
                                (1,0)       (1,1)       (1,2)
                            [.greenRock, .blueRock, .purpleRock],
 
                                (2,0)       (2,1)       (2,2)
                            [.blueRock, .greenRock, .blueRock]]
 
 
 */

struct MockBoardHelper {
    private static func row(of type: Tile = Tile.greenRock, by size: Int = 5) -> [Tile] {
        return Array(repeating: type, count: size)
    }
    
    static func createBoard(_ type: Tile = Tile.greenRock, size: Int = 5) -> Board {
        let tc = TileCreator(entities(),
                             difficulty: .normal,
                             level: .test, randomSource: GKLinearCongruentialRandomSource())
        return Board(tileCreator: tc,
                     tiles: Array(repeating: row(of: type, by: size),  count: size),
                     level: .test)
    }
    
    static func createBoardWithRowOfSameColor(_ type: Tile = Tile.greenRock, size: Int = 5, rowIdx: Int = 0) -> Board {
        let board = createBoard(.exit, size: size)
        var tiles = board.tiles
        for col in 0..<size {
            tiles[rowIdx][col] = type
        }
        return Board(tileCreator: board.tileCreator, tiles: tiles, level: .test)
    }
}

class BoardTests: XCTestCase {
    
    var tiles: [[Tile]]!
    var board: Board!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.tiles = [[Tile(type: .player(.zero)), .exit, .blueRock],
                  [.blueRock, .blueRock, .blueRock],
                  [.blueRock, .blueRock, .blueRock]]
        self.board = Board(tileCreator: TileCreator(entities(),
                                                    difficulty: .normal,
                                                    level: .test, randomSource: GKLinearCongruentialRandomSource()),
                           tiles: tiles,
                           level: .test)
    }
    
    func testValidNeighbors() {
        
        //surrounded by 8
        var neighborTileCoord = TileCoord(0, 1)
        var currTileCoord = TileCoord(1,1)
        XCTAssertTrue(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(1, 2)
        currTileCoord = TileCoord(1,1)
        XCTAssertTrue(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(2, 1)
        currTileCoord = TileCoord(1,1)
        XCTAssertTrue(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(1, 0)
        currTileCoord = TileCoord(1,1)
        XCTAssertTrue(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        
        // surrounded by 5
        neighborTileCoord = TileCoord(0, 0)
        currTileCoord = TileCoord(0,1)
        XCTAssertTrue(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(0, 2)
        currTileCoord = TileCoord(0,1)
        XCTAssertTrue(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(1, 1)
        currTileCoord = TileCoord(0,1)
        XCTAssertTrue(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        
        //surround by three
        
        neighborTileCoord = TileCoord(0, 1)
        currTileCoord = TileCoord(0,0)
        XCTAssertTrue(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(1, 0)
        currTileCoord = TileCoord(0,0)
        XCTAssertTrue(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
    }
    
    func testNotValidNeighbors() {
        
        // surrounded by 8, NW, NE, SW, SE are not valid neighbors
        var neighborTileCoord = TileCoord(0, 0)
        var currTileCoord = TileCoord(1,1)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(0, 2)
        currTileCoord = TileCoord(1,1)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(2, 0)
        currTileCoord = TileCoord(1,1)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(2, 2)
        currTileCoord = TileCoord(1,1)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        
        // surrounded by 5, NW and SW or NE and SE or NW and NE or SW and SE are not neighbors
        neighborTileCoord = TileCoord(1, 0)
        currTileCoord = TileCoord(0,1)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(1, 2)
        currTileCoord = TileCoord(0,1)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        
        //surround by three NW, NE, SW, or  SE is not a neighbor
        
        neighborTileCoord = TileCoord(1, 1)
        currTileCoord = TileCoord(0,0)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        
        // all non-adjacent tiles are not neighbors
        
        neighborTileCoord = TileCoord(2, 2)
        currTileCoord = TileCoord(0,0)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(1, 2)
        currTileCoord = TileCoord(0,0)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(2, 0)
        currTileCoord = TileCoord(0,0)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(2, 1)
        currTileCoord = TileCoord(0,0)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))
        
        neighborTileCoord = TileCoord(0, 2)
        currTileCoord = TileCoord(0,0)
        XCTAssertFalse(board.valid(neighbor: neighborTileCoord, for: currTileCoord))


    }


    func testFindNeighbors () {
        let expectedNeighbors: [TileCoord] = [(0,2), (1,2), (2,2), (1,1), (1,0), (2,0), (2,1)].map { TileCoord($0.0, $0.1) }
        let actualNeighbors = board.findNeighbors(TileCoord(1, 1)).0
        XCTAssertEqual(Set(actualNeighbors), Set(expectedNeighbors), "Neighbors found do not match")
        
    }
    
    func testFindNoNeighbots() {
        let tiles: [[Tile]] = [[Tile(type: .player(.zero)), .exit, .blueRock],
                                   [.purpleRock, .greenRock, .purpleRock],
                                   [.blueRock, .purpleRock, .blueRock]]
        
        let board = Board(tiles: tiles)
        let actualFoundNeighbors = board.findNeighbors(TileCoord(1,1)).0
        XCTAssertEqual(actualFoundNeighbors.count, 1, "No neighbors found, inital and after board should be equal")
    }
    
    func testInvalidInputFindNeighbors() {
        let actualFoundNeighbors = board.findNeighbors(TileCoord(-1,-1)).0
        XCTAssertTrue(actualFoundNeighbors.isEmpty, "Invalid input, inital and after board should be equal")
    }
    
    func testRotateLeft() {
        
        let tiles: [[Tile]] = [[Tile(type: .player(.zero)), .exit, .blueRock],
                                   [.greenRock, .blueRock, .purpleRock],
                                   [.blueRock, .greenRock, .blueRock]]
        
        let rotatedTiles: [[Tile]] = [[.blueRock, .greenRock, Tile(type: .player(.zero))],
                                          [.greenRock, .blueRock, .exit],
                                          [.blueRock, .purpleRock, .blueRock]]
        
        let initalBoard = Board(tiles: tiles)
        
        let acutalRotatedBoard = initalBoard.rotate(.counterClockwise, preview: true).first!.endTiles
        XCTAssertEqual(acutalRotatedBoard, rotatedTiles, "Inital board should match expected result board after 90 degree rotate left")
        
        
    }
    
    func testRotateRight() {
        let tiles: [[Tile]] = [[Tile(type: .player(.zero)), .exit, .blueRock],
                                   [.greenRock, .blueRock, .purpleRock],
                                   [.blueRock, .greenRock, .blueRock]]
        
        let rotatedTiles: [[Tile]] = [[.blueRock, .purpleRock, .blueRock],
                                          [.exit, .blueRock, .greenRock],
                                          [Tile(type: .player(.zero)), .greenRock, .blueRock]]
        
        let initalBoard = Board(tiles: tiles)
        
        let acutalRotatedBoard = initalBoard.rotate(.clockwise, preview: false).first!.endTiles
        XCTAssertEqual(acutalRotatedBoard, rotatedTiles, "Inital board should match expected result board after 90 degree rotate right")
    }
    
    func testTapPlayerDoesNotResultTransformation() {
        
        let playerTapppedTransformation = board.removeAndReplace(from: board.tiles,
                                                                 tileCoord: TileCoord(row: 0, column: 0),
                                                                 singleTile: false,
                                                                 input: Input(.touch(TileCoord(0,0), .player(.zero))))
        
        let expectedTrans = Transformation(transformation: nil,
                                           inputType: .touch(TileCoord(0,0),
                                                             .player(.zero)),
                                           endTiles: board.tiles)
        XCTAssertEqual(expectedTrans, playerTapppedTransformation, "Tapping player should not result in a board transformation")
    }
    
    func testTapExitDoesNotResultTransformation() {
        let exitTappedTransformation = board.removeAndReplace(from: board.tiles,
        tileCoord: TileCoord(0,1),
        singleTile: false,
        input: Input(.touch(TileCoord(0,1), .exit(blocked: false))))

        let expectedTrans = Transformation(transformation: nil,
                                           inputType: .touch(TileCoord(0,1),
                                           TileType.exit(blocked: false)),
                                           endTiles: board.tiles)
        XCTAssertEqual(expectedTrans, exitTappedTransformation, "Tapping exit should not result in a board transformation")
    }
    
    //TODO: tap monster does not result in transformation
    
    func testBoardComputesValidPlayerAttackVariableDamage() {
        let player1 = Tile(type: .player(.zero))
        let player2 = TileType.createPlayer(originalHp: 5,
                                            hp: 5,
                                            attack: AttackModel(type: .targets,
                                                                frequency: 1,
                                                                range: .one,
                                                                damage: 3,
                                                                attacksThisTurn: 0,
                                                                turns: 1,
                                                                attacksPerTurn: 1,
                                                                attackSlope: [AttackSlope.south]))

        var givenTiles: [[Tile]] = [[.blueRock, .exit, .blueRock],
                                    [Tile(type: .strongMonster), .blueRock, .blueRock],
                                        [player1, .blueRock, .blueRock]]
        var expectedTiles: [[Tile]] = [[.blueRock, .exit, .blueRock],
                                           [Tile(type: .normalMonster), .blueRock, .blueRock],
                                           [player1, .blueRock, .blueRock]]
        var actualBoard = Board(tiles: givenTiles).attack(Input(.attack(attackType: .targets,
                                                                        attacker: TileCoord(2, 0),
                                                                        defender: TileCoord(1, 0),
                                                                        affectedTiles: [TileCoord(1, 0)], dodged: false))).endTiles
        XCTAssertEqual(expectedTiles, actualBoard, "Board removes HP from tiles beneath the player equal to the palyer attack damage.")

        givenTiles = [[.blueRock, .exit, .blueRock],
                      [Tile(type: .healthyMonster), .blueRock, .blueRock],
                      [Tile(type: player2), .blueRock, .blueRock]]

        expectedTiles = [[.blueRock, .exit, .blueRock],
                         [Tile(type: .normalMonster), .blueRock, .blueRock],
                         [Tile(type: player2), .blueRock, .blueRock]]

        actualBoard = Board(tiles: givenTiles)
            .attack(Input(.attack(attackType: .targets,
                                                                    attacker: TileCoord(2, 0),
                                                                    defender: TileCoord(1, 0),
                                                                    affectedTiles: [TileCoord(1, 0)], dodged: false))).endTiles
        XCTAssertEqual(expectedTiles, actualBoard, "Board removes HP from tiles beneath the palyer equal to the palyer attack damage.")


        givenTiles = [[.blueRock, .exit, .blueRock],
                      [Tile(type: .normalMonster), .blueRock, .blueRock],
                      [Tile(type: player2), .blueRock, .blueRock]]

        expectedTiles = [[.blueRock, .exit, .blueRock],
                         [Tile(type: .deadRat), .blueRock, .blueRock],
                         [Tile(type: player2), .blueRock, .blueRock]]

        actualBoard = Board(tiles: givenTiles).attack(Input(.attack(attackType: .targets,
                                                                    attacker: TileCoord(2, 0),
                                                                    defender: TileCoord(1, 0),
                                                                    affectedTiles: [TileCoord(1, 0)], dodged: false))).endTiles
        XCTAssertEqual(expectedTiles, actualBoard, "Board subtracts HP from tile's hp located beneath the player equal to the player attack damage.")


        givenTiles = [[.blueRock, .exit, .blueRock],
                      [Tile(type: .strongMonster), .blueRock, .blueRock],
                      [Tile(type: .strongPlayer), .blueRock, .blueRock]]

        expectedTiles = [[.blueRock, .exit, .blueRock],
                         [Tile(type: .deadRat), .blueRock, .blueRock],
                         [Tile(type: .strongPlayer), .blueRock, .blueRock]]

        actualBoard = Board(tiles: givenTiles).attack(Input(.attack(attackType: .targets,
                                                                    attacker: TileCoord(2, 0),
                                                                    defender: TileCoord(1, 0),
                                                                    affectedTiles: [TileCoord(1, 0)], dodged: false))).endTiles
        XCTAssertEqual(expectedTiles, actualBoard, "Board subtracts HP from tile's hp located beneath the player equal to the player attack damage.")
    }
    
    func testBoardValidMonsters() {
        let givenTiles = [[Tile(type: .normalPlayer), Tile(type: .normalMonster), .blueRock],
                          [.blueRock, .exit, .blueRock],
                          [.blueRock, .blueRock, .blueRock]]
        
        let expectedTiles: [[Tile]] = [[Tile(type: .deadPlayer), Tile(type: .monsterThatHasAttacked), .blueRock],
                                           [.blueRock, .exit, .blueRock],
                                           [.blueRock, .blueRock, .blueRock]]
        let actualBoard = Board(tiles: givenTiles).attack(Input(.attack(attackType: .targets,
                                                                        attacker: TileCoord(0, 1),
                                                                        defender: TileCoord(0, 0),
                                                                        affectedTiles: [TileCoord(0, 0)], dodged: false))).endTiles
        XCTAssertEqual(expectedTiles, actualBoard, "Board applies Monster's attack damage to Player's hp.")
        
    }
    
    func testBoardDeterminesHowManyTilesAreEmpty() {
        var tiles: [[Tile]] = [[Tile(type: .player(.zero)), .exit, .blueRock],
                                   [.purpleRock, .empty, .purpleRock],
                                   [.blueRock, .empty, .blueRock]]
        
        var board = Board.init(tiles: tiles)
        XCTAssertEqual(board.tiles(of: .empty).count, 2, "Board can deteremine how many empty tiles it has")

        tiles = [[.empty, .empty, .empty],
                 [.empty, .empty, .empty],
                 [.empty, .empty, .empty]]
        board = Board.init(tiles: tiles)
        XCTAssertEqual(board.tiles(of: .empty).count, 9, "Board can deteremine how many empty tiles it has")
        
        tiles = [[.purpleRock, .purpleRock, .purpleRock],
                 [.purpleRock, .purpleRock, .purpleRock],
                 [.purpleRock, .purpleRock, .purpleRock]]
        board = Board.init(tiles: tiles)
        XCTAssertEqual(board.tiles(of: .empty).count, 0, "Board can deteremine how many empty tiles it has")

    }
    
    func testBoardKnowsHowManyExitsThereAre() {
        var tiles: [[Tile]] = [[Tile(type: .player(.zero)), .exit, .blueRock],
                                   [.purpleRock, .empty, .purpleRock],
                                   [.blueRock, .empty, .blueRock]]
        
        var board = Board.init(tiles: tiles)
        XCTAssertEqual(board.tiles(of: .exit(blocked: false)).count, 1, "Board can deteremine how many exit tiles it has")
        
        tiles = [[.empty, .exit, .empty],
                 [.empty, .exit, .empty],
                 [.empty, .exit, .empty]]
        board = Board.init(tiles: tiles)
        XCTAssertEqual(board.tiles(of: .exit(blocked: false)).count, 3, "Board can deteremine how many exit tiles it has")
        
        tiles = [[.exit, .exit, .exit],
                 [.exit, .exit, .exit],
                 [.exit, .exit, .exit]]
        board = Board.init(tiles: tiles)
        XCTAssertEqual(board.tiles(of: .exit(blocked: false)).count, 9, "Board can deteremine how many exit tiles it has")
        
    }
    
    func arrayEquality(_ actual: [TileTransformation], _ expected: [TileTransformation] )  {
        for idx in 0..<actual.count {
            let actualStart = actual[idx].initial
            let actualEnd = actual[idx].end
            
            let expectedStart = expected[idx].initial
            let expectedEnd = expected[idx].end
            
            XCTAssertEqual(actualStart, expectedStart, "Actual and expected initial coords match")
            XCTAssertEqual(actualEnd, expectedEnd, "Actual and expected end coords match")
        }
    }
    
    func testBoardRemoveAndReplace() {
        let size = 5
        let board = MockBoardHelper.createBoard(size: size)
        
        var expectedTransformation: [TileTransformation] = []
        for colIdx in 0..<size{
            for rowIdx in size..<size+5 {
                let targetRow = rowIdx-size
                let trans = TileTransformation(TileCoord(rowIdx, colIdx), TileCoord(targetRow, colIdx))
                expectedTransformation.append(trans)
            }
        }
        
        let actualTransformation: [TileTransformation] =
            board.removeAndReplace(from: board.tiles,
                                   tileCoord: TileCoord(0,0),
                                   input: Input(.touch(TileCoord(0,0), .rock(.green))))
                .tileTransformation![2]
        
        XCTAssertEqual(expectedTransformation.count, actualTransformation.count, "Shift down transformations should be the same")
        
        arrayEquality(actualTransformation, expectedTransformation)
        
    }
    
    func testRemoveFirstRow() {
        let size = 3
        let board = MockBoardHelper.createBoardWithRowOfSameColor(.blueRock, size: size, rowIdx: 0)
        
        var expectedTransformation: [TileTransformation] = []
        for colIdx in 0..<size{
            for rowIdx in 1..<size {
                let targetRow = rowIdx-1
                let trans = TileTransformation(TileCoord(rowIdx, colIdx), TileCoord(targetRow, colIdx))
                expectedTransformation.append(trans)
            }
        }
        for colIdx in 0..<size{
            for rowIdx in size..<size+1 {
                let targetRow = rowIdx-1
                let trans = TileTransformation(TileCoord(rowIdx, colIdx), TileCoord(targetRow, colIdx))
                expectedTransformation.append(trans)
            }
        }

        
        
        let transformation = board.removeAndReplace(from: board.tiles,
                                                    tileCoord: TileCoord(0,0),
                                                    input: Input(.touch(TileCoord(0,0), .rock(.purple))))
            
        let actualTransformation = transformation.tileTransformation![2]
        
        XCTAssertEqual(expectedTransformation.count, actualTransformation.count, "Shift down transformations should be the same")
        arrayEquality(actualTransformation, expectedTransformation)
        
    }
    
    func testBoardRemoveAndReplaceSingleTile() {
        let board = MockBoardHelper.createBoard(Tile.greenRock, size: 3)
        
        let expectedTransformation = [TileTransformation.init(TileCoord(1, 1), TileCoord(0, 1)),
                                      TileTransformation.init(TileCoord(2, 1), TileCoord(1, 1)),
                                      TileTransformation.init(TileCoord(3, 1), TileCoord(2, 1))]
        
        
        let actualTransformation = board.removeAndReplace(from: board.tiles, tileCoord: TileCoord(0, 1), singleTile: true, input: Input(.touch(TileCoord(0,1), .rock(.green)))).tileTransformation![2]

        XCTAssertEqual(expectedTransformation.count, actualTransformation.count, "Shift down transformations should be the same")
        arrayEquality(actualTransformation, expectedTransformation)

    }
    
    func testvalidCardinalNeighbors() {
        let board = MockBoardHelper.createBoard(Tile.greenRock, size: 3)
        
        // Test 1,1 has 4 neighbors
        var expectedNeighborsSet : Set<TileCoord> = [TileCoord(0, 1), TileCoord(1, 0), TileCoord(2, 1), TileCoord(1, 2)]
        var actualNeighborSet = Set(board.validCardinalNeighbors(of: TileCoord(1, 1)))
        XCTAssertEqual(expectedNeighborsSet, actualNeighborSet)
        
        
        // Test 0,0 has 2 neighbors
        expectedNeighborsSet = [TileCoord(0, 1), TileCoord(1, 0)]
        actualNeighborSet = Set(board.validCardinalNeighbors(of: TileCoord(0, 0)))
        
        XCTAssertEqual(expectedNeighborsSet, actualNeighborSet)
        
        
        // Test 2,0 has 2 neighbors
        expectedNeighborsSet = [TileCoord(1, 0), TileCoord(2, 1)]
        actualNeighborSet = Set(board.validCardinalNeighbors(of: TileCoord(2, 0)))
        
        XCTAssertEqual(expectedNeighborsSet, actualNeighborSet)
        
        // Test 2,2 has 2 neighbors
        expectedNeighborsSet = [TileCoord(1, 2), TileCoord(2, 1)]
        actualNeighborSet = Set(board.validCardinalNeighbors(of: TileCoord(2, 2)))
        
        XCTAssertEqual(expectedNeighborsSet, actualNeighborSet)
        
        // Test 0,2 has 2 neighbors
        expectedNeighborsSet = [TileCoord(0, 1), TileCoord(1, 2)]
        actualNeighborSet = Set(board.validCardinalNeighbors(of: TileCoord(0, 2)))
        
        XCTAssertEqual(expectedNeighborsSet, actualNeighborSet)
        
        // Test 0,1 has 3 neighbors
        expectedNeighborsSet = [TileCoord(0, 0), TileCoord(1, 1), TileCoord(0, 2)]
        actualNeighborSet = Set(board.validCardinalNeighbors(of: TileCoord(0, 1)))
        
        XCTAssertEqual(expectedNeighborsSet, actualNeighborSet)
        
        // Test 1,0 has 3 neighbors
        expectedNeighborsSet = [TileCoord(0, 0), TileCoord(1, 1), TileCoord(2, 0)]
        actualNeighborSet = Set(board.validCardinalNeighbors(of: TileCoord(1,0)))
        
        XCTAssertEqual(expectedNeighborsSet, actualNeighborSet)
        
        // Test 2,1 has 3 neighbors
        expectedNeighborsSet = [TileCoord(2, 0), TileCoord(1, 1), TileCoord(2, 2)]
        actualNeighborSet = Set(board.validCardinalNeighbors(of: TileCoord(2, 1)))
        
        XCTAssertEqual(expectedNeighborsSet, actualNeighborSet)
        
        // Test 1,2 has 3 neighbors
        expectedNeighborsSet = [TileCoord(2, 2), TileCoord(1, 1), TileCoord(0, 2)]
        actualNeighborSet = Set(board.validCardinalNeighbors(of: TileCoord(1, 2)))
        
        XCTAssertEqual(expectedNeighborsSet, actualNeighborSet)
        
    }
}

