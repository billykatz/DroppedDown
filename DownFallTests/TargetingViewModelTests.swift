//
//  TargetingViewModelTests.swift
//  DownFallTests
//
//  Created by Katz, Billy on 1/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import XCTest
@testable import Shift_Shaft

class TargetingViewModelTests: XCTestCase {
    
    
    override func setUp() {
        Dispatch.shared.reset()
    }
    
    var playerCoord: TileCoord?
    
    @discardableResult
    func sendTiles(_ numMonsters: Int = 1) -> [[Tile]] {
        var customTiles = [Tile(type: .player(.zero))]
        customTiles.append(contentsOf: Array.init(repeating: Tile(type: .monster(.zero)), count: numMonsters))
        
        let board = Board.build(size: 10)
        let allblue = all(.blueRock, Board.build(size: 10))
        let playerAndMonster = xTiles(customTiles, board)
        let boardWithPlayerAndMonster = allblue >>> playerAndMonster
        let tiles = boardWithPlayerAndMonster(board).tiles
        
        self.playerCoord = tileCoords(for: tiles, of: .player(.zero)).first
        
        Dispatch.shared.send(Input(.boardBuilt, board.tiles))
        
        return tiles

    }
    
    func testDidTargetSingle() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.all.count, 0)
        sendTiles()
        
        //when
        vm.didSelect(Rune.rune(for: .vortex))
        
        vm.didTarget(TileCoord(1, 1))
        
        // verify
        XCTAssertEqual(vm.currentTargets.all.count, 9)
        
        
    }
    
    func testDidTargetMultiple() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.all.count, 0)
        
        //when
        let _ = sendTiles()
        vm.didSelect(Rune.rune(for: .getSwifty))
        
        vm.didTarget(.zero)
        
        // verify
        XCTAssertEqual(vm.currentTargets.all.count, 1)
        
        //when
        vm.didTarget(TileCoord(0,3))
        
        // verify
        XCTAssertEqual(vm.currentTargets.all.count, 2)
        
        // when we try to target a 3rd, it removes an old target to add the new one
        vm.didTarget(TileCoord(0,4))
        
        //verify
        XCTAssertEqual(vm.currentTargets.all.count, 2)
        
        // when we try to target a 3rd, it removes an old target to add the new one
        vm.didTarget(TileCoord(0,5))
        
        //verify
        XCTAssertEqual(vm.currentTargets.all.count, 2)
        
        
        // when you target one that has already been chosen
        // it removes it
        
        vm.didTarget(TileCoord(0,5))
        
        //verify
        XCTAssertEqual(vm.currentTargets.all.count, 1)
        
        // when you target one that has already been chosen
        // it removes it
        
        vm.didTarget(TileCoord(0,4))
        
        //verify
        XCTAssertEqual(vm.currentTargets.all.count, 0)
    }
    
    func testAutoTargetPlayer() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.all.count, 0)
        
        //when
        let tiles = sendTiles()
        
        let trans = Transformation(transformation: nil,
                                   inputType: .itemUseSelected(Rune.rune(for: .bubbleUp)),
                                   endTiles: tiles)
        
        Dispatch.shared.send(Input(InputType.newTurn, tiles))
        
        Dispatch.shared.send(Input(InputType.transformation([trans])))
        
        vm.didSelect(Rune.rune(for: .bubbleUp))
        
        // verify
        XCTAssertEqual(vm.currentTargets.all.count, 1)
        
        
        
    }
    
    
    func testAutoTargetMonster() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.all.count, 0)
        
        // with 1 monster
        let tiles = sendTiles(2)
        
        let trans = Transformation(transformation: nil,
                                   inputType: .itemUseSelected(Rune.rune(for: .bubbleUp)),
                                   endTiles: tiles)
        
        Dispatch.shared.send(Input(InputType.newTurn, tiles))
        
        Dispatch.shared.send(Input(InputType.transformation([trans])))
        
        
        //when
        vm.didSelect(Rune.rune(for: .rainEmbers))

        
        // verify
        XCTAssertEqual(vm.currentTargets.all.count, 2)
        
    }
    
    func testAutoTargetMonsterFail() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.all.count, 0)
        
        //when
        Dispatch.shared.send(Input(InputType.itemUseSelected(Rune.rune(for: .rainEmbers))))
        
        // with 1 monster
        sendTiles(3)
        
        // verify
        XCTAssertEqual(vm.currentTargets.all.count, 0)
        
    }
    
    
    func testAutoTargetFail() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.all.count, 0)
        
        //when
        Dispatch.shared.send(Input(InputType.itemUseSelected(Rune.rune(for: .getSwifty))))
        sendTiles()
        
        // verify
        XCTAssertEqual(vm.currentTargets.all.count, 0)
        
    }
    
    func testDidUseAbility() {
        // given
        let vm = TargetingViewModel()
        
        //when
        vm.didSelect(Rune.rune(for: .transformRock))
        sendTiles()
        XCTAssertNotNil(vm.rune)
        vm.currentTargets = AllTarget(targets: [Target(coord: .zero, associatedCoord: [], isLegal: true), Target(coord: TileCoord(1, 2), associatedCoord: [], isLegal: true)], areLegal: true)
        vm.didUse(Rune.rune(for: .transformRock))
        
        // verify
        XCTAssertNil(vm.rune)
    }
}
