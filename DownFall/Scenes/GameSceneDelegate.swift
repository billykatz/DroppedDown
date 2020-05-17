//
//  GameSceneDelegate.swift
//  DownFall
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol GameSceneCoordinatingDelegate: class {
    func reset(_ scene: SKScene, playerData: EntityModel)
    func resetToMain(_ scene: SKScene, playerData: EntityModel)
    func visitStore(_ playerData: EntityModel, _ goalProgress: [GoalTracking])
}
