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
        let fadeOut = SKAction.fadeOut(withDuration: 1.25)
        loadingSprite?.run(fadeOut, completion: completion)
    }
}
