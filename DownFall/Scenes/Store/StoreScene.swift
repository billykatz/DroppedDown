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
    
    init(offers: [StoreOffer]) {
        self.offers = offers
    }
}

class StoreScene: SKScene {
    
    struct Constants {
        static let gemWallet = "gemWallet"
        static let popup  = "popup"
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
    private let level: Level

    weak var storeSceneDelegate: StoreSceneDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    init(size: CGSize,
         playerData: EntityModel,
         level: Level,
         viewModel: StoreSceneViewModel) {
        //playable rect
        playableRect = size.playableRect
        
        background = SKSpriteNode(color: .clayRed,
                                  size: playableRect.size)
        self.viewModel = viewModel
        self.playerData = playerData
        self.level = level
        
        self.storeHUDViewModel = StoreHUDViewModel(currentPlayerData: playerData, pastPlayerData: playerData)
        self.storeHUD = StoreHUD(viewModel: storeHUDViewModel, size: CGSize(width: playableRect.width, height: 350.0))
        
        let stagingViewModel = StagingAreaViewModel(storeOffers: level.storeOffering)
        self.stagingArea = StagingAreaView(viewModel: stagingViewModel, size: CGSize(width: playableRect.width, height: 600))
        
        /// Super init'd
        super.init(size: playableRect.size)
        
        stagingViewModel.offerWasStaged = self.offerWasStaged
        
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
        let button = Button(size: Button.large,
                            delegate: self,
                            identifier: .leaveStore,
                            precedence: .foreground,
                            fontSize:  UIFont.mediumSize,
                            fontColor: .black,
                            backgroundColor: .menuPurple)
        
        button.position = CGPoint.position(button.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most*3)
        
        
        background.addChild(button)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        
    }
    
    func offerWasStaged(offer: StoreOffer) {
        storeHUDViewModel.selected(offer: offer, deselected: nil)
    }
}

extension StoreScene: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case .leaveStore:
            storeSceneDelegate?.leave(self, updatedPlayerData: playerData)
        default:
            fatalError("You must add a case for added buttons here")
        }
    }
}
