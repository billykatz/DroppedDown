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
    
    func sendTiles(_ numMonsters: Int = 1) {
        var customTiles = [Tile(type: .player(.zero))]
        customTiles.append(contentsOf: Array.init(repeating: Tile(type: .monster(.zero)), count: numMonsters))
        
        let board = Board.build(size: 10)
        let allblue = all(.blueRock, Board.build(size: 10))
        let playerAndMonster = xTiles(customTiles, board)
        let boardWithPlayerAndMonster = allblue >>> playerAndMonster
        let tiles = boardWithPlayerAndMonster(board).tiles
        let trans = Transformation(transformation: nil,
                                   inputType: .itemUseSelected(AnyAbility(DoubleAttack())),
                                   endTiles: tiles)
        
        self.playerCoord = typeCount(for: tiles, of: .player(.zero)).first
        Dispatch.shared.send(Input(InputType.transformation([trans])))
    }
    
    func testDidTargetSingle() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.count, 0)
        sendTiles()
        
        //when
        vm.didSelect(AnyAbility(KillMonsterPotion()))
        
        vm.didTarget(.zero)
        
        // verify
        XCTAssertEqual(vm.currentTargets.count, 1)
        
        
    }
    
    func testDidTargetMultiple() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.count, 0)
        
        //when
        vm.didSelect(AnyAbility(RockASwap()))
        sendTiles()
        
        vm.didTarget(.zero)
        
        // verify
        XCTAssertEqual(vm.currentTargets.count, 1)
        
        //when
        vm.didTarget(TileCoord(0,3))
        
        // verify
        XCTAssertEqual(vm.currentTargets.count, 2)
        
        // when we try to target a 3rd, it removes an old target to add the new one
        vm.didTarget(TileCoord(0,4))
        
        //verify
        XCTAssertEqual(vm.currentTargets.count, 2)
        
        // when we try to target a 3rd, it removes an old target to add the new one
        vm.didTarget(TileCoord(0,5))
        
        //verify
        XCTAssertEqual(vm.currentTargets.count, 2)
        
        
        // when you target one that has already been chosen
        // it removes it
        
        vm.didTarget(TileCoord(0,5))
        
        //verify
        XCTAssertEqual(vm.currentTargets.count, 1)
        
        // when you target one that has already been chosen
        // it removes it
        
        vm.didTarget(.zero)
        
        //verify
        XCTAssertEqual(vm.currentTargets.count, 0)
    }
    
    func testAutoTargetPlayer() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.count, 0)
        
        //when
        vm.didSelect(AnyAbility(GreaterHealingPotion()))
        sendTiles()
        
        // verify
        XCTAssertEqual(vm.currentTargets.count, 1)
        
        
        
    }
    
    
    func testAutoTargetMonster() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.count, 0)
        
        //when
        vm.didSelect(AnyAbility(KillMonsterPotion()))
        
        // with 1 monster
        sendTiles(1)
        
        // verify
        XCTAssertEqual(vm.currentTargets.count, 1)
        
    }
    
    func testAutoTargetMonsterFail() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.count, 0)
        
        //when
        Dispatch.shared.send(Input(InputType.itemUseSelected(AnyAbility(KillMonsterPotion()))))
        
        // with 1 monster
        sendTiles(2)
        
        // verify
        XCTAssertEqual(vm.currentTargets.count, 0)
        
    }
    
    
    func testAutoTargetFail() {
        // given
        let vm = TargetingViewModel()
        XCTAssertEqual(vm.currentTargets.count, 0)
        
        //when
        Dispatch.shared.send(Input(InputType.itemUseSelected(AnyAbility(RockASwap()))))
        sendTiles()
        
        // verify
        XCTAssertEqual(vm.currentTargets.count, 0)
        
    }
    
    func testDidUseAbility() {
        // given
        let vm = TargetingViewModel()
        
        //when
        vm.didSelect(AnyAbility(RockASwap()))
        sendTiles()
        XCTAssertNotNil(vm.ability)
        vm.currentTargets = [Target(coord: .zero, isLegal: true), Target(coord: TileCoord(1, 2), isLegal: true)]
        vm.didUse(AnyAbility(RockASwap()))
        
        // verify
        XCTAssertNil(vm.ability)
    }
}
