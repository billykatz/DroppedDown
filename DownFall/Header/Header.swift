//
//  Header.swift
//  DownFall
//
//  Created by William Katz on 3/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class Header: SKSpriteNode {
    
    static func build(color: UIColor,
                      size: CGSize) -> Header {
        let header = Header(texture: SKTexture(imageNamed: "header"), color: color, size: size)
        let setting = SKSpriteNode(imageNamed: "setting")
        let settingX = header.frame.maxX - setting.frame.width/2
        setting.position = CGPoint(x: settingX, y: size.height/2 - setting.frame.height)
        setting.zPosition = 3.0
        
        header.addChild(setting)
        return header
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
