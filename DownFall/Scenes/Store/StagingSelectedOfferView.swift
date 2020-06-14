//
//  StagingSelectedOfferView.swift
//  DownFall
//
//  Created by Katz, Billy on 5/9/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

class StagingSelectedOfferView: SKSpriteNode {
    var storeOffer: StoreOffer?
    let contentView: SKSpriteNode
    var offerWasRemoved: (StoreOffer) -> ()
    
    
    struct Constants {
        static let goalSize = CGSize.oneFifty
        static let cornerRadius = CGFloat(5.0)
        static let shapeName = "shapeName"
        static let closeName = "closeName"
    }
    
    init(storeOffer: StoreOffer?, size: CGSize, offerWasRemoved: @escaping (StoreOffer) -> ()) {
        self.storeOffer = storeOffer
        self.contentView = SKSpriteNode(color: .clear, size: size)
        self.offerWasRemoved = offerWasRemoved
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(contentView)
        self.zPosition = Precedence.aboveMenu.rawValue
        
        setupView()
        
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with offer: StoreOffer) {
        removeOffer()
        let offerSprite = offer.sprite
        
        /// grab the position that we saved earlier in setupOfferSlots
        offerSprite.size = .oneFifty
        offerSprite.zPosition = Precedence.aboveMenu.rawValue
        
        let xButtonEnlarger = SKSpriteNode(color: .clear, size: .oneHundred)
        let xButton = SKSpriteNode(texture: SKTexture(imageNamed: "buttonNegativeWhiteX"), size: CGSize(width: 35.0, height: 35.0))
        xButton.position = CGPoint.position(xButton.frame, inside: offerSprite.frame, verticalAlign: .top, horizontalAnchor: .right)
        xButton.zPosition = Precedence.aboveMenu.rawValue
        xButtonEnlarger.addChild(xButton)
        
        xButtonEnlarger.name = Constants.closeName
        offerSprite.addChild(xButtonEnlarger)
        /// add the sprite
        contentView.addChildSafely(offerSprite)
        
        self.storeOffer = offer

    }
    
    func removeOffer() {
        contentView.removeAllChildren(exclude: [Constants.shapeName])
    }
    
    private func setupView() {
        let shape = SKShapeNode(rect:
            CGRect(x: -Constants.goalSize.width/2,
                     y: -Constants.goalSize.height/2,
                     width: Constants.goalSize.width,
                     height: Constants.goalSize.height),
                cornerRadius: Constants.cornerRadius)
        shape.name = Constants.shapeName
        shape.zPosition = Precedence.menu.rawValue
        contentView.addChild(shape)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let offer = self.storeOffer else { return }
        let positionInScene = touch.location(in: self.contentView)
        let nodes = contentView.nodes(at: positionInScene)
        
        for node in nodes {
            if node.name?.contains(Constants.closeName) ?? false {
                offerWasRemoved(offer)
                contentView.removeAllChildren(exclude: [Constants.shapeName])
                
            }
        }

    }
}
