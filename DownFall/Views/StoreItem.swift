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
    func wasPurchased(_ storeItem: StoreItem)
}

class StoreItem: SKSpriteNode {
    weak var storeItemDelegate: StoreItemDelegate?
    let ability: Ability
    var isSelected = false {
        didSet {
            toggleSelection()
        }
    }
    var isPurchased = false {
        didSet {
            storeItemDelegate?.wasPurchased(self)
            togglePurchaseIndicator()
        }
    }
    
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
        isSelected = true
    }
    
    func deselect() {
        isSelected = false
    }
    
    func purchase() {
        isPurchased = true
    }
    
    func sell() {
        isPurchased = false
    }
    
    private func toggleSelection() {
        let selectionHighlight: SKShapeNode = {
            let strokeColor: UIColor = isPurchased ? .highlightGreen : .highlightGold
            let highlight = SKShapeNode(path: CGPath(rect: self.frame, transform: nil), centered: true)
            highlight.strokeColor = strokeColor
            highlight.fillColor = .clear
            highlight.name = highlightString
            highlight.lineWidth = 8.0
            highlight.zPosition = 2
            return highlight
        }()
        
        func select() {
            addChild(selectionHighlight)
        }
        
        func deselect() {
            for child in children {
                if child.name == highlightString {
                    child.removeFromParent()
                }
            }
        }
        
        isSelected ? select() : deselect()
    }
    
    private func togglePurchaseIndicator() {
        let grayOut: SKSpriteNode = {
            let grayOut = SKSpriteNode(color: .gray, size: self.size)
            grayOut.alpha = 0.9
            grayOut.zPosition = 1
            grayOut.name = "grayOut"
            return grayOut
        }()
        
        switch isPurchased {
        case true:
            addChild(grayOut)
        case false:
            for child in children {
                if child.name == "grayOut" {
                    child.removeFromParent()
                }
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func ==(_ lhs: StoreItem, rhs: StoreItem) -> Bool {
        return lhs.ability.type == rhs.ability.type && lhs.isPurchased == rhs.isPurchased
    }

}

extension StoreItem: LabelDelegate {
    func labelPressed(_ label: Label) {
        self.storeItemDelegate?.storeItemTapped(self, ability: ability)
    }
    
    func labelPressBegan(_ label: Label) {
        self.storeItemDelegate?.storeItemTapped(self, ability: ability)
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
