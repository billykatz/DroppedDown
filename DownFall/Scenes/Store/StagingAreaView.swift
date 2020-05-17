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
    
    // is before level 1
    let isBeforeLevelOne: Bool
    
    // output
    var offerWasStaged: ((StoreOffer, StoreOffer?) -> ())? = nil
    var offerWasUnstagedByXButton: ((StoreOffer) -> ())? = nil
    
    // input offer was unstage
    //TODO: need to figure out a way to translate an effect model back into a store offer
    var offerWasUnstaged: ((StoreOffer) -> ())? = nil
    var runeReplacedChanged: ((Rune, StoreOffer) -> ())? = nil
    
    init(storeOffers: [StoreOffer], goalProgress: [GoalTracking], isBeforeLevelOne: Bool) {
        self.storeOffers = storeOffers
        self.isBeforeLevelOne = isBeforeLevelOne
        /// sort the goals by the ones that have been rewarded first
        self.goalProgress = goalProgress.sorted(by: { goalA, goalB -> Bool in
            return goalA.hasBeenRewarded
        })
    }
    
}

class StagingAreaView: SKSpriteNode {
    
    struct Constants {
        static let offerSize: CGSize = .oneFifty
        static let selectionAreaToTierOnePadding = CGFloat(200)
        static let dragThreshold = CGFloat(15.0)
        static let stagingTierHeight = CGFloat(350)
    }
    
    var stagingTierViewModels: [StagingTierViewModel] = []
    let viewModel: StagingAreaViewModel
    let contentView: SKSpriteNode
    
    /// selection view model
    let stagingSelectionAreaViewModel: StagingSelectionAreaViewModel
    
    /// selection area
    let stagingSelectionAreaView: StagingSelectionAreaView
    
    /// Touch property
    private var spriteToMove: SKSpriteNode?
    private var selectedSpritesOriginalPosition: CGPoint? = nil
    
    func tierIsUnlocked(tier: Int, goalProgress: [GoalTracking]) -> Bool {
        /// TODO: reset when done testing
        return goalProgress.filter { $0.hasBeenRewarded }.count >= tier
    }
    
    // tier 1 area
    private lazy var tierOneArea: StagingTierView? = {
        // tier area
        let tier = 1
        guard viewModel.storeOffers.filter({$0.tier == tier }).count > 0 else { return nil}
        let tierIndex = 0
        let goalProgress = viewModel.goalProgress.optionalElement(at: tierIndex)
        let vm = StagingTierViewModel(offers: viewModel.storeOffers.filter { $0.tier == tier }, tier: tier, unlocked: tierIsUnlocked(tier: tier, goalProgress: viewModel.goalProgress) || viewModel.isBeforeLevelOne, touchDelegate: self, offerThatWasSelected: self.offerWasSelected, offerWasTappedForInformation: storeOfferWasTappedForInformation, goalTracker: goalProgress)
        let tierOneArea = StagingTierView(viewModel: vm, size: CGSize(width: size.width, height: Constants.stagingTierHeight))
        tierOneArea.zPosition = Precedence.foreground.rawValue
        tierOneArea.position = CGPoint.alignHorizontally(tierOneArea.frame, relativeTo: stagingSelectionAreaView.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        
        stagingTierViewModels.append(vm)
        return tierOneArea
    }()
    
    // tier 1 area
    private lazy var tierTwoArea: StagingTierView? = {
        // tier area
        let tier = 2
        let tierIndex = 1
        guard viewModel.storeOffers.filter({$0.tier == tier }).count > 0,
            let tierOneFrame = self.tierOneArea?.frame,
            tierIndex < viewModel.goalProgress.count
            else { return nil }
        let offer = viewModel.storeOffers.filter { $0.tier == tier }
        let vm = StagingTierViewModel(offers: offer,
                                      tier: tier,
                                      unlocked: tierIsUnlocked(tier: tier, goalProgress: viewModel.goalProgress),
                                      touchDelegate: self,
                                      offerThatWasSelected: self.offerWasSelected,
                                      offerWasTappedForInformation: storeOfferWasTappedForInformation,
                                      goalTracker: viewModel.goalProgress[tierIndex])
        let tierTwoArea = StagingTierView(viewModel: vm, size: CGSize(width: size.width, height: Constants.stagingTierHeight))
        tierTwoArea.zPosition = Precedence.foreground.rawValue
        tierTwoArea.position = CGPoint.alignHorizontally(tierTwoArea.frame, relativeTo: tierOneFrame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        stagingTierViewModels.append(vm)
        return tierTwoArea
    }()
    
    private lazy var tierThreeArea: StagingTierView? = {
        // tier area
        let tier = 3
        let tierIndex = 2
        guard viewModel.storeOffers.filter({$0.tier == tier }).count > 0,
            let tierTwoFrame = self.tierTwoArea?.frame,
            tierIndex < viewModel.goalProgress.count
            else { return nil }
        let offer = viewModel.storeOffers.filter { $0.tier == tier }
        let vm = StagingTierViewModel(offers: offer,
                                      tier: tier,
                                      unlocked: tierIsUnlocked(tier: tier, goalProgress: viewModel.goalProgress),
                                      touchDelegate: self,
                                      offerThatWasSelected: self.offerWasSelected,
                                      offerWasTappedForInformation: storeOfferWasTappedForInformation,
                                      goalTracker: viewModel.goalProgress[tierIndex])
        let tierThreeArea = StagingTierView(viewModel: vm, size: CGSize(width: size.width, height: Constants.stagingTierHeight))
        tierThreeArea.zPosition = Precedence.foreground.rawValue
        tierThreeArea.position = CGPoint.alignHorizontally(tierThreeArea.frame, relativeTo: tierTwoFrame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        stagingTierViewModels.append(vm)
        return tierThreeArea
    }()
    
    
    init(viewModel: StagingAreaViewModel, size: CGSize) {
        self.viewModel = viewModel
        self.contentView = SKSpriteNode(texture: nil, size: size)
        
        var unlockedGoals = viewModel.goalProgress.filter { $0.hasBeenRewarded }.count
        unlockedGoals += viewModel.isBeforeLevelOne ? 1 : 0
        // selection area
        stagingSelectionAreaViewModel = StagingSelectionAreaViewModel(unlockedGoals: unlockedGoals, selectedOffers: [])
        stagingSelectionAreaView = StagingSelectionAreaView(viewModel: stagingSelectionAreaViewModel, size: CGSize(width: size.width, height: 250))
        stagingSelectionAreaView.zPosition = Precedence.floating.rawValue
        stagingSelectionAreaView.position = CGPoint.position(stagingSelectionAreaView.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .center)
        
        
        super.init(texture: nil, color: .storeBlack, size: size)
        
        // touch delegation
        stagingSelectionAreaViewModel.touchDelegate = self
        
        // offer cancelation
        self.viewModel.offerWasUnstaged = self.offerWasUnselected
        self.viewModel.runeReplacedChanged = self.runeReplacedChanged
        stagingSelectionAreaViewModel.offerWasCanceled = self.offerWasUnselected
        
        //user interaction
        self.isUserInteractionEnabled = true
        
        // add selection are to content view
        contentView.addChildSafely(tierOneArea)
        contentView.addChildSafely(tierTwoArea)
        contentView.addChildSafely(tierThreeArea)
        contentView.addChild(stagingSelectionAreaView)
        
        // add contentView to scene
        addChild(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func runeReplacedChanged(_ rune: Rune, offer: StoreOffer) {
        stagingTierViewModels[offer.tierIndex].runeReplacedChanged(rune, offer)
    }
    
    func offerWasSelected(offer: StoreOffer, deselected: StoreOffer?) {
        stagingSelectionAreaViewModel.offerWasSelected(offer)
        viewModel.offerWasStaged?(offer, deselected)
    }
    
    func offerWasUnselected(_ offer: StoreOffer) {
        // tell the selection area
        stagingSelectionAreaViewModel.offerWasDeselected(offer)
        
        // tell each tier
        stagingTierViewModels[offer.tier-1].offerWasDeselected(offer)
        
        // tell out parente
        viewModel.offerWasUnstagedByXButton?(offer)
    }
    
    func storeOfferWasTappedForInformation(_ offer: StoreOffer) {
        let storeMenuViewModel = StoreMenuViewModel(title: offer.title, body: offer.description, backgroundColor: .lightBarPurple, mode: .offerDescription, buttonAction: ButtonAction(button: .okay, action: closeInformationalPopup))
        let storeMenu = StoreMenuView(viewModel: storeMenuViewModel, size: CGSize(width: self.contentView.frame.width * 0.9, height: 600.0))
        storeMenu.zPosition = Precedence.flying.rawValue
        contentView.addChild(storeMenu)
        
    }
    
    func closeInformationalPopup(_ storeMenuView: StoreMenuView) {
        storeMenuView.removeFromParent()
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
