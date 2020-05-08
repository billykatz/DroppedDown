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
    private var healthBarContainer: SKSpriteNode?
    private var runeContainerView: RuneContainerView?
    var storeMenuViewModel: StoreMenuViewModel?
    
    var halfWidth: CGFloat {
        return size.width/2
    }
    
    var halfHeight: CGFloat {
        return size.height/2
    }
    
    var quarterSize: CGSize {
        return CGSize(width: halfWidth, height: halfHeight)
    }
    
    init(viewModel: StoreHUDViewModel, size: CGSize) {
        self.viewModel = viewModel
        contentView = SKSpriteNode(texture: nil, size: size)
        
        
        super.init(texture: nil, color: .clear, size: size)
        
        /// Health Bar Container
        self.healthBarContainer = SKSpriteNode(color: .clear, size: quarterSize)
        
        /// hook up to the view models update hud
        self.viewModel.updateHUD = self.updateHUD
        self.viewModel.removedEffect = self.removedEffect
        self.viewModel.addedEffect = self.addedEffect
        self.viewModel.startRuneReplacement = self.startRuneReplacement
        
        setupContentView(size: size)
        
        contentView.color = .storeDarkGray
        
        addChild(contentView)
    }
    
    func createRuneContainerView(mode: ViewMode, playerData: EntityModel?) {
        let fullSize = contentView.size
        
        let sizeToUse = mode == .storeHUD ? quarterSize : fullSize
        
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
    
    var removedRune: Rune?
    
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
        storeMenuViewModel = StoreMenuViewModel(title: "Rune Slots Full", body: "Select a rune to replace\nYou can reverse your decision", backgroundColor: .lightBarPurple, mode: .runeReplacement(runeReplacementViewModel), buttonAction: ButtonAction(button: .runeReplaceCancel, action: canceled), secondaryButtonAction: ButtonAction(button: .runeReplaceConfirm, action: cofirmed))
        let swapRunes = StoreMenuView(viewModel: storeMenuViewModel!, size: CGSize(width: contentView.frame.width * 0.9, height: 800.0))
        swapRunes.position = CGPoint.alignHorizontally(swapRunes.frame, relativeTo: contentView.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: 200.0)
        swapRunes.zPosition = Precedence.floating.rawValue
        addChildSafely(swapRunes)
    }
    
    func removedEffect(_ effect: EffectModel) {
        switch effect.stat {
        case .health:
            if let healthBarContainer = healthBarContainer,
                let currentHealthLabel = healthBarContainer.childNode(withName: Constants.currentHealthLabelName) as? ParagraphNode {
                animate(parentNode: healthBarContainer,
                        paragraphNode: currentHealthLabel,
                        start: viewModel.previewPlayerData.hp,
                        difference: -(viewModel.previewPlayerData.hp - viewModel.baseHealth))
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer?.addChild(newHealthLabel)
                }
            }
        case .maxHealth:
            if let healthBarContainer = healthBarContainer, let totalHealthLabel = healthBarContainer.childNode(withName: Constants.totalHealthLabelName) as? ParagraphNode {
                animate(parentNode: healthBarContainer,
                        paragraphNode: totalHealthLabel,
                        start: viewModel.previewPlayerData.originalHp,
                        difference: -effect.amount)
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer?.addChild(newHealthLabel)
                }
            }
        case .pickaxe:
            self.createRuneContainerView(mode: .storeHUD, playerData: viewModel.previewPlayerData)
        default: ()
        }

    }
    
    func addedEffect(_ effect: EffectModel) {
        switch effect.stat {
        case .health:
            if let healthBarContainer = healthBarContainer, let currentHealthLabel = healthBarContainer.childNode(withName: Constants.currentHealthLabelName) as? ParagraphNode {
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
                let totalHealthLabel = healthBarContainer.childNode(withName: Constants.totalHealthLabelName) as? ParagraphNode {
                animate(parentNode: healthBarContainer,
                        paragraphNode: totalHealthLabel,
                        start: viewModel.totalHealth,
                        difference: effect.amount)
                { [weak self] (newHealthLabel) in
                    self?.healthBarContainer?.addChild(newHealthLabel)
                }
            }
        case .pickaxe:
            /// if the player has reach the max number of runes, make the pickaxe larger and trigger a replace rune flow
            self.createRuneContainerView(mode: .storeHUD, playerData: viewModel.previewPlayerData)
        default: ()
        }
    }
    
    func updateHUD() {
        
    }
    
    func setupContentView(size: CGSize) {
        contentView.removeAllChildren()
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.fullHeart), size: Style.HUD.heartSize)
        heartNode.position = CGPoint.position(heartNode.frame, inside: healthBarContainer?.frame, verticalAlign: .center, horizontalAnchor: .left)
        
        let healthBar = FillableBar(size: quarterSize.scale(by: 0.25), viewModel: FillableBarViewModel(total: viewModel.totalHealth, progress: viewModel.baseHealth, fillColor: .red, backgroundColor: nil, text: nil, horiztonal: true))
        healthBar.position = CGPoint.alignVertically(healthBar.frame, relativeTo: heartNode.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        healthBar.zPosition = Precedence.menu.rawValue
        
        let healthBarContainerMaxX = healthBarContainer?.frame.maxX ?? 0
        
        let currentHealthParagraph = ParagraphNode(text: "\(viewModel.baseHealth)", paragraphWidth: healthBarContainerMaxX - healthBar.frame.maxX)
        let outOfParagraph = ParagraphNode(text: "/", paragraphWidth: healthBarContainerMaxX - healthBar.frame.maxX)
        let totalHealthParagraph = ParagraphNode(text: "\(viewModel.totalHealth)", paragraphWidth: healthBarContainerMaxX - healthBar.frame.maxX)

        currentHealthParagraph.position = CGPoint.alignVertically(currentHealthParagraph.frame, relativeTo: healthBar.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        currentHealthParagraph.name = Constants.currentHealthLabelName
        
        outOfParagraph.position = CGPoint.alignVertically(outOfParagraph.frame, relativeTo: currentHealthParagraph.frame, horizontalAnchor: .right, verticalAlign: .center)
        
        totalHealthParagraph.position = CGPoint.alignVertically(totalHealthParagraph.frame, relativeTo: outOfParagraph.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most)
        totalHealthParagraph.name = Constants.totalHealthLabelName
        
        healthBarContainer?.addChild(currentHealthParagraph)
        healthBarContainer?.addChild(outOfParagraph)
        healthBarContainer?.addChild(totalHealthParagraph)
        healthBarContainer?.addChild(heartNode)
        healthBarContainer?.addChild(healthBar)
        healthBarContainer?.position = CGPoint.position(healthBarContainer?.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: .right)
        addChildSafely(healthBarContainer)
        
        
        /// Currency View
        let currencyView = CurrencyView(viewModel: CurrencyViewModel(currency: .gem, amount: viewModel.totalGems), size: CGSize(width: halfWidth, height: halfHeight))
        currencyView.position = CGPoint.position(currencyView.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .right)
        addChild(currencyView)
        
        /// Pickaxe View
        self.createRuneContainerView(mode: .storeHUD, playerData: self.viewModel.previewPlayerData)
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
