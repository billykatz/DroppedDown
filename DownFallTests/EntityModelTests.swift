//
//  EntityModelTests.swift
//  DownFallTests
//
//  Created by William Katz on 5/18/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

@testable import DownFall

import XCTest

extension EntityModel {
    
    static func createPlayer(originalHp: Int = 3,
                             hp: Int = 3,
                             name: String = "player2",
                             attack: AttackModel = AttackModel.pickaxe,
                             type: EntityModel.EntityType = .player,
                             carry: CarryModel = .zero,
                             animations: AllAnimationsModel = .zero,
                             abilities: [AnyAbility] = []) -> EntityModel {
        return EntityModel(originalHp: originalHp,
                           hp: hp,
                           name: name,
                           attack: attack,
                           type: type,
                           carry: carry,
                           animations: animations,
                           abilities: abilities)
    }
    
    static func createMonster(originalHp: Int = 3,
                              hp: Int = 3,
                              name: String = "rat",
                              attack: AttackModel = AttackModel.swipe,
                              type: EntityModel.EntityType = .rat,
                              carry: CarryModel = .zero,
                              animations: AllAnimationsModel = .zero,
                              abilities: [AnyAbility] = []) -> EntityModel {
        return EntityModel(originalHp: originalHp,
                           hp: hp,
                           name: name,
                           attack: attack,
                           type: type,
                           carry: carry,
                           animations: animations,
                           abilities: abilities)
    }

}

class EntityModelTests: XCTestCase {
    
    func testEntityModelParsingFromData() {
        guard let data = try! Data.data(from: "EntityTest") else {
            XCTFail("Failed to json file");
            return
        }
        do {
            let entity = try JSONDecoder().decode(EntitiesModel.self, from: data).entities.first!
            XCTAssertEqual(entity.hp, 1)
            XCTAssertEqual(entity.name, "Gloop")
            
            let expectedRangeModel = RangeModel.one
            let expectedAttackModel = AttackModel(frequency: 0,
                                                  range: expectedRangeModel,
                                                  damage: 1,
                                                  directions: [.east, .west],
                                                  attacksThisTurn: 0,
                                                  attacksPerTurn: 1)
            XCTAssertEqual(entity.attack.frequency, expectedAttackModel.frequency)
            XCTAssertEqual(entity.attack.range, expectedAttackModel.range)
            XCTAssertEqual(entity.attack.directions, expectedAttackModel.directions)
        }
        catch {
            XCTFail("Failed JSON decode the Entity Model because \(error)")
        }
    }
    
    func json(from fileName: String) throws -> [String: Any]? {
        if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else {
                    return nil
                }
                return jsonResult
            } catch {
                // handle error
                XCTFail("\(error)")
            }
        }
        return nil
    }
    
    func assertBasePlayerStats(_ player: EntityModel) -> Bool {
        return player.canAttack
            && player.attack.attacksThisTurn == 0
            && player.attack.attacksPerTurn == 1
            && player.abilities.isEmpty
    }
    
    func testEntityAttacks() {
        let player = EntityModel.createPlayer()
        XCTAssertTrue(assertBasePlayerStats(player), "A base player has not yet attacked and can attack at most once a turn")
        
        let newPlayer = player.didAttack()
        
        XCTAssertFalse(newPlayer.canAttack, "A player cannot attack more than their defined attackersPerTurn")
        XCTAssertEqual(newPlayer.attack.attacksThisTurn, 1, "A player can attack once a turn")
        XCTAssertEqual(newPlayer.attack.attacksPerTurn, 1, "A player can attack once a turn")
    }
    
    func testEntityResetAttack() {
        let player = EntityModel.createPlayer()
        XCTAssertTrue(assertBasePlayerStats(player), "A base player has not yet attacked and can attack at most once a turn")
        
        let playerHasAttacked = player.didAttack()
        let playerHasReset = playerHasAttacked.resetAttacks()
        
        XCTAssertTrue(playerHasReset.canAttack, "After resetting attacks, a player can attack again")
        XCTAssertEqual(playerHasReset.attack.attacksThisTurn, 0, "A player can attack once a turn")
        XCTAssertEqual(playerHasReset.attack.attacksPerTurn, 1, "A player can attack once a turn")
    }
    
    func testEntityAddAbility() {
        let player = EntityModel.createPlayer()
        XCTAssertTrue(assertBasePlayerStats(player), "A base player has not yet attacked. A base player can attack at most once a turn.  A base player does not have any abilities")
        
        let doubleAttack = DoubleAttack()
        let playerGetsAbility = player.add(doubleAttack)
        
        XCTAssertTrue(playerGetsAbility.abilities.contains(where: { $0.textureName == doubleAttack.textureName}), "After gaining an ability, it exists within the player's abilities array")
    }
    
    func testEntityDoubleAttackAbility() {
        let player = EntityModel.createPlayer(abilities: [AnyAbility(DoubleAttack())])
        XCTAssertTrue(player.abilities.contains(where: { $0.textureName == DoubleAttack().textureName}), "After gaining an ability, it exists within the player's abilities array")
        
        //Player attacks
        let playerAttacksOnce = player.didAttack()
        
        XCTAssertTrue(playerAttacksOnce.canAttack, "A player with the double attack ability can attack once more than their defined attackersPerTurn")
        XCTAssertEqual(playerAttacksOnce.attack.attacksThisTurn, 1, "A player can attack once a turn")
        XCTAssertEqual(playerAttacksOnce.attack.attacksPerTurn, 1, "A player can attack once a turn")
        
        //Player attacks
        let playerAttackedTwice = playerAttacksOnce.didAttack()
        
        XCTAssertFalse(playerAttackedTwice.canAttack, "A player with the double attack ability can attack once more than their defined attackersPerTurn")
        XCTAssertEqual(playerAttackedTwice.attack.attacksThisTurn, 2, "A player with the double attack ability can attack once a turn")
        XCTAssertEqual(playerAttackedTwice.attack.attacksPerTurn, 1, "A player with the double attack ability still thinks it can only attack once a turn????")
        
    }
    
    func testPlayerReceivesDamager() {
        let rat = EntityModel.createMonster()
        let player = EntityModel.createPlayer()
        
        let playerTookDamage = player.wasAttacked(for: rat.attack.damage)
        
        XCTAssertEqual(playerTookDamage.hp, player.hp - rat.attack.damage, "A player takes damage equal to the rat's attack")
    }
    
    func testEntityRevives() {
        let player = EntityModel.createPlayer(hp: 0)
        
        XCTAssertEqual(player.hp, 0, "Player has no more hp")
        XCTAssertEqual(player.originalHp, player.revive().hp, "A player has it's original HP after being revived")
    }
    
    func testEntityRemovesAbility() {
        let doubleAttack = AnyAbility(DoubleAttack())
        let player = EntityModel.createPlayer(abilities:[doubleAttack])
        
        XCTAssertTrue(player.abilities.contains(doubleAttack), "Player has ability double attack")
        
        let updatedPlayer = player.remove(DoubleAttack())
        XCTAssertFalse(updatedPlayer.abilities.contains(doubleAttack), "Player no longer has ability double attack")
    }


    
}

