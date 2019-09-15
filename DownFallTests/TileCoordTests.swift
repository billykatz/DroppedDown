//
//  TileCoordTests.swift
//  DownFallTests
//
//  Created by William Katz on 9/14/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall


class TileCoordTests: XCTestCase {
    
    func testTileCoordRowAbove() {
        let tileCoord = TileCoord(0, 0)
        let expectedTileCoord = TileCoord(1, 0)
        XCTAssertEqual(tileCoord.rowAbove, expectedTileCoord)
    }
    
    func testTileCoordRowBelow() {
        let tileCoord = TileCoord(1, 0)
        let expectedTileCoord = TileCoord(0, 0)
        XCTAssertEqual(tileCoord.rowBelow, expectedTileCoord)
    }
    
    func testTileCoordColumnRight() {
        let tileCoord = TileCoord(1, 1)
        let expectedTileCoord = TileCoord(1, 2)
        XCTAssertEqual(tileCoord.colRight, expectedTileCoord)
    }
    
    func testTileCoordColumnLeft() {
        let tileCoord = TileCoord(1, 1)
        let expectedTileCoord = TileCoord(1, 0)
        XCTAssertEqual(tileCoord.colLeft, expectedTileCoord)
    }
    
    
    func testIsOrthogonallyAdjacent() {
        let centerTileCoord = TileCoord(1,1)
        let totallyRemoveTileCoord = TileCoord(5,5)
        let orthognalTileCoords = [centerTileCoord.colLeft,
                                   centerTileCoord.colRight,
                                   centerTileCoord.rowAbove,
                                   centerTileCoord.rowBelow]
        
        for tileCoord in orthognalTileCoords {
            XCTAssertTrue(centerTileCoord.isOrthogonallyAdjacent(to: tileCoord))
            XCTAssertFalse(totallyRemoveTileCoord.isOrthogonallyAdjacent(to: tileCoord))
        }
    }
    
    func testDirectionRelativeTo() {
        let centerTileCoord = TileCoord(3,3)
        
        let noRelativeCoord = TileCoord(7,4)
        let anotherNoRelativeCoord = TileCoord(10,2)
        
        let tileToNorth = TileCoord(5, 3)
        let tileToSouth = TileCoord(1, 3)
        let tileToEast = TileCoord(3, 5)
        let tileToWest = TileCoord(3, 1)
        
        let tileToNorthEast = TileCoord(5, 5)
        let tileToNorthWest = TileCoord(5, 1)
        let tileToSouthEast = TileCoord(1, 5)
        let tileToSouthWest = TileCoord(1, 1)
        
        let tileCoords: [TileCoord] = [tileToNorth,
                                       tileToSouth,
                                       tileToEast,
                                       tileToWest,
                                       tileToNorthEast,
                                       tileToNorthWest,
                                       tileToSouthEast,
                                       tileToSouthWest]
        
        for tileCoord in tileCoords {
            if let direction = centerTileCoord.direction(relative: tileCoord) {
                switch direction {
                case .east:
                    XCTAssertEqual(tileCoord, tileToEast)
                case .north:
                    XCTAssertEqual(tileCoord, tileToNorth)
                case .south:
                    XCTAssertEqual(tileCoord, tileToSouth)
                case .west:
                    XCTAssertEqual(tileCoord, tileToWest)
                case .northEast:
                    XCTAssertEqual(tileCoord, tileToNorthEast)
                case .southEast:
                    XCTAssertEqual(tileCoord, tileToSouthEast)
                case .northWest:
                    XCTAssertEqual(tileCoord, tileToNorthWest)
                case .southWest:
                    XCTAssertEqual(tileCoord, tileToSouthWest)
                }
            }
            
            XCTAssertNil(noRelativeCoord.direction(relative: tileCoord))
            XCTAssertNil(anotherNoRelativeCoord.direction(relative: tileCoord))
        }
        
    }
}
