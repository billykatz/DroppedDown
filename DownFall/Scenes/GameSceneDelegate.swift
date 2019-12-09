//
//  GameSceneDelegate.swift
//  DownFall
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol GameSceneCoordinatingDelegate: class {
    func reset(_ scene: SKScene)
    func selectLevel()
    func visitStore(_ playerData: EntityModel)
}
