//
//  Header.swift
//  DownFall
//
//  Created by William Katz on 3/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol SettingsDelegate: AnyObject {
    func settingsTapped()
}

class Header: SKSpriteNode {
    
    weak var delegate: SettingsDelegate?
    
    static func build(color: UIColor,
                      size: CGSize,
                      precedence: Precedence,
                      delegate: SettingsDelegate) -> Header {
        let header = Header(texture: nil, color: color, size: size)
        let setting = SKSpriteNode(imageNamed: Identifiers.settings)
        setting.size = .oneFifty
        setting.name = Identifiers.settings
        setting.position = CGPoint.position(setting.frame, centeredOnTheRightOf: header.frame, horizontalOffset: Style.Padding.more)
        setting.zPosition = precedence.rawValue
        
        header.delegate = delegate
        header.addChild(setting)
        header.isUserInteractionEnabled = true
        
        
        return header
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        for node in self.nodes(at: position) {
            if node.name == Identifiers.settings {
                delegate?.settingsTapped()
            }
        }
    }
}
