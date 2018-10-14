//
//  Menu.swift
//  DownFall
//
//  Created by William Katz on 9/21/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol MenuDelegate: class {
    func didTapPrimary()
    func didTapSecondary()
}

class Menu: SKScene {
    private var titleLabel: SKLabelNode!
    private var primaryLabel: SKLabelNode!
    private var secondaryLabel: SKLabelNode!
    
    weak var menuDelegate: MenuDelegate?
    
    override func didMove(to view: SKView) {
        titleLabel = self.childNode(withName: "titleLabel") as? SKLabelNode
        primaryLabel = self.childNode(withName: "primaryLabel") as? SKLabelNode
        secondaryLabel = self.childNode(withName: "secondaryLabel") as? SKLabelNode
    }
    
    public func configure(title: String,
                   primary: String?,
                   secondary: String?,
                   delegate: MenuDelegate) {
        titleLabel.text = title
        if let primaryText = primary {
            primaryLabel.text = primaryText
        }
        if let secondaryText = secondary {
            secondaryLabel.text = secondaryText
        }
    }
    
    
}


// MARK: Touch Relay

extension Menu {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if primaryLabel.contains(location) {
            menuDelegate?.didTapPrimary()
        }
        if secondaryLabel.contains(location) {
            menuDelegate?.didTapSecondary()
        }
    }
}
