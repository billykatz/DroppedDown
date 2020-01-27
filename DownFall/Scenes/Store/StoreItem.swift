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
    func wasTransactedOn(_ storeItem: StoreItem)
}

class StoreItem: SKSpriteNode {
    weak var storeItemDelegate: StoreItemDelegate?
    let ability: Ability
    var boxShapeNode: SKShapeNode?
    var isSelected = false {
        didSet {
            toggleSelection()
        }
    }
    var isPurchased = false {
        didSet {
            storeItemDelegate?.wasTransactedOn(self)
            togglePurchaseIndicator()
        }
    }
    
    init(ability: Ability,
         size: CGSize,
         color: UIColor = UIColor.storeItemBackground,
         delegate: StoreItemDelegate,
         identifier: ButtonIdentifier,
         precedence: Precedence,
         fontSize: CGFloat = UIFont.smallSize) {
        self.ability = ability
        super.init(texture: nil, color: color, size: size)
        
        let costLabel = Label(text: "\(ability.cost)",
                              width: self.frame.width,
                              delegate: self,
                              precedence: .menu,
                              identifier: .storeItem,
                              fontSize: fontSize)
            
        if let abilityFrames = ability.spriteSheet?.animationFrames(), let first = abilityFrames.first  {
            let sprite = SKSpriteNode(texture: first, color: .clear, size: Style.Store.Item.size)
            sprite.position = .zero
            sprite.name = ability.textureName
            sprite.run(SKAction.repeatForever(SKAction.animate(with: abilityFrames, timePerFrame: AnimationSettings.Store.itemFrameRate)))
            
            addChild(sprite)
        } else if let sprite = ability.sprite {
            sprite.position = .zero
            sprite.name = ability.textureName
            addChild(sprite)
        }
        
        
        boxShapeNode = SKShapeNode(rect: frame.applying(CGAffineTransform(scaleX: 1.4 , y: 1.7)))
        boxShapeNode?.strokeColor = .white
        boxShapeNode?.position = CGPoint(x: 0, y: -15)
        boxShapeNode?.lineWidth = 1.5
        addChild(boxShapeNode!)
        
        
        let currencyTexture = SKTexture(imageNamed: ability.currency.rawValue)
        let currencySprite = SKSpriteNode(texture: currencyTexture)
        currencySprite.position = CGPoint.positionThis(currencySprite.frame, inBottomOf: frame, padding: -30.0, anchor: .right)
        
        costLabel.position = CGPoint.positionThis(costLabel.frame, inBottomOf: frame, padding: -25.0 , anchor:.left, xOffset: 10.0)
        
        addChild(currencySprite)
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
            let highlight = SKShapeNode(path: CGPath(rect: boxShapeNode!.frame, transform: nil), centered: true)
            highlight.strokeColor = strokeColor
            highlight.fillColor = .clear
            highlight.name = highlightString
            highlight.lineWidth = 2.5
            highlight.zPosition = 2
            highlight.position = boxShapeNode!.position
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
    
    func labelPressCancelled(_ label: Label) {}
    
    func labelPressUnknown(_ label: Label, _ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}

//MARK:- Touch Events

extension StoreItem {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let translatedPosition = CGPoint(x: self.frame.center.x + position.x, y: self.frame.center.y + position.y)
        if self.frame.contains(translatedPosition) {
            self.storeItemDelegate?.storeItemTapped(self, ability: ability)
        } else {
            
            //TODO: make the store UI better
        }
    }
}
