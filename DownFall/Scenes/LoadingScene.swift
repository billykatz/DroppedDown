//
//  LoadingScene.swift
//  DownFall
//
//  Created by Katz, Billy on 7/18/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit


/// Displays a loading image
class LoadingScene: SKScene {
    
    var loadingSprite: SKSpriteNode?
    override func didMove(to view: SKView) {
    
        let background = SKSpriteNode(color: .backgroundGray, size: self.size)
        
        addChild(background)
        
        let ratio: CGFloat = 60.0/210.0
        let width = size.playableRect.width*0.8
        let height = width * ratio
        let loadingSprite = SKSpriteNode(texture: SKTexture(imageNamed: "logo"), size: CGSize(width: width, height: height))
        loadingSprite.zPosition = Precedence.menu.rawValue
        loadingSprite.position = .zero
        
        self.loadingSprite = loadingSprite
        
        background.addChild(loadingSprite)
    }
    
    func fadeOut(_ completion: @escaping (() -> ())) {
        let target = CGPoint.position(loadingSprite?.frame,
                               inside: size.playableRect,
                               verticalAlign: .top,
                               horizontalAnchor: .center,
                               yOffset: 150.0)
        let moveTo = SKAction.move(to: target, duration: 0.75)
        let group = SKAction.group([moveTo])
        group.timingMode = .easeInEaseOut
        loadingSprite?.run(group, completion: completion)
    }
}
