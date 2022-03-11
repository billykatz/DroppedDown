//
//  TileCreator+Screenshot.swift
//  DownFall
//
//  Created by Billy on 3/10/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import GameplayKit

extension TileCreator {
    
    static let gems25 = Tile(type: .item(Item(type: .gem, amount: 25, color: .blue)))
    static let basicPlayer = Tile(type: .player(.playerZero))
    
    func matchThreeScreenshot() -> [[Tile]] {
        [
            [.blueRock, .blueRock, .blueRock, .purpleRock, .purpleRock, .redRock],
            
            [.redRock, .blockedExit, .redRock, .purpleRock, .purpleRock, .blueRock],
            
            [.redRock, .purpleRock,  .purpleRock, .blueRock, .redRock, .redRock],
            
            [.purpleRock, .redRock, .blueRock, createPlayer(), .redRock, .blueRock],
            
            [.purpleRock, .purpleRock, .redRock, .redRock, .redRock, .purpleRock],
            
            [.blueRock, .blueRock, .blueRock, .blueRock, .redRock, .purpleRock]
        ]
    }
    

    
    func rotateScreenshot() -> [[Tile]] {
        [
            [.redRock, .redRock, .redRock, .purpleRock, .purpleRock, .redRock],
            
            [.redRock, .purpleRock, .blueRock, .blueRock, .blueRock, .blueRock],
            
            [.redRock, .purpleRock, createPlayer(), .purpleRock, TileCreator.gems25, .redRock],
            
            [.purpleRock, .redRock, .blueRock, .blueRock, .redRock, .blueRock],
            
            [.purpleRock, .purpleRock, .redRock, .redRock, .redRock, .blockedExit],
            
            [.blueRock, .blueRock, .blueRock, .blueRock, .redRock, .redRock]
        ]
    }
    
    func powerUpScreenshot() -> [[Tile]] {
        [
            [.purpleRock, .purpleRock, .redRock, .blueRock, .blueRock, .blueRock],
            
            [.purpleRock, .purpleRock, .redRock, .redRock, Tile.init(type: .offer(.offer(type: .plusOneMaxHealth, tier: 1))), .blueRock],
            
            [.purpleRock, .purpleRock, createPlayer(), .purpleRock, .redRock, .redRock],
            
            [.purpleRock, .redRock, .purpleRock, .blueRock, .redRock, .blueRock],
            
            [.blueRock, Tile.init(type: .offer(.offer(type: .chest, tier: 1))), .redRock, .redRock, .purpleRock, .blockedExit],
            
            [.blueRock, .redRock, .redRock, .blueRock, .purpleRock, .purpleRock]
        ]
    }
    
    func crushScreenshot() -> [[Tile]] {
        [
            [Tile.init(type: .offer(.offer(type: .wingedBoots, tier: 1))), .redRock, .redRock, .blueRock, .purpleRock, .purpleRock],
            
            [.purpleRock, .redRock, .blockedExit, .redRock, .purpleRock, .blueRock],
            
            [.purpleRock, .monster(.ratZero), .purpleRock, .redRock, .monster(.batZero), .redRock],
            
            [.purpleRock, .purpleRock, .redRock, .blueRock, createPlayer(), .blueRock],

            [.purpleRock, .redRock, .purpleRock, .blueRock, .redRock, .blueRock],
            
            [.blueRock, Tile.init(type: .offer(.offer(type: .killMonsterPotion, tier: 1))), .redRock, .monster(.alamoZero), .purpleRock, .redRock],
            
        ]
    }


    
    func createPlayer() -> Tile {
        if UITestRunningChecker.shared.testSwipeScreenShot {
            let playerData = EntityModel(originalHp: 3, hp: 3, name: "player", attack: .zero, type: .player, carry: .init(items: [.init(type: .gem, amount: 100)]), animations: [], pickaxe: .init(runeSlots: 1, runes: []), effects: [], dodge: 10, luck: 7, killedBy: nil)
            return Tile(type: .player(playerData))
        } else if UITestRunningChecker.shared.testMatchThreeScreenShot {
            let playerData = EntityModel(originalHp: 5, hp: 5, name: "player", attack: .zero, type: .player, carry: .init(items: [.init(type: .gem, amount: 200)]), animations: [], pickaxe: .init(runeSlots: 1, runes: []), effects: [], dodge: 5, luck: 12, killedBy: nil)
            return Tile(type: .player(playerData))
        } else if UITestRunningChecker.shared.testPowerUpScreenShot {
            let playerData = EntityModel(originalHp: 6, hp: 5, name: "player", attack: .zero, type: .player, carry: .init(items: [.init(type: .gem, amount: 275)]), animations: [], pickaxe: .init(runeSlots: 2, runes: [.rune(for: .fireball, isCharged: true)]), effects: [], dodge: 10, luck: 15, killedBy: nil)
            return Tile(type: .player(playerData))
        } else if UITestRunningChecker.shared.testIsCrushScreenShot {
            let playerData = EntityModel(originalHp: 7, hp: 4, name: "player", attack: .zero, type: .player, carry: .init(items: [.init(type: .gem, amount: 425)]), animations: [], pickaxe: .init(runeSlots: 2, runes: [.rune(for: .drillDown, isCharged: true), .rune(for: .fieryRage, isCharged: false)]), effects: [], dodge: 15, luck: 8, killedBy: nil)
            return Tile(type: .player(playerData))
        }
        else {
            return .player
        }
    }
    
    func boardForScreenshots() -> [[Tile]]? {
        #if DEBUG
        if UITestRunningChecker.shared.testSwipeScreenShot {
            return rotateScreenshot()
        } else if UITestRunningChecker.shared.testMatchThreeScreenShot {
            return matchThreeScreenshot()
        } else if UITestRunningChecker.shared.testPowerUpScreenShot {
            return powerUpScreenshot()
        } else if UITestRunningChecker.shared.testIsCrushScreenShot {
            return crushScreenshot()
        }
        else {
            return nil
        }
        #endif
        return nil
    }

    
}
