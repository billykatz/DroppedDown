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
        static let healthBarName = "healthBarName"
        static let currencyViewName = "currencyViewName"
        static let totalDodgeLabelName = "totalDodgeLabelName"
        static let totalLuckLabelName = "totalLuckLabelName"
    }
    
    private var viewModel: StoreHUDViewModel
    private let contentView: SKSpriteNode
    private var healthBarContainer: SKSpriteNode?
    private var luckContainer: SKSpriteNode?
    private var dodgeContainer: SKSpriteNode?
    
    private var runeContainerView: RuneContainerView?
    var storeMenuViewModel: StoreMenuViewModel?
    var removedRune: Rune?
    var swapRunesMenuView: StoreMenuView?
    
    var halfWidth: CGFloat {
        return size.width/2
    }
    
    var halfHeight: CGFloat {
        return size.height/2
    }
    
    var quarterSize: CGSize {
        return CGSize(width: halfWidth, height: halfHeight)
    }
    
    var thirdWidth: CGFloat {
        return size.width/3
    }
    
    init(viewModel: StoreHUDViewModel, size: CGSize) {
        self.viewModel = viewModel
        contentView = SKSpriteNode(texture: nil, size: size)
        
        
        super.init(texture: nil, color: .clear, size: size)
        
        /// Health Bar Container
        self.healthBarContainer = SKSpriteNode(color: .clear, size: CGSize(width: thirdWidth, height: halfHeight))
        
        /// hook up to the view models update hud
        self.viewModel.updateHUD = self.updateHUD
        self.viewModel.removedEffect = self.removedEffect
        self.viewModel.addedEffect = self.addedEffect
        self.viewModel.startRuneReplacement = self.startRuneReplacement
        
        setupContentView(size: size)
        
        contentView.color = .storeDarkGray
        
        addChild(contentView)
    }
    
    func removedEffect(_ effect: EffectModel) {
        switch effect.stat {
        case .health:
            if let healthBarContainer = healthBarContainer,
                let currentHealthLabel = healthBarContainer.childNode(withName: Constants.currentHealthLabelName) as? ParagraphNode,
                let healthBar = healthBarContainer.childNode(withName: Constants.healthBarName) as? FillableBar{
                
                //redraw the health bar
                redrawHealthBarNode(healthBar, currentHealth: viewModel.baseHealth, totalHealth: viewModel.totalHealth)
                
                animate(parentNode: healthBarContainer,
                        paragraphNode: currentHealthLabel,
                        start: viewModel.previewPlayerData.hp,
                        difference: -(viewModel.previewPlayerData.hp - viewModel.baseHealth))
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer?.addChild(newHealthLabel)
                }
            }
        case .maxHealth:
            if let healthBarContainer = healthBarContainer, let totalHealthLabel = healthBarContainer.childNode(withName: Constants.totalHealthLabelName) as? ParagraphNode,
                let healthBar = healthBarContainer.childNode(withName: Constants.healthBarName) as? FillableBar{
                
                
                //redraw the health bar
                redrawHealthBarNode(healthBar, currentHealth: viewModel.baseHealth, totalHealth: viewModel.totalHealth)
                
                animate(parentNode: healthBarContainer,
                        paragraphNode: totalHealthLabel,
                        start: viewModel.previewPlayerData.originalHp,
                        difference: -effect.amount)
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer?.addChild(newHealthLabel)
                }
            }
        case .gems:
            if let currencyView = contentView.childNode(withName: Constants.currencyViewName) {
                currencyView.removeFromParent()
                redrawCurrencyView(newAmount: effect.amount, removed: true)
            }
        case .pickaxe:
            self.createRuneContainerView(mode: .storeHUD, playerData: viewModel.previewPlayerData)
            swapRunesMenuView?.removeFromParent()
        case .runeSlot:
            self.createRuneContainerView(mode: .storeHUD, playerData: viewModel.previewPlayerData)
        case .dodge:
            if let container = dodgeContainer,
                let dodgeLabel = container.childNode(withName: Constants.totalDodgeLabelName) as? ParagraphNode {
                animate(parentNode: container,
                        paragraphNode: dodgeLabel,
                        start: viewModel.previewPlayerData.dodge,
                        difference: -effect.amount)
                { [weak self] (newLabel) in
                    self?.dodgeContainer?.addChild(newLabel)
                }
            }

        case .luck:
            if let container = luckContainer,
                let luckLabel = container.childNode(withName: Constants.totalLuckLabelName) as? ParagraphNode {
                animate(parentNode: container,
                        paragraphNode: luckLabel,
                        start: viewModel.previewPlayerData.luck,
                        difference: -effect.amount)
                { [weak self] (newLabel) in
                    self?.luckContainer?.addChild(newLabel)
                }
            }
        }
        
    }
    
    func addedEffect(_ effect: EffectModel) {
        switch effect.stat {
        case .health:
            if let healthBarContainer = healthBarContainer, let currentHealthLabel = healthBarContainer.childNode(withName: Constants.currentHealthLabelName) as? ParagraphNode,
                let healthBar = healthBarContainer.childNode(withName: Constants.healthBarName) as? FillableBar
            {
                
                
                //redraw the health bar
                redrawHealthBarNode(healthBar, currentHealth: viewModel.previewPlayerData.hp, totalHealth: viewModel.previewPlayerData.originalHp)
                
                
                
                animate(parentNode: healthBarContainer,
                        paragraphNode: currentHealthLabel,
                        start: viewModel.baseHealth,
                        difference: viewModel.previewPlayerData.hp - viewModel.baseHealth)
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer?.addChild(newHealthLabel)
                }
            }
        case .maxHealth:
            if let healthBarContainer = healthBarContainer,
                let totalHealthLabel = healthBarContainer.childNode(withName: Constants.totalHealthLabelName) as? ParagraphNode,
                let healthBar = healthBarContainer.childNode(withName: Constants.healthBarName) as? FillableBar
            {
                //redraw the health bar
                redrawHealthBarNode(healthBar, currentHealth: viewModel.previewPlayerData.hp, totalHealth: viewModel.previewPlayerData.originalHp)
                
                // animate the numbers
                animate(parentNode: healthBarContainer,
                        paragraphNode: totalHealthLabel,
                        start: viewModel.totalHealth,
                        difference: effect.amount)
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer?.addChild(newHealthLabel)
                }
            }
        case .gems:
            if let currencyView = contentView.childNode(withName: Constants.currencyViewName) {
                currencyView.removeFromParent()
                redrawCurrencyView(newAmount: effect.amount, removed: false)
            }
        case .pickaxe:
            /// if the player has reach the max number of runes, make the pickaxe larger and trigger a replace rune flow
            self.createRuneContainerView(mode: .storeHUD, playerData: viewModel.previewPlayerData)
        case .runeSlot:
            self.createRuneContainerView(mode: .storeHUD, playerData: viewModel.previewPlayerData)
        case .dodge:
            if let container = dodgeContainer,
                let dodgeLabel = container.childNode(withName: Constants.totalDodgeLabelName) as? ParagraphNode {
                animate(parentNode: container,
                        paragraphNode: dodgeLabel,
                        start: viewModel.baseDodge,
                        difference: effect.amount)
                { [weak self] (newLabel) in
                    self?.dodgeContainer?.addChild(newLabel)
                }
            }

        case .luck:
            if let container = luckContainer,
                let luckLabel = container.childNode(withName: Constants.totalLuckLabelName) as? ParagraphNode {
                animate(parentNode: container,
                        paragraphNode: luckLabel,
                        start: viewModel.baseLuck,
                        difference: effect.amount)
                { [weak self] (newLabel) in
                    self?.luckContainer?.addChild(newLabel)
                }
            }
        }
    }
    
    func redrawCurrencyView(newAmount: Int, removed: Bool) {
        /// Currency View
        let gemAmount = removed ? viewModel.totalGems : viewModel.previewTotalGems
        let currencyView = CurrencyView(viewModel: CurrencyViewModel(currency: .gem, amount: gemAmount), size: CGSize(width: halfWidth, height: halfHeight))
        currencyView.position = CGPoint.position(currencyView.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .right)
        currencyView.name = Constants.currencyViewName
        contentView.addChild(currencyView)
    }
    
    func redrawHealthBarNode(_ healthBar: SKSpriteNode, currentHealth: Int, totalHealth: Int) {
        let oldPosition = healthBar.position
        healthBar.removeFromParent()
        let newHealthBar = FillableBar(size: quarterSize.scale(by: 0.25), viewModel: FillableBarViewModel(total: totalHealth, progress: currentHealth, fillColor: .red, backgroundColor: nil, text: nil, horiztonal: true))
        newHealthBar.position = oldPosition
        newHealthBar.zPosition = Precedence.menu.rawValue
        newHealthBar.name = Constants.healthBarName
        self.healthBarContainer?.addChild(newHealthBar)
    }
    
    func updateHUD() {
        
    }
    
    func setupContentView(size: CGSize) {
        contentView.removeAllChildren()
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.fullHeart), size: .fifty)
        heartNode.position = CGPoint.position(heartNode.frame, inside: healthBarContainer?.frame, verticalAlign: .center, horizontalAnchor: .left)
        
        let healthBar = FillableBar(size: quarterSize.scale(by: 0.25), viewModel: FillableBarViewModel(total: viewModel.totalHealth, progress: viewModel.baseHealth, fillColor: .red, backgroundColor: nil, text: nil, horiztonal: true))
        healthBar.position = CGPoint.alignVertically(healthBar.frame, relativeTo: heartNode.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        healthBar.zPosition = Precedence.menu.rawValue
        healthBar.name = Constants.healthBarName
        
        let healthBarContainerMaxX = healthBarContainer?.frame.maxX ?? 0
        
        let currentHealthParagraph = ParagraphNode(text: "\(viewModel.baseHealth)", paragraphWidth: healthBarContainerMaxX - healthBar.frame.maxX)
        let outOfParagraph = ParagraphNode(text: "/", paragraphWidth: healthBarContainerMaxX - healthBar.frame.maxX)
        let totalHealthParagraph = ParagraphNode(text: "\(viewModel.totalHealth)", paragraphWidth: healthBarContainerMaxX - healthBar.frame.maxX)
        
        currentHealthParagraph.position = CGPoint.alignVertically(currentHealthParagraph.frame, relativeTo: healthBar.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
        currentHealthParagraph.name = Constants.currentHealthLabelName
        
        outOfParagraph.position = CGPoint.alignVertically(outOfParagraph.frame, relativeTo: currentHealthParagraph.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
        
        totalHealthParagraph.position = CGPoint.alignVertically(totalHealthParagraph.frame, relativeTo: outOfParagraph.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.normal, translatedToBounds: true)
        totalHealthParagraph.name = Constants.totalHealthLabelName
        
        healthBarContainer?.addChild(currentHealthParagraph)
        healthBarContainer?.addChild(outOfParagraph)
        healthBarContainer?.addChild(totalHealthParagraph)
        healthBarContainer?.addChild(heartNode)
        healthBarContainer?.addChild(healthBar)
        healthBarContainer?.position = CGPoint.position(healthBarContainer?.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: .right)
        contentView.addChildSafely(healthBarContainer)
        
        
        /// Currency View
        let currencyView = CurrencyView(viewModel: CurrencyViewModel(currency: .gem, amount: viewModel.totalGems), size: CGSize(width: thirdWidth, height: halfHeight))
        currencyView.position = CGPoint.position(currencyView.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .right)
        currencyView.name = Constants.currencyViewName
        contentView.addChild(currencyView)
        
        /// Dodge View
        let dodgeContainer = SKSpriteNode(color: .clear, size: CGSize(width: thirdWidth, height: halfHeight))
        let dodgeSprite = SKSpriteNode(texture: SKTexture(imageNamed: "dodge"), size: .oneHundred)
        let dodgeAmountNode = ParagraphNode(text: "\(viewModel.baseDodge)", paragraphWidth: thirdWidth)
        
        dodgeSprite.position = CGPoint.position(dodgeSprite.frame, inside: dodgeContainer.frame, verticalAlign: .center, horizontalAnchor: .left, xOffset: Style.Padding.most)
        dodgeAmountNode.position = CGPoint.alignVertically(dodgeAmountNode.frame, relativeTo: dodgeSprite.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
        dodgeAmountNode.name = Constants.totalDodgeLabelName
        
        dodgeContainer.addChild(dodgeSprite)
        dodgeContainer.addChild(dodgeAmountNode)
        
        dodgeContainer.position = CGPoint.position(dodgeContainer.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .center)
        
        contentView.addChild(dodgeContainer)
        self.dodgeContainer = dodgeContainer
        
        
        /// Luck view
        let luckContainer = SKSpriteNode(color: .clear, size: CGSize(width: thirdWidth, height: halfHeight))
        let luckSprite = SKSpriteNode(texture: SKTexture(imageNamed: "luck"), size: .oneHundred)
        let luckAmountNode = ParagraphNode(text: "\(viewModel.baseLuck)", paragraphWidth: thirdWidth)
        
        luckSprite.position = CGPoint.position(luckSprite.frame, inside: luckContainer.frame, verticalAlign: .center, horizontalAnchor: .left)
        luckAmountNode.position = CGPoint.alignVertically(luckAmountNode.frame, relativeTo: luckSprite.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
        luckAmountNode.name = Constants.totalLuckLabelName
        
        luckContainer.addChild(luckSprite)
        luckContainer.addChild(luckAmountNode)
        
        luckContainer.position = CGPoint.position(luckContainer.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .left)
        
        contentView.addChild(luckContainer)
        self.luckContainer = luckContainer

        /// Pickaxe View
        self.createRuneContainerView(mode: .storeHUD, playerData: self.viewModel.previewPlayerData)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK: Rune Replacement
extension StoreHUD {
    func createRuneContainerView(mode: ViewMode, playerData: EntityModel?) {
        let fullSize = contentView.size
        
        let sizeToUse = mode == .storeHUD ? CGSize(width: 2*thirdWidth, height: halfHeight) : fullSize
        
        let positionToUse = mode == .storeHUD ?
            CGPoint.position(CGRect(origin: .zero, size: sizeToUse), inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: .left)
            :
            .zero
        
        
        let playerData = playerData ?? viewModel.previewPlayerData
        /// Add a new rune container with an updated view mode to avoid scaling issues
        let runeContainerViewModel = RuneContainerViewModel(runes: playerData.pickaxe?.runes ?? [],
                                                            numberOfRuneSlots: playerData.pickaxe?.runeSlots ?? 0,
                                                            runeWasTapped: selectedRune,
                                                            runeWasUsed: nil,
                                                            runeUseWasCanceled: deselctedRune)
        let pickaxeView = RuneContainerView(viewModel: runeContainerViewModel,
                                            mode: mode,
                                            size: sizeToUse)
        pickaxeView.position = positionToUse
        pickaxeView.zPosition = Precedence.aboveMenu.rawValue
        runeContainerView?.removeFromParent()
        runeContainerView = pickaxeView
        contentView.addChildSafely(runeContainerView)
    }
    
    func selectedRune(_ rune: Rune) {
        self.removedRune = rune
        storeMenuViewModel?.selectedRuneToReplace(rune)
        
    }
    
    func deselctedRune() {
        removedRune = nil
        storeMenuViewModel?.deselectedRuneToReplace()
    }
    
    func cancelRuneReplacement(_ menuView: StoreMenuView, effect: EffectModel, originalPosition: CGPoint) {
        let scaleAction = SKAction.scale(to: contentView.size.scale(by: 0.5), duration: 0.5)
        let moveAction = SKAction.move(to: originalPosition, duration: 0.5)
        runeContainerView?.zPosition = Precedence.aboveMenu.rawValue
        runeContainerView?.run(SKAction.group([scaleAction, moveAction])) { [weak self] in
            self?.createRuneContainerView(mode: .storeHUD, playerData: self?.viewModel.previewPlayerData)
            self?.viewModel.cancelRuneReplacement(effect: effect)
        }
        
        menuView.removeFromParent()
    }
    
    func confirmRuneReplacement(_ menu: StoreMenuView, effect: EffectModel, originalPosition: CGPoint) {
        guard let rune = removedRune else { return }
        self.viewModel.confirmRuneReplacement(effect: effect, removed: rune)
        
        /// preview the new pickaxe handle
        let newPickaxe = self.viewModel.previewPlayerData.pickaxe
        let runeContainerViewModel = RuneContainerViewModel(runes: newPickaxe?.runes ?? [], numberOfRuneSlots: newPickaxe?.runeSlots ?? 0, runeWasTapped: nil, runeWasUsed: nil, runeUseWasCanceled: nil)
        let pickaxeView = RuneContainerView(viewModel: runeContainerViewModel, mode: .storeHUDExpanded, size: runeContainerView?.size ?? .zero)
        pickaxeView.position = runeContainerView?.position ?? .zero
        pickaxeView.zPosition = Precedence.aboveMenu.rawValue
        runeContainerView?.removeFromParent()
        runeContainerView = pickaxeView
        
        /// add the rune container view back
        contentView.addChildSafely(runeContainerView)
        
        /// animate it back to where it lives
        let scaleAction = SKAction.scale(to: contentView.size.scale(by: 0.5), duration: 0.5)
        let moveAction = SKAction.move(to: originalPosition, duration: 0.5)
        runeContainerView?.zPosition = Precedence.aboveMenu.rawValue
        runeContainerView?.run(SKAction.group([scaleAction, moveAction])) { [weak self] in
            self?.createRuneContainerView(mode: .storeHUD, playerData: self?.viewModel.previewPlayerData)
        }
        
        
        /// remove the menu
        menu.removeFromParent()
    }
    
    func startRuneReplacement(_ effect: EffectModel) {
        guard effect.rune != nil else { return }
        // save original size and position for later repositioning
        let originalPosition = runeContainerView?.position ?? .zero
        
        // scale pickaxe up so it is easier to see
        let scaleAction = SKAction.scale(to: contentView.size, duration: 0.5)
        let moveAction = SKAction.move(to: .zero, duration: 0.5)
        
        // run the action and move out view up
        runeContainerView?.zPosition = Precedence.floating.rawValue
        runeContainerView?.run(SKAction.group([scaleAction, moveAction])) { [weak self] in
            self?.createRuneContainerView(mode: .storeHUDExpanded,
                                          playerData: self?.viewModel.previewPlayerData)
        }
        
        // show the rune replacement menu
        updateRuneReplacementMenu(effect: effect,
                                  originalPosition: originalPosition)
    }
    
    func updateRuneReplacementMenu(effect: EffectModel, originalPosition: CGPoint) {
        guard let rune = effect.rune else { return }
        
        func canceled(menuView: StoreMenuView) {
            cancelRuneReplacement(menuView, effect: effect, originalPosition: originalPosition)
        }
        
        func cofirmed(menuView: StoreMenuView) {
            confirmRuneReplacement(menuView, effect: effect, originalPosition: originalPosition)
        }
        
        let runeReplacementViewModel = RuneReplacementViewModel(newRune: rune, oldRune: nil)
        storeMenuViewModel = StoreMenuViewModel(title: "Rune Slots Full", body: "Tap a rune in your pickaxe handle", backgroundColor: .lightBarPurple, mode: .runeReplacement(runeReplacementViewModel), buttonAction: ButtonAction(button: .runeReplaceCancel, action: canceled), secondaryButtonAction: ButtonAction(button: .runeReplaceConfirm, action: cofirmed))
        let swapRunes = StoreMenuView(viewModel: storeMenuViewModel!, size: CGSize(width: contentView.frame.width * 0.9, height: 800.0))
        swapRunes.position = CGPoint.alignHorizontally(swapRunes.frame, relativeTo: contentView.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.more)
        swapRunes.zPosition = Precedence.flying.rawValue
        addChildSafely(swapRunes)
        swapRunesMenuView = swapRunes
    }
}
