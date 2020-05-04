//
//  StagingTierView.swift
//  DownFall
//
//  Created by Katz, Billy on 5/3/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

extension StoreOffer: Equatable {
    static func ==(lhsOffer: StoreOffer, rhsOffer: StoreOffer) -> Bool {
        return lhsOffer.type == rhsOffer.type
    }
}

class StagingTierViewModel {
    let offers: [StoreOffer]
    let tier: Int
    let unlocked: Bool
    var selectedOffer: StoreOffer? {
        didSet {
            guard let offer = selectedOffer, offer != oldValue else { return }
            self.offerThatWasSelected(offer)
        }
    }
    var touchDelegate: SKNode
    
    /// input from outside world
    var offerWasSelected: () -> () = { }
    
    // output
    var offerThatWasSelected: (StoreOffer) -> ()
    
    init(offers: [StoreOffer], tier: Int, unlocked: Bool, touchDelegate: SKNode, offerThatWasSelected: @escaping (StoreOffer) -> ()) {
        self.offers = offers
        self.tier = tier
        self.unlocked = unlocked
        self.touchDelegate = touchDelegate
        self.offerThatWasSelected = offerThatWasSelected
    }
}

class StagingTierView: SKSpriteNode {
    var viewModel: StagingTierViewModel
    let contentView: SKSpriteNode
    
    var addedSprites: [SKSpriteNode] = []
    
    private var spriteToMove: SKSpriteNode?
    private var selectedSpritesOriginalPosition: CGPoint? = nil
    
    
    init(viewModel: StagingTierViewModel, size: CGSize) {
        self.viewModel = viewModel
        contentView = SKSpriteNode(texture: nil, size: size)
        super.init(texture: nil, color: .clear, size: size)
        
        /// get informed when our offer is selected
        self.viewModel.offerWasSelected = self.offerWasSelected
        
        /// response to user touch events
        self.isUserInteractionEnabled = true
        
        /// set up our views
        addChild(contentView)
        
        setupTierView()
        
        setupDelimiterView()
        
        setupTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func offerWasSelected() {
        guard spriteToMove != nil else { return }
        let selectedOffer = viewModel.offers.filter { $0.textureName == spriteToMove?.name }.first
        viewModel.selectedOffer = selectedOffer
        // hide the sprite and put it back in the original position
        spriteToMove?.isHidden = true
        spriteToMove?.position = selectedSpritesOriginalPosition ?? .zero
        spriteToMove = nil
        
        let otherOffers = viewModel.offers.filter { $0.textureName != selectedOffer?.textureName }
        for offer in otherOffers {
            for sprite in addedSprites {
                if sprite.name == offer.textureName {
                    sprite.isHidden = false
                }
            }
        }
    }
    
    func setupTierView() {
        guard viewModel.offers.count == 2 else { preconditionFailure("This is not set up for more than 2 store offers") }
        
        let first = viewModel.offers.first!
        let second = viewModel.offers.last!
        
        let padding = Style.Padding.more*4
        
        let firstOfferSprite = first.sprite
        firstOfferSprite.name = first.textureName
        firstOfferSprite.size = .oneFifty
        firstOfferSprite.position = CGPoint.position(firstOfferSprite.frame, inside: contentView.frame, verticalAlign: .center, horizontalAnchor: .left, xOffset: padding)
        
        let secondOfferSprite = second.sprite
        secondOfferSprite.name = second.textureName
        secondOfferSprite.size = .oneFifty
        secondOfferSprite.position = CGPoint.position(secondOfferSprite.frame, inside: contentView.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: padding)
        
        contentView.addChild(firstOfferSprite)
        contentView.addChild(secondOfferSprite)
        
        addedSprites.append(firstOfferSprite)
        addedSprites.append(secondOfferSprite)
    }
    
    func setupDelimiterView() {
        let horizontalRule = SKSpriteNode(color: .black, size: CGSize(width: contentView.frame.width, height: 2.0))
        let horizontalRuleCopy = SKSpriteNode(color: .black, size: CGSize(width: contentView.frame.width, height: 2.0))
        
        horizontalRule.position = CGPoint.position(horizontalRule.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .center)
        horizontalRuleCopy.position = CGPoint.position(horizontalRuleCopy.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: .center)
        
        contentView.addChild(horizontalRule)
        contentView.addChild(horizontalRuleCopy)
    }
    
    func setupTextView() {
        let textString = viewModel.unlocked ?
            "Choose one."
            :
        "Complete \(viewModel.tier) goal\(viewModel.tier > 1 ? "s" : "") to unlock."
        
        let text = ParagraphNode(text: textString, paragraphWidth: contentView.frame.width)
        text.position = CGPoint.position(text.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .center)
        
        contentView.addChild(text)
    }
    
    // MARK: Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            viewModel.touchDelegate.touchesBegan(touches, with: event)
        }
        guard let touch  = touches.first else { return }
        let point = touch.location(in: self.contentView)
        for sprite in addedSprites {
            if sprite.contains(point) && !sprite.isHidden {
                print("contains point")
                selectedSpritesOriginalPosition = sprite.position
                spriteToMove = sprite
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            viewModel.touchDelegate.touchesMoved(touches, with: event)
        }
        guard let touch  = touches.first else { return }
        let point = touch.location(in: self.contentView)
        spriteToMove?.position = point.translate(xOffset: -50.0, yOffset:100.0)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            viewModel.touchDelegate.touchesEnded(touches, with: event)
        }
        
        /// if we are still moving a sprite then we havent reached the selection area
        if spriteToMove != nil {
            let action = SKAction.move(to: selectedSpritesOriginalPosition ?? .zero, duration: 0.25)
            
            spriteToMove?.run(action)
            spriteToMove = nil
        }
        
        
    }
    
}

