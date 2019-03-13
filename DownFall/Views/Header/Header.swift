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
        setting.name = "setting"
        let settingX = header.frame.maxX - setting.frame.width
        setting.position = CGPoint(x: settingX, y: size.height/2 - setting.frame.height)
        setting.zPosition = 3
        
        header.addChild(setting)
        header.isUserInteractionEnabled = true
        return header
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        for node in self.nodes(at: position) {
            if node.name == "setting" {
                InputQueue.append(.pause)
            }
        }

    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
