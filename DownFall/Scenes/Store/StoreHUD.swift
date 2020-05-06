//
//  StoreHUD.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

/// Visual representation of the player's current stats
/// This displays the player's
/// Health, number of gems and their pickace
/// In the future, this should display all the players stats like
/// Dodge, luck, armor, and status effects
class StoreHUD: SKSpriteNode {
    
    struct Constants {
        static let currentHealthLabelName = "currentHealthLabelName"
        static let totalHealthLabelName = "totalHealthLabelName"
    }
    
    private var viewModel: StoreHUDViewModel
    private let contentView: SKSpriteNode
    private var healthBarContainer: SKSpriteNode
    
    init(viewModel: StoreHUDViewModel, size: CGSize) {
        self.viewModel = viewModel
        contentView = SKSpriteNode(texture: nil, size: size)
        
        //create sizes
        let halfWidth = size.width/2
        let halfHeight = size.height/2
        let quarterSize = CGSize(width: halfWidth, height: halfHeight)
        
        /// Health Bar Container
        self.healthBarContainer = SKSpriteNode(color: .clear, size: quarterSize)
        
        super.init(texture: nil, color: .clear, size: size)
        
        /// hook up to the view models update hud
        self.viewModel.updateHUD = self.updateHUD
        self.viewModel.removedEffect = self.removedEffect
        self.viewModel.addedEffect = self.addedEffect
        
        setupContentView(size: size)
        
        contentView.color = .storeDarkGray
        
        addChild(contentView)
    }
    
    func removedEffect(_ effect: EffectModel) {
        switch effect.stat {
        case .health:
            if let currentHealthLabel = healthBarContainer.childNode(withName: Constants.currentHealthLabelName) as? ParagraphNode {
                animate(parentNode: healthBarContainer,
                        paragraphNode: currentHealthLabel,
                        start: viewModel.previewPlayerData.hp,
                        difference: -(viewModel.previewPlayerData.hp - viewModel.baseHealth))
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer.addChild(newHealthLabel)
                }
            }
        case .maxHealth:
            if let totalHealthLabel = healthBarContainer.childNode(withName: Constants.totalHealthLabelName) as? ParagraphNode {
                animate(parentNode: healthBarContainer,
                        paragraphNode: totalHealthLabel,
                        start: viewModel.previewPlayerData.originalHp,
                        difference: -effect.amount)
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer.addChild(newHealthLabel)
                }
            }
        default: ()
        }

    }
    
    func addedEffect(_ effect: EffectModel) {
        switch effect.stat {
        case .health:
            if let currentHealthLabel = healthBarContainer.childNode(withName: Constants.currentHealthLabelName) as? ParagraphNode {
                animate(parentNode: healthBarContainer,
                        paragraphNode: currentHealthLabel,
                        start: viewModel.baseHealth,
                        difference: viewModel.previewPlayerData.hp - viewModel.baseHealth)
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer.addChild(newHealthLabel)
                }
            }
        case .maxHealth:
            if let totalHealthLabel = healthBarContainer.childNode(withName: Constants.totalHealthLabelName) as? ParagraphNode {
                animate(parentNode: healthBarContainer,
                        paragraphNode: totalHealthLabel,
                        start: viewModel.totalHealth,
                        difference: effect.amount)
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer.addChild(newHealthLabel)
                }
            }
        default: ()
        }
    }
    
    func updateHUD() {
//        if viewModel.healthWasUpdated,
//            let currentHealthLabel = healthBarContainer.childNode(withName: Constants.currentHealthLabelName) as? ParagraphNode {
//            animate(parentNode: healthBarContainer,
//                    paragraphNode: currentHealthLabel,
//                    start: viewModel.pastHealth,
//                    difference: viewModel.healthDifference)
//            { [weak self] (newHealthLabel) in
//                self?.healthBarContainer.addChild(newHealthLabel)
//            }
//        } else if viewModel.maxHealthWasUpdate,
//            let totalHealthLabel = healthBarContainer.childNode(withName: Constants.totalHealthLabelName) as? ParagraphNode {
//            animate(parentNode: healthBarContainer,
//                    paragraphNode: totalHealthLabel,
//                    start: viewModel.pastOriginalHealth,
//                    difference: viewModel.originalHealthDifference)
//            { [weak self] (newHealthLabel) in
//                self?.healthBarContainer.addChild(newHealthLabel)
//            }
//        }
        
    }
    
    func setupContentView(size: CGSize) {
        contentView.removeAllChildren()
        
        let halfWidth = size.width/2
        let halfHeight = size.height/2
        let quarterSize = CGSize(width: halfWidth, height: halfHeight)
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.fullHeart), size: Style.HUD.heartSize)
        heartNode.position = CGPoint.position(heartNode.frame, inside: healthBarContainer.frame, verticalAlign: .center, horizontalAnchor: .left)
        
        let healthBar = FillableBar(size: quarterSize.scale(by: 0.25), viewModel: FillableBarViewModel(total: viewModel.totalHealth, progress: viewModel.baseHealth, fillColor: .red, backgroundColor: nil, text: nil, horiztonal: true))
        healthBar.position = CGPoint.alignVertically(healthBar.frame, relativeTo: heartNode.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        healthBar.zPosition = Precedence.menu.rawValue
        
        let currentHealthParagraph = ParagraphNode(text: "\(viewModel.baseHealth)", paragraphWidth: healthBarContainer.frame.maxX - healthBar.frame.maxX)
        let outOfParagraph = ParagraphNode(text: "/", paragraphWidth: healthBarContainer.frame.maxX - healthBar.frame.maxX)
        let totalHealthParagraph = ParagraphNode(text: "\(viewModel.totalHealth)", paragraphWidth: healthBarContainer.frame.maxX - healthBar.frame.maxX)

        currentHealthParagraph.position = CGPoint.alignVertically(currentHealthParagraph.frame, relativeTo: healthBar.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        currentHealthParagraph.name = Constants.currentHealthLabelName
        
        outOfParagraph.position = CGPoint.alignVertically(outOfParagraph.frame, relativeTo: currentHealthParagraph.frame, horizontalAnchor: .right, verticalAlign: .center)
        
        totalHealthParagraph.position = CGPoint.alignVertically(totalHealthParagraph.frame, relativeTo: outOfParagraph.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most)
        totalHealthParagraph.name = Constants.totalHealthLabelName
        
        healthBarContainer.addChild(currentHealthParagraph)
        healthBarContainer.addChild(outOfParagraph)
        healthBarContainer.addChild(totalHealthParagraph)
        healthBarContainer.addChild(heartNode)
        healthBarContainer.addChild(healthBar)
        healthBarContainer.position = CGPoint.position(healthBarContainer.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: .right)
        addChild(healthBarContainer)
        
        
        /// Currency View
        let currencyView = CurrencyView(viewModel: CurrencyViewModel(currency: .gem, amount: viewModel.totalGems), size: CGSize(width: halfWidth, height: halfHeight))
        
        currencyView.position = CGPoint.position(currencyView.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .right)
        addChild(currencyView)
        
        /// Pickaxe View
        let runeContainerViewModel = RuneContainerViewModel(runes: viewModel.pickaxe?.runes ?? [], numberOfRuneSlots: viewModel.pickaxe?.runeSlots ?? 0, runeWasTapped: nil, runeWasUsed: nil, runeUseWasCanceled: nil)
        let pickaxeView = RuneContainerView(viewModel: runeContainerViewModel, mode: .storeHUD, size: quarterSize)
        pickaxeView.position = CGPoint.position(currencyView.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: .left)
        pickaxeView.zPosition = Precedence.menu.rawValue
        
        addChild(pickaxeView)
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
