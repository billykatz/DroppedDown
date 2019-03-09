//
//  RendererTests.swift
//  DownFallTests
//
//  Created by William Katz on 2/14/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
import SpriteKit
@testable import DownFall

class RendererTests: XCTestCase {
    let boardSize = 10
    let mockTileCount = 10 * 10
    var board : Board!
    var greenBoard : Builder!
    var renderer: Renderer!
    
    
    override func setUp() {
        board = Board.build(size: boardSize)
        greenBoard = all(.greenRock, board)
        renderer = Renderer(playableRect: CGRect.zero,
                                foreground: SKNode(),
                                board: greenBoard(board))
    }
    
    func testAddSprites() {
        //TODO: Add some functionality on Renderer that allows us to know how many children it has, including headers and controls etc...
        XCTAssertTrue(mockTileCount < renderer.foreground.children.count, "The foreground should contain at least the 100 sprites we added. It may contain more because of things like the header and controls that are also added as children")
    }
    
    func testCreateSprites() {
        let count = renderer.createSprites(from: greenBoard(board)).flatMap { $0 }.count
        XCTAssertEqual(mockTileCount, count)
    }

}
