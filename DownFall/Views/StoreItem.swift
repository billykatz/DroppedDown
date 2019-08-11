//
//  StoreItem.swift
//  DownFall
//
//  Created by William Katz on 8/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

let highlightString = "highlight"

protocol StoreItemDelegate: class {
    func storeItemTapped(_ storeItem: StoreItem, ability: Ability)
}

class StoreItem: SKSpriteNode {
    weak var storeItemDelegate: StoreItemDelegate?
    let ability: Ability
    var isSelected = false
    var isPurchased = false
    
    init(ability: Ability,
         size: CGSize,
         color: UIColor = UIColor(rgb: 0x8fa9af),
         delegate: StoreItemDelegate,
         identifier: ButtonIdentifier,
         precedence: Precedence,
         fontSize: CGFloat = 80) {
        self.ability = ability
        super.init(texture: nil, color: color, size: size)
        
        let costLabel = Label(text: "\(ability.cost) coins",
            delegate: self,
            precedence: .menu,
            identifier: .storeItem,
            fontSize: fontSize)
        let abilityForeground = SKSpriteNode(texture: SKTexture(imageNamed: ability.textureName), size: CGSize(width: 35, height: 35))
        
        costLabel.position = CGPoint(x: 0, y: -50)
        abilityForeground.position = .zero
        abilityForeground.name = ability.textureName
        addChild(abilityForeground)
        addChild(costLabel)
        position = .zero
        zPosition = precedence.rawValue
        isUserInteractionEnabled = true
        name = ability.textureName
        storeItemDelegate = delegate
    }
    
    func select() {
        guard !isPurchased else { return }
        let highlight = SKShapeNode(path: CGPath(rect: self.frame, transform: nil), centered: true)
        highlight.strokeColor = .highlightGold
        highlight.fillColor = .clear
        highlight.name = highlightString
        highlight.lineWidth = 8.0
        addChild(highlight)
        
        isSelected = true
    }
    
    func deselect() {
        for child in children {
            if child.name == highlightString {
                child.removeFromParent()
                isSelected = false
            }
        }
    }
    
    func purchase() {
        isPurchased = true
        deselect()
        
        let grayOut = SKSpriteNode(color: .gray, size: self.size)
        grayOut.alpha = 0.9
        addChild(grayOut)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StoreItem: LabelDelegate {
    func labelPressed(_ label: Label) {
    }
    
    func labelPressBegan(_ label: Label) {
    }
    
    
}

//MARK:- Touch Events

extension StoreItem {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.wasTouched(touches, with: event) {
            self.storeItemDelegate?.storeItemTapped(self, ability: ability)
        }
        
    }
}
