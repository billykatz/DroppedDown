//
//  Menu.swift
//  DownFall
//
//  Created by William Katz on 3/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class MenuSpriteNode: SKSpriteNode {
    
    init(playableRect: CGRect) {
        let menuSizeWidth = playableRect.size.width * 0.5
        let menuSizeHeight = playableRect.size.height * 0.5
        super.init(texture: SKTexture(imageNamed: "menu"), color: .black, size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        
        let button = SKSpriteNode(imageNamed: "button")
        button.position = playableRect.center
        button.zPosition = 1
        button.size = CGSize(width: menuSizeWidth * 0.5, height: menuSizeHeight * 0.5)
//        button
        self.addChild(button)
        
        isUserInteractionEnabled = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
