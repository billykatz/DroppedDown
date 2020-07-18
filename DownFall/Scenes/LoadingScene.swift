//
//  LoadingScene.swift
//  DownFall
//
//  Created by Katz, Billy on 7/18/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit


class LoadingScene: SKScene {
    
    override func didMove(to view: SKView) {
    
        let background = SKSpriteNode(color: .backgroundGray, size: self.size)
        
        addChild(background)
        
        let ratio: CGFloat = 60.0/210.0
        let loadingSprite = SKSpriteNode(texture: SKTexture(imageNamed: "logo"), size: CGSize(width: size.playableRect.width*0.8, height: size.playableRect.width*0.8*ratio))
        loadingSprite.zPosition = Precedence.menu.rawValue
        loadingSprite.position = .zero
        
        background.addChild(loadingSprite)
    }
}
