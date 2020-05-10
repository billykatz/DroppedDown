//
//  StagingSelectionAreaView.swift
//  DownFall
//
//  Created by Katz, Billy on 5/3/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

class StagingSelectionAreaViewModel {
    let unlockedGoals: Int
    var selectedOffers: [StoreOffer]
    var touchDelegate: SKNode? = nil
    
    // input from outside
    var offerWasSelected: (StoreOffer) -> () = { _ in }
    var offerWasDeselected: (StoreOffer) -> () = { _ in }
    
    /// output
    var offerWasCanceled: (StoreOffer) -> () = { _ in }
    
    init(unlockedGoals: Int, selectedOffers: [StoreOffer]) {
        self.unlockedGoals = unlockedGoals
        self.selectedOffers = selectedOffers
    }
}

class StagingSelectionAreaView: SKSpriteNode {
    
    struct Constants {
        static let goalPadding = CGFloat(50.0)
        static let goalSize = CGSize.oneFifty
        static let cornerRadius = CGFloat(5.0)
        static let offerSpriteNameBase = "offerSpriteName"
    }
    
    let viewModel: StagingSelectionAreaViewModel
    let contentView: SKSpriteNode
    var offerSprite: SKSpriteNode?
    var selectedOffers: [StoreOffer] = []
    var stagingSelectedOfferViews: [StagingSelectedOfferView] = []

    
    init(viewModel: StagingSelectionAreaViewModel, size: CGSize) {
        self.viewModel = viewModel
        
        self.contentView = SKSpriteNode(color: .clear, size: size)
        super.init(texture: nil, color: .clear, size: size)
        self.viewModel.offerWasSelected = self.offerWasSelected
        self.viewModel.offerWasDeselected = self.offerWasDeselected
        
        addChild(contentView)
        
        setupOfferSlots()
        setupBackground()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func offerWasSelected(_ storeOffer: StoreOffer) {
        stagingSelectedOfferViews[storeOffer.tierIndex].update(with: storeOffer)
    }
    
    
    // remove the sprite of the offer from the stagin area
    func offerWasDeselected(_ storeOffer: StoreOffer) {
        stagingSelectedOfferViews[storeOffer.tierIndex].removeOffer()
    }
    
    func setupOfferSlots() {
        
        let width = Constants.goalSize.width * CGFloat(viewModel.unlockedGoals+2)
        let height = Constants.goalSize.height
        let divisor = CGFloat(viewModel.unlockedGoals+1)
        for idx in 0..<viewModel.unlockedGoals {
            
            let x = -width/2 + (CGFloat(idx) * width/divisor) + CGFloat(width/divisor)
            let y = -height/2 + Constants.goalSize.height/2
            let stagingSelectedOfferView = StagingSelectedOfferView(storeOffer: nil, size: Constants.goalSize, offerWasRemoved: self.offerWasRemoved)
            stagingSelectedOfferView.position = CGPoint(x: x, y: y)
            
            // add to scene
            contentView.addChild(stagingSelectedOfferView)
            
            //save for later
            stagingSelectedOfferViews.append(stagingSelectedOfferView)
        }
    }
    
    func offerWasRemoved(offer: StoreOffer) {
        viewModel.offerWasCanceled(offer)
    }
    
    func setupBackground() {
        let width = Constants.goalSize.width * CGFloat(viewModel.unlockedGoals+2)
        let height = contentView.frame.size.height
        let background = SKShapeNode(rect: CGRect(x: -width/2,
                                                  y: -height/2,
                                                  width: width,
                                                  height: height),
                                     cornerRadius: Constants.cornerRadius)
        background.color = .foregroundBlue
        background.zPosition = Precedence.foreground.rawValue
        background.position = .zero
        contentView.addChild(background)
    }
}


