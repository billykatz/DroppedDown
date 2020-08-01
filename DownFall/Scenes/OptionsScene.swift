//
//  OptionsScene.swift
//  DownFall
//
//  Created by Katz, Billy on 7/26/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

class OptionsScene: SKScene {
    
    var foreground: SKSpriteNode!
    
    override func didMove(to view: SKView) {
    
        let foreground = SKSpriteNode(color: .backgroundGray, size: self.size)
        self.foreground = foreground
        addChild(foreground)
    }
}
