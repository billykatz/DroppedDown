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
        static let offerSpriteName = "offerSpriteName"
    }
    
    let viewModel: StagingSelectionAreaViewModel
    let contentView: SKSpriteNode
    var offerSprite: SKSpriteNode?
    
    init(viewModel: StagingSelectionAreaViewModel, size: CGSize) {
        self.viewModel = viewModel
        
        self.contentView = SKSpriteNode(color: .clear, size: size)
        super.init(texture: nil, color: .clear, size: size)
        self.viewModel.offerWasSelected = self.offerWasSelected
        
        addChild(contentView)
        
        setupOfferSlots()
        setupBackground()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func offerWasSelected(_ storeOffer: StoreOffer) {
        contentView.removeChild(with: Constants.offerSpriteName)
        offerSprite = storeOffer.sprite
        offerSprite?.size = .oneFifty
        offerSprite?.zPosition = Precedence.aboveMenu.rawValue
        offerSprite?.name = Constants.offerSpriteName
        contentView.addChildSafely(offerSprite)
    }
    
    func setupOfferSlots() {
        
        let width = Constants.goalSize.width
        let height = Constants.goalSize.height
        for _ in 0..<viewModel.unlockedGoals {
            let shape = SKShapeNode(rect: CGRect(x: -width/2,
                                                 y: -height/2,
                                                 width: Constants.goalSize.width,
                                                 height: Constants.goalSize.height),
                                    cornerRadius: Constants.cornerRadius)
            shape.zPosition = Precedence.menu.rawValue
            contentView.addChild(shape)
        }
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


