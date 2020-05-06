//
//  StagingAreaView.swift
//  DownFall
//
//  Created by Katz, Billy on 5/3/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol StagingAreaViewModelable {
    
}

class StagingAreaViewModel: StagingAreaViewModelable {
    /// static offers
    let storeOffers: [StoreOffer]
    
    /// the goal progress
    let goalProgress: [GoalTracking]
    
    /// selected offers
    var stagedOffers: [StoreOffer] = []
    
    /// any swapped out runes
    var destroyedRunes: [Rune] = []
    
    // output
    var offerWasStaged: ((StoreOffer, StoreOffer?) -> ())? = nil
    
    init(storeOffers: [StoreOffer], goalProgress: [GoalTracking]) {
        self.storeOffers = storeOffers
        self.goalProgress = goalProgress
    }
    
}

class StagingAreaView: SKSpriteNode {
    
    struct Constants {
        static let offerSize: CGSize = .oneFifty
        static let selectionAreaToTierOnePadding = CGFloat(200)
    }
    
    var stagingTierViewModels: [StagingTierViewModel] = []
    let viewModel: StagingAreaViewModel
    let contentView: SKSpriteNode
    
    /// selection view model
    let stagingSelectionAreaViewModel: StagingSelectionAreaViewModel
    
    /// selection area
    let stagingSelectionAreaView: StagingSelectionAreaView
    
    func tierIsUnlocked(tier: Int, goalProgress: [GoalTracking]) -> Bool {
        /// TODO: reset when done testing
        return true
        return goalProgress.filter { $0.hasBeenRewarded }.count >= tier
    }
    
    
    // tier 1 area
    private lazy var tierOneArea: StagingTierView = {
        // tier area
        let tier = 1
        let vm = StagingTierViewModel(offers: viewModel.storeOffers.filter { $0.tier == tier }, tier: tier, unlocked: tierIsUnlocked(tier: tier, goalProgress: viewModel.goalProgress), touchDelegate: self, offerThatWasSelected: self.offerWasSelected)
        let tierOneArea = StagingTierView(viewModel: vm, size: CGSize(width: size.width, height: 300))
        tierOneArea.zPosition = Precedence.foreground.rawValue
        tierOneArea.position = CGPoint.alignHorizontally(tierOneArea.frame, relativeTo: stagingSelectionAreaView.frame, horizontalAnchor: .center, verticalAlign: .bottom)
        stagingTierViewModels.append(vm)
        return tierOneArea
    }()
    
    // tier 1 area
       private lazy var tierTwoArea: StagingTierView = {
           // tier area
           let tier = 2
           let vm = StagingTierViewModel(offers: viewModel.storeOffers.filter { $0.tier == tier }, tier: tier, unlocked: tierIsUnlocked(tier: tier, goalProgress: viewModel.goalProgress), touchDelegate: self, offerThatWasSelected: self.offerWasSelected)
           let tierTwoArea = StagingTierView(viewModel: vm, size: CGSize(width: size.width, height: 300))
           tierTwoArea.zPosition = Precedence.foreground.rawValue
           tierTwoArea.position = CGPoint.alignHorizontally(tierTwoArea.frame, relativeTo: tierOneArea.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
           stagingTierViewModels.append(vm)
           return tierTwoArea
       }()
    
    /// Touch property
    private var spriteToMove: SKSpriteNode?
    private var selectedSpritesOriginalPosition: CGPoint? = nil
    
    
    init(viewModel: StagingAreaViewModel, size: CGSize) {
        self.viewModel = viewModel
        self.contentView = SKSpriteNode(texture: nil, size: size)
        
        let unlockedGoals = 2//viewModel.goalProgress.filter { $0.hasBeenRewarded }.count
        // selection area
        stagingSelectionAreaViewModel = StagingSelectionAreaViewModel(unlockedGoals: unlockedGoals, selectedOffers: [])
        stagingSelectionAreaView = StagingSelectionAreaView(viewModel: stagingSelectionAreaViewModel, size: CGSize(width: size.width, height: 250))
        stagingSelectionAreaView.position = CGPoint.position(stagingSelectionAreaView.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
        
        
        super.init(texture: nil, color: .clear, size: size)
            
        // touch delegation
        stagingSelectionAreaViewModel.touchDelegate = self
        
        //user interaction
        self.isUserInteractionEnabled = true
        
        // add selection are to content view
        contentView.addChild(tierOneArea)
        contentView.addChild(tierTwoArea)
        contentView.addChild(stagingSelectionAreaView)
        
        // add contentView to scene
        addChild(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func offerWasSelected(offer: StoreOffer, deselected: StoreOffer?) {
        stagingSelectionAreaViewModel.offerWasSelected(offer)
        viewModel.offerWasStaged?(offer, deselected)
    }

    // MARK: Touch Events
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch  = touches.first else { return }
        let point = touch.location(in: self.contentView)
        
        if stagingSelectionAreaView.contains(point.translate(yOffset: 50.0)) {
            /// tell all the staging tier view models that one of their offers was potentially selected.  Basically all viewModels will get a message that says, if you were moving a sprite, it is now selected
            /// we will also need to tell the Selection Area that this happened so it can keep track opf it's state.
             stagingTierViewModels.forEach { $0.offerWasSelected() }
        }
    }

    //TODO: implement touches canceled to handle getting system alerts and things like that
}
