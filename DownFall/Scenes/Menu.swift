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
    
    weak var menuDelegate: MenuDelegate?
    
    override func didMove(to view: SKView) {
        titleLabel = self.childNode(withName: "titleLabel") as? SKLabelNode
        titleLabel.constraints = [
            SKConstraint.distance(SKRange(lowerLimit: 200, upperLimit: 300), to:  CGPoint(x: CGRect(origin: frame.origin, size: size).minX, y: 0)),
            SKConstraint.distance(SKRange(lowerLimit: 200, upperLimit: 300), to:  CGPoint(x: CGRect(origin: frame.origin, size: size).maxX, y: 0))
                ]
        
        titleLabel.numberOfLines = 0
        primaryLabel = self.childNode(withName: "primaryLabel") as? SKLabelNode
    }
    
    public func configure(title: String,
                   primary: String?,
                   delegate: MenuDelegate) {
        titleLabel.text = title
        if let primaryText = primary {
            primaryLabel.text = primaryText
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
    }
}
