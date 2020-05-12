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
    let goalTracker: GoalTracking
    
    var selectedOffer: StoreOffer? {
        didSet {
            guard let offer = selectedOffer, offer.textureName != oldValue?.textureName ?? "" else { return }
            var otherOffer: StoreOffer? = nil
            if oldValue != nil { otherOffer = offers.first { $0.textureName != offer.textureName } }
            self.offerThatWasSelected(offer, otherOffer)
        }
    }
    var touchDelegate: SKNode
    
    /// input from outside world
    var offerWasSelected: () -> () = { }
    var offerWasDeselected: (StoreOffer) -> () = { _ in }
    var runeReplacedChanged: (Rune, StoreOffer) -> () = { _,_ in }
    
    // output
    let offerThatWasSelected: (StoreOffer, StoreOffer?) -> ()
    let offerWasTappedForInformation: (StoreOffer) -> ()
    
    init(offers: [StoreOffer], tier: Int, unlocked: Bool, touchDelegate: SKNode, offerThatWasSelected: @escaping (StoreOffer, StoreOffer?) -> (),
         offerWasTappedForInformation: @escaping (StoreOffer) -> (),
         goalTracker: GoalTracking) {
        self.offers = offers
        self.tier = tier
        self.unlocked = unlocked
        self.touchDelegate = touchDelegate
        self.offerThatWasSelected = offerThatWasSelected
        self.offerWasTappedForInformation = offerWasTappedForInformation
        self.goalTracker = goalTracker
    }
}

class StagingTierView: SKSpriteNode {
    
    struct Constants {
        static let dragThreshold = CGFloat(15.0)
    }
    
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
        self.viewModel.offerWasDeselected = self.offerWasDeselected
        self.viewModel.runeReplacedChanged = self.runeReplacedChanged
        
        /// response to user touch events
        self.isUserInteractionEnabled = true
        
        /// set up our views
        addChild(contentView)
        
        setupTierView()
        
        setupDelimiterView()
        
        setupTextView()
        
        setupGoalView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var replacedRuneSpriteConatiner: SKSpriteNode? = nil
    
    func runeReplacedChanged(_ rune : Rune, offer: StoreOffer) {
        replacedRuneSpriteConatiner = SKSpriteNode(color: .clear, size: .oneFifty)
        
        let runeSprite = SKSpriteNode(texture: SKTexture(imageNamed: rune.textureName), size: .oneFifty)
        
        let replaceText = ParagraphNode(text: "Replaced", paragraphWidth: runeSprite.frame.width*2, fontSize: UIFont.largeSize)
        replaceText.position = CGPoint.alignHorizontally(replaceText.frame, relativeTo: runeSprite.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        
        
        replacedRuneSpriteConatiner?.position = selectedSpritesOriginalPosition ?? .zero
        replacedRuneSpriteConatiner?.addChild(replaceText)
        replacedRuneSpriteConatiner?.addChild(runeSprite)
        addChildSafely(replacedRuneSpriteConatiner)
    }
    
    func offerWasSelected() {
        guard spriteToMove != nil else { return }
        
        /// if an ffer was selected at any point then we should remove the replace rune container
        /// This will break if we add more than two offers to the tier
        replacedRuneSpriteConatiner?.removeFromParent()
        replacedRuneSpriteConatiner = nil
        
        /// find the selected offer by comparing the sprite we were moving name to the name of the offer texture
        let selectedOffer = viewModel.offers.filter { $0.textureName == spriteToMove?.name }.first
        
        /// trigger our view model on the selected offer
        viewModel.selectedOffer = selectedOffer
        
        // hide the sprite and put it back in the original position
        spriteToMove?.isHidden = true
        spriteToMove?.position = selectedSpritesOriginalPosition ?? .zero
        spriteToMove = nil
        
        /// unhide the other offers we may have hidden
        let otherOffers = viewModel.offers.filter { $0.textureName != selectedOffer?.textureName }
        for offer in otherOffers {
            for sprite in addedSprites {
                if sprite.name == offer.textureName {
                    sprite.isHidden = false
                }
            }
        }
    }
    
    func offerWasDeselected(_ offer: StoreOffer) {
        /// at any point we deselect an offer, we should remove the replaced rune sprite
        replacedRuneSpriteConatiner?.removeFromParent()
        replacedRuneSpriteConatiner = nil
        
        //un hide all the offers as non are currently selected
        for offer in viewModel.offers {
            for sprite in addedSprites {
                if sprite.name == offer.textureName {
                    sprite.isHidden = false
                }
            }
        }
        
        //reset the selected offer so everything is back to the base state
        viewModel.selectedOffer = nil
    }
    
    func setupTierView() {
        guard viewModel.offers.count == 2 else { return }
        
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
        let horizontalRule = SKSpriteNode(color: .eggshellWhite, size: CGSize(width: contentView.frame.width, height: 2.0))
        
        horizontalRule.position = CGPoint.position(horizontalRule.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .center)
        
        contentView.addChild(horizontalRule)
    }
    
    func setupTextView() {
        let textString = viewModel.unlocked ?
            "Choose one."
            :
        "Complete \(viewModel.tier) goal\(viewModel.tier > 1 ? "s" : "") to unlock."
        
        let text = ParagraphNode(text: textString, paragraphWidth: contentView.frame.width, fontSize: UIFont.largeSize)
        text.position = CGPoint.position(text.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .center)
        
        contentView.addChild(text)
    }
    
    func setupGoalView() {
        let goalCircleViewModel = FillableCircleViewModel(horiztonal: false,
                                                          radius: 100.0,
                                                          total: viewModel.goalTracker.target,
                                                          progress: viewModel.goalTracker.current,
                                                          fillColor: viewModel.goalTracker.fillBarColor.0,
                                                          darkFillColor: viewModel.goalTracker.fillBarColor.1,
                                                          text: nil,
                                                          backgroundColor: .storeBlack)
        let goalCircleSprite = FillableCircleBar(size: .oneFifty, viewModel: goalCircleViewModel)
        goalCircleSprite.position = goalCircleSprite.position.translateVertically(-10.0)
        contentView.addChild(goalCircleSprite)
    }
    
    // MARK: Touch Events
    
    var touchIsDrag = false
    var lastTouchPoint: CGPoint? = nil
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            viewModel.touchDelegate.touchesBegan(touches, with: event)
        }
        
        guard let touch  = touches.first else { return }
        let point = touch.location(in: self.contentView)
        
        for sprite in addedSprites {
            if sprite.contains(point) && !sprite.isHidden {
                selectedSpritesOriginalPosition = sprite.position
                spriteToMove = sprite
                spriteToMove?.zPosition = Precedence.floating.rawValue
            }
        }

        touchIsDrag = false
        lastTouchPoint = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            viewModel.touchDelegate.touchesEnded(touches, with: event)
        }
        
        guard let touch  = touches.first else { return }
        let point = touch.location(in: self.contentView)
        
        if touchIsDrag {
            touchIsDrag = false
            /// if we are still moving a sprite then we havent reached the selection area
            if spriteToMove != nil {
                let action = SKAction.move(to: selectedSpritesOriginalPosition ?? .zero, duration: 0.25)
                
                spriteToMove?.run(action)
                spriteToMove = nil
            }
            return
        } else {
            for node in nodes(at: point)
            {
                if let offer = viewModel.offers.first(where: { $0.textureName == node.name }) {
                    viewModel.offerWasTappedForInformation(offer)
                }
            }
        }
        
        spriteToMove = nil
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard viewModel.unlocked else { return }
        
        defer {
            viewModel.touchDelegate.touchesMoved(touches, with: event)
        }
        guard let touch  = touches.first else { return }
        let point = touch.location(in: self.contentView)
        
        if lastTouchPoint == nil {
            lastTouchPoint = point
        }
        
        guard let lastPosition = lastTouchPoint else { return }
        let touchIsPastDragThreshold =
            (abs(point.x - lastPosition.x) > Constants.dragThreshold ||
                abs(point.y - lastPosition.y) > Constants.dragThreshold)
        
        guard touchIsPastDragThreshold || touchIsDrag else { return }
        
        touchIsDrag = true
        
        spriteToMove?.position = point.translate(xOffset: -50.0, yOffset:100.0)
    }
    
}

