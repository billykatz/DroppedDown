//
//  BossTestScene.swift
//  DownFall
//
//  Created by Billy on 12/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class BossTestScene: SKScene {

    private(set) var foreground: SKNode!
 
    private var bossTestView: BossTestView?
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func commonInit() {
        //create the foreground node
        foreground = SKNode()
        foreground.position = .zero
        addChild(foreground)
        
        self.backgroundColor = .backgroundGray
        self.view?.ignoresSiblingOrder = true

    }
    
    override func didMove(to view: SKView) {
        self.bossTestView = BossTestView(foreground: foreground, playableRect: size.playableRect)
    }
}
