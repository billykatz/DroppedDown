//
//  DownFallTests.swift
//  DownFallTests
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall

class DownFallTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
    
    func testFindNeighbors () {
        let tiles =
            [[DFTileSpriteNode.init(type: .rock(RockData.init(textureName: "player2")), search: .white),
              DFTileSpriteNode.init(type: .rock(RockData.init(textureName: "exit")), search: .white),
              DFTileSpriteNode.init(type: .rock(RockData.init(textureName: "blueRock")), search: .white)],
             [DFTileSpriteNode.init(type: .rock(RockData.init(textureName: "blueRock")), search: .white), DFTileSpriteNode.init(type: .rock(RockData.init(textureName: "blueRock")), search: .white), DFTileSpriteNode.init(type: .rock(RockData.init(textureName: "blueRock")), search: .white)],
             [DFTileSpriteNode.init(type: .rock(RockData.init(textureName: "blueRock")), search: .white), DFTileSpriteNode.init(type: .rock(RockData.init(textureName: "blueRock")), search: .white), DFTileSpriteNode.init(type: .rock(RockData.init(textureName: "blueRock")), search: .white)]]
        
        let board = Board.init(tiles, size: 3, playerPosition: (0,0), exitPosition: (0,1), buttons: [])
        
        let neighbors = board.findNeighbors(1,1)
        XCTAssert(compareTuples(neighbors, [(0,2), (1,0), (1,1), (1, 2), (2,0), (2,1) ,(2,2)]), "Neighbors found")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
