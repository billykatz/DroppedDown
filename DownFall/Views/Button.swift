//
//  Button.swift
//  DownFall
//
//  Created by William Katz on 3/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

class Button: SKSpriteNode {
    static func build(_ text: String, size: CGSize) -> Button {
        let button = Button.init(texture: nil, color: .white, size: size)
        let label = SKLabelNode(text: text)
        label.fontSize = 80
        label.zPosition = 5
        label.fontColor = .black
        label.fontName = "Helvetica-Bold"
        label.position = button.frame.center
        button.addChild(label)
        return button
    }
}
