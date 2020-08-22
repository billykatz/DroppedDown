//
//  StoreScene.swift
//  DownFall
//
//  Created by William Katz on 7/31/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit


protocol StoreSceneDelegate: class {
    func leave(_ storeScene: StoreScene, updatedPlayerData: EntityModel)
}

protocol StoreSceneViewModelable {
    var offers: [StoreOffer] { get }
}

struct StoreSceneViewModel: StoreSceneViewModelable {
    let offers: [StoreOffer]
    let goalTracking: [GoalTracking]
    
    init(offers: [StoreOffer], goalTracking: [GoalTracking]) {
        self.offers = offers
        self.goalTracking = goalTracking
    }
}

class StoreScene: SKScene {
    
    struct Constants {
        static let gemWallet = "gemWallet"
        static let popup  = "popup"
        static let storeHUDHeight = CGFloat(350)
    }
    
    /// Store HUD
    private let storeHUD: StoreHUD
    private var storeHUDViewModel: StoreHUDViewModel
    
    /// Store Staging Area
    private let stagingArea: StagingAreaView
    
    private let viewModel: StoreSceneViewModel
    private let playableRect: CGRect
    private let background: SKSpriteNode
    private var playerData: EntityModel

    weak var storeSceneDelegate: StoreSceneDelegate?
    
    private var offerEffectTranslator = StoreOfferEffectTranslator()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    init(size: CGSize,
         playerData: EntityModel,
         levelGoalProgress: [GoalTracking],
         storeOffers: [StoreOffer],
         levelDepth: Int,
         viewModel: StoreSceneViewModel) {
        //playable rect
        playableRect = size.playableRect
        
        background = SKSpriteNode(color: .clayRed,
                                  size: playableRect.size)
        self.viewModel = viewModel
        self.playerData = playerData
        
        self.storeHUDViewModel = StoreHUDViewModel(currentPlayerData: playerData)
        self.storeHUD = StoreHUD(viewModel: storeHUDViewModel, size: CGSize(width: playableRect.width, height: Constants.storeHUDHeight))
        
        
        let trimmedOffers = StoreOffer.trimStoreOffers(storeOffers: storeOffers, playerData: playerData)
        let stagingViewModel = StagingAreaViewModel(storeOffers: trimmedOffers, goalProgress: levelGoalProgress, isBeforeLevelOne: levelDepth == 0)
        self.stagingArea = StagingAreaView(viewModel: stagingViewModel, size: CGSize(width: playableRect.width, height: playableRect.height - Constants.storeHUDHeight))
        
        /// Super init'd
        super.init(size: size)
        
        //acnhor point
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //set up call backs
        //staging area call backs
        stagingViewModel.offerWasStaged = self.offerWasStaged
        stagingViewModel.offerWasUnstagedByXButton = self.offerWasUnstagedByXButton
        
        // store HUD call backs
        storeHUDViewModel.effectUseCanceled = self.effectUseCanceled
        storeHUDViewModel.runeRelacedChanged = self.runeReplacedChanged
        
        /// Position and add the store hud
        storeHUD.position = CGPoint.position(storeHUD.frame, centeredInTopOf: playableRect, verticalOffset: Style.Padding.safeArea)
        storeHUD.zPosition = Precedence.foreground.rawValue
        addChild(storeHUD)
        
        /// Position and add the staging area
        stagingArea.position = CGPoint.alignHorizontally(stagingArea.frame, relativeTo: storeHUD.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        stagingArea.zPosition = Precedence.foreground.rawValue
        addChild(stagingArea)
        
        
        /// Background
        self.backgroundColor = .clayRed
        
        /// Leave store button
        let button = Button(size: .buttonExtralarge,
                            delegate: self,
                            identifier: .leaveStore,
                            precedence: .foreground,
                            fontSize:  .fontLargeSize,
                            fontColor: .black,
                            backgroundColor: .menuPurple)
        
        button.position = CGPoint.position(button.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most*3)
        
        
        background.addChild(button)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        
    }
    
    func runeReplacedChanged(_ rune: Rune) {
        if let offer = offerEffectTranslator.offer(for: .rune(rune)) {
            stagingArea.viewModel.runeReplacedChanged?(rune, offer)
        }
    }
    
    func effectUseCanceled(effect: EffectModel) {
        if let offer = offerEffectTranslator.translate(effect: effect) {
            self.stagingArea.viewModel.offerWasUnstaged?(offer)
        }
    }
    
    func offerWasStaged(offer: StoreOffer, unstagedOffer: StoreOffer?) {
        let effects = offerEffectTranslator.translate(offers: [offer, unstagedOffer])
        guard let first = effects.first else { return }
        var lastEffect: EffectModel? = nil
        if effects.count > 1, let last = effects.last {
            lastEffect = last
        }
        storeHUDViewModel.add(effect: first, remove: lastEffect)
    }
    
    func offerWasUnstagedByXButton(offer: StoreOffer) {
        let effects = offerEffectTranslator.translate(offers: [offer])
        guard let first = effects.first else { return }
        storeHUDViewModel.remove(effect: first)
    }
    
    func showLeaveStoreConfirmation() {
        let areYouSureMenu = MenuSpriteNode(.confirmation, playableRect: playableRect, precedence: .flying, level: .zero, buttonDelegate: self)
        areYouSureMenu.name = "areYouSureMenu"
        addChild(areYouSureMenu)
    }
}

extension StoreScene: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case .leaveStore:
            if stagingArea.hasSelectedAllOffers {
                /// allow player to move to next level
                storeSceneDelegate?.leave(self, updatedPlayerData: storeHUDViewModel.previewPlayerData)
            } else if childNode(withName: "areYouSureMenu") != nil {
                ///  the player has selected confirm with the menu on the screen
                storeSceneDelegate?.leave(self, updatedPlayerData: storeHUDViewModel.previewPlayerData)
                
            } else {
                /// show menu to ask the player if they are sure that they want to continue without selecting all the offers
                showLeaveStoreConfirmation()
                
            }
            
        case .backpackCancel:
            removeChild(with: "areYouSureMenu")
            
        case .backpackConfirm:
            /// allow player to move to next level
            storeSceneDelegate?.leave(self, updatedPlayerData: storeHUDViewModel.previewPlayerData)
            
        default:
            break
        }
    }
}

class StoreOfferEffectTranslator {
    
    var offerMap: [EffectModel: StoreOffer] = [:]
    
    func offer(for offerType: StoreOfferType) -> StoreOffer? {
        for (_, offer) in offerMap {
            if offer.type == offerType {
                return offer
            }
        }
        return nil
    }
    
    func translate(offers: [StoreOffer?]) -> [EffectModel] {
        return offers.compactMap { offer in
            switch offer?.type {
            case .fullHeal:
                let effect = EffectModel(kind: .refill, stat: .health, amount: 0, duration: 0, offerTier: offer?.tier ?? 0)
                offerMap[effect] = offer
                return effect
            case .plusTwoMaxHealth:
                let effect = EffectModel(kind: .buff, stat: .maxHealth, amount: 2, duration: Int.max, offerTier: offer?.tier ?? 0)
                offerMap[effect] = offer
                return effect
            case .rune(let rune):
                let effect = EffectModel(kind: .rune, stat: .pickaxe, amount: 0, duration: 0, rune: rune, offerTier: offer?.tier ?? 0)

                offerMap[effect] = offer
                return effect
            case .gems(let amount):
                let effect = EffectModel(kind: .buff, stat: .gems, amount: amount, duration: 0, offerTier: offer?.tier ?? 0)
                offerMap[effect] = offer
                return effect
            case .runeUpgrade:
                let effect = EffectModel(kind: .buff, stat: .pickaxe, amount: 10, duration: 0, offerTier: offer?.tier ?? 0)
                offerMap[effect] = offer
                return effect
            case .runeSlot:
                let effect = EffectModel(kind: .buff, stat: .runeSlot, amount: 1, duration: 0, offerTier: offer?.tier ?? 0)
                offerMap[effect] = offer
                return effect
            case .dodge:
                let effect = EffectModel(kind: .buff, stat: .dodge, amount: 5, duration: 0, offerTier: offer?.tier ?? 0)
                offerMap[effect] = offer
                return effect
            case .luck:
                let effect = EffectModel(kind: .buff, stat: .luck, amount: 5, duration: 0, offerTier: offer?.tier ?? 0)
                offerMap[effect] = offer
                return effect
            case .none:
                return nil
            }
        }
    }
    
    func translate(effect: EffectModel) -> StoreOffer? {
        return offerMap[effect]
    }
}
