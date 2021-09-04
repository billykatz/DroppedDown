//
//  StoreItem.swift
//  DownFall
//
//  Created by William Katz on 8/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit


protocol StoreItemDelegate: AnyObject {
    func storeItemTapped(_ storeItem: StoreItem, offer: StoreOffer)
    func wasTransactedOn(_ storeItem: StoreItem)
}

class StoreItem: SKSpriteNode {
    weak var storeItemDelegate: StoreItemDelegate?
    let offer: StoreOffer
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
    
    init(storeOffer: StoreOffer,
         size: CGSize,
         color: UIColor = UIColor.storeItemBackgroundNotSelected,
         delegate: StoreItemDelegate,
         identifier: ButtonIdentifier,
         precedence: Precedence,
         fontSize: CGFloat = .fontExtraSmallSize) {
        
        self.offer = storeOffer
        
        super.init(texture: nil, color: color, size: size)
        
        let costLabel = Label(text: "\(offer.startingPrice)",
                              width: self.frame.width,
                              delegate: self,
                              precedence: .menu,
                              identifier: .storeItem,
                              fontSize: fontSize)
            
        let sprite = offer.sprite
        sprite.size = Style.Store.Item.size
        sprite.position = .zero
        sprite.name = offer.textureName
        
        addChildSafely(sprite)
        
        let currencyTexture = SKTexture(imageNamed: offer.currency.rawValue)
        let currencySprite = SKSpriteNode(texture: currencyTexture)
        currencySprite.position = CGPoint.alignHorizontally(currencySprite.frame, relativeTo: sprite.frame, horizontalAnchor: .left, verticalAlign: .bottom, translatedToBounds: true)
        costLabel.position = CGPoint.alignVertically(costLabel.frame, relativeTo: currencySprite.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        
        addChild(currencySprite)
        addChild(costLabel)
        position = .zero
        zPosition = precedence.rawValue
        isUserInteractionEnabled = true
        name = offer.textureName
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
        self.color = isSelected ? .foregroundBlue : .storeItemBackgroundNotSelected
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
        return lhs.offer.type == rhs.offer.type && lhs.isPurchased == rhs.isPurchased
    }

}

extension StoreItem: LabelDelegate {
    func labelPressed(_ label: Label) {
        self.storeItemDelegate?.storeItemTapped(self, offer: offer)
    }
    
    func labelPressBegan(_ label: Label) {
        self.storeItemDelegate?.storeItemTapped(self, offer: offer)
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
            self.storeItemDelegate?.storeItemTapped(self, offer: offer)
        } else {
            
            //TODO: make the store UI better
        }
    }
}
