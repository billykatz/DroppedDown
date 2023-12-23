//
//  LevelModel+TestScreenshots.swift
//  DownFall
//
//  Created by Billy on 3/10/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation

extension Level {
 
    func createScreenShotLevelGoals() -> [LevelGoal]? {
        guard UITestRunningChecker.shared.testsAreRunning else {
            return nil
        }
        
        if UITestRunningChecker.shared.testPowerUpScreenShot {
            let levelGoal1 = LevelGoal(type: .unlockExit, tileType: .rock(color: .blue, holdsGem: false, groupCount: 1), targetAmount: 0, minimumGroupSize: 1, grouped: false)
            let levelGoal2 = LevelGoal(type: .unlockExit, tileType: .monster(.zero), targetAmount: 5, minimumGroupSize: 1, grouped: false)
            
            return [levelGoal2, levelGoal1]
        } else if UITestRunningChecker.shared.testMatchThreeScreenShot {
            let levelGoal1 = LevelGoal(type: .unlockExit, tileType: .rock(color: .red, holdsGem: false, groupCount: 1), targetAmount: 20, minimumGroupSize: 1, grouped: false)
            let levelGoal2 = LevelGoal(type: .unlockExit, tileType: .monster(.zero), targetAmount: 5, minimumGroupSize: 1, grouped: false)
            
            return [levelGoal1, levelGoal2]

        } else if UITestRunningChecker.shared.testSwipeScreenShot {
            let levelGoal1 = LevelGoal(type: .unlockExit, tileType: .rock(color: .purple, holdsGem: false, groupCount: 1), targetAmount: 25, minimumGroupSize: 1, grouped: false)
            let levelGoal2 = LevelGoal(type: .unlockExit, tileType: .gem, targetAmount: 25, minimumGroupSize: 1, grouped: false)
            
            return [levelGoal1, levelGoal2]

        } else if UITestRunningChecker.shared.testIsCrushScreenShot {
            let levelGoal1 = LevelGoal(type: .unlockExit, tileType: .pillar(.init(color: .blue, health: 3)), targetAmount: 0, minimumGroupSize: 1, grouped: false)
            let levelGoal2 = LevelGoal(type: .unlockExit, tileType: .monster(.zero), targetAmount: 8, minimumGroupSize: 1, grouped: false)
            return [levelGoal1, levelGoal2]
        }
        
        else {
            let levelGoal1 = LevelGoal(type: .unlockExit, tileType: .rock(color: .purple, holdsGem: false, groupCount: 1), targetAmount: 25, minimumGroupSize: 1, grouped: false)
            let levelGoal2 = LevelGoal(type: .unlockExit, tileType: .gem, targetAmount: 25, minimumGroupSize: 1, grouped: false)
            
            return [levelGoal1, levelGoal2]
        }
    }
}
