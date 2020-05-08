//
//  StoreHUD.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

struct ButtonAction {
    let button: ButtonIdentifier
    let action: (StoreMenuView) -> ()
}

struct StoreMenuViewModel {
    let title: String
    let body: String
    let backgroundColor: UIColor
    let buttonAction: ButtonAction
    var secondaryButtonAction: ButtonAction?
}

class StoreMenuView: SKSpriteNode, ButtonDelegate {
    let viewModel: StoreMenuViewModel
    let contentView: SKSpriteNode
    
    init(viewModel: StoreMenuViewModel, size: CGSize) {
        self.viewModel = viewModel
        contentView = SKSpriteNode(color: .clear, size: size)
        super.init(texture:nil, color: .clear, size: size)
        
        addChild(contentView)
        setupView()
    }
    
    func setupView() {
        
        /// background
        let backgroundView = SKSpriteNode(color: viewModel.backgroundColor, size: size)
        backgroundView.zPosition = Precedence.background.rawValue
        
        /// title
        let widthCoefficient = CGFloat(0.9)
        let titleNode = ParagraphNode.labelNode(text: viewModel.title, paragraphWidth: size.width * widthCoefficient,fontSize: UIFont.extraLargeSize)

        titleNode.position = CGPoint.position(titleNode.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
        titleNode.zPosition = Precedence.foreground.rawValue
        
        /// Body
        let bodyNode = ParagraphNode(text: viewModel.body, paragraphWidth: size.width * widthCoefficient, fontSize: UIFont.largeSize)
        bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        bodyNode.zPosition = Precedence.foreground.rawValue
        
        /// Button
        let horizontalPositioning: CGPoint.Anchor = viewModel.secondaryButtonAction == nil ? .center : .left
        let button = Button(size: Button.extralarge, delegate: self, identifier: viewModel.buttonAction.button, fontColor: UIColor.darkGray, backgroundColor: UIColor.eggshellWhite)
        button.position = CGPoint.position(button.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: horizontalPositioning, xOffset: Style.Padding.more, yOffset: Style.Padding.more)
        button.zPosition = Precedence.foreground.rawValue
        
        if let secondaryButtonAction = viewModel.secondaryButtonAction {
            let button = Button(size: Button.extralarge, delegate: self, identifier: secondaryButtonAction.button, fontColor: UIColor.darkGray, backgroundColor: UIColor.eggshellWhite)
            button.position = CGPoint.position(button.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: .right, xOffset: Style.Padding.more, yOffset: Style.Padding.more)
            button.zPosition = Precedence.foreground.rawValue
            contentView.addChild(button)
        }
        
        /// border
        let border = SKShapeNode(rect: self.frame)
        border.strokeColor = UIColor.darkBarPurple
        border.lineWidth = Style.Menu.borderWidth
        contentView.addChild(border)

        
        contentView.addChild(backgroundView)
        contentView.addChild(titleNode)
        contentView.addChild(bodyNode)
        contentView.addChild(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case viewModel.buttonAction.button:
            viewModel.buttonAction.action(self)
        case viewModel.secondaryButtonAction?.button:
            viewModel.secondaryButtonAction?.action(self)
        default:
            ()
        }
    }
    
}

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
    private var runeContainerView: RuneContainerView?
    
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
        self.viewModel.startRuneReplacement = self.startRuneReplacement
        
        setupContentView(size: size)
        
        contentView.color = .storeDarkGray
        
        addChild(contentView)
    }
    
    func createRuneContainerView(mode: ViewMode, playerData: EntityModel?) {
        let halfWidth = size.width/2
        let halfHeight = size.height/2
        let quarterSize = CGSize(width: halfWidth, height: halfHeight)
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
                                                            runeUseWasCanceled: nil)
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
    }
    
    
    func startRuneReplacement(_ effect: EffectModel) {
        guard let rune = effect.rune else { return }
        // save original size and position for later repositioning
        let originalSize = runeContainerView?.size ?? .zero
        let originalPosition = runeContainerView?.position ?? .zero
        
        // scale pickaxe up so it is easier to see
        let scaleAction = SKAction.scale(to: contentView.size, duration: 0.5)
        let moveAction = SKAction.move(to: .zero, duration: 0.5)
        
        // run the action and move out view up
        runeContainerView?.zPosition = Precedence.aboveMenu.rawValue
        runeContainerView?.run(SKAction.group([scaleAction, moveAction])) { [weak self] in
            self?.createRuneContainerView(mode: .storeHUDExpanded, playerData: self?.viewModel.previewPlayerData)
            


        }
        
        func cancelRuneReplacement(_ menuView: StoreMenuView) {
            let scaleAction = SKAction.scale(to: contentView.size.scale(by: 0.5), duration: 0.5)
            let moveAction = SKAction.move(to: originalPosition, duration: 0.5)
            runeContainerView?.zPosition = Precedence.aboveMenu.rawValue
            runeContainerView?.run(SKAction.group([scaleAction, moveAction])) { [weak self] in
                self?.viewModel.cancelRuneReplacement(effect: effect)
                self?.createRuneContainerView(mode: .storeHUD, playerData: self?.viewModel.previewPlayerData)
            }
            
            menuView.removeFromParent()
        }
        
        func confirmRuneReplacement(_ menu: StoreMenuView) {
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
        
        let viewModel = StoreMenuViewModel(title: "Rune Slots Full", body: "Select a rune to replace\nYou can reverse your decision", backgroundColor: .lightBarPurple, buttonAction: ButtonAction(button: .runeReplaceCancel, action: cancelRuneReplacement), secondaryButtonAction: ButtonAction(button: .runeReplaceConfirm, action: confirmRuneReplacement))
        let swapRunes = StoreMenuView(viewModel: viewModel, size: CGSize(width: contentView.frame.width * 0.8, height: 500.0))
        swapRunes.position = CGPoint.alignHorizontally(swapRunes.frame, relativeTo: contentView.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: 200.0)
        swapRunes.zPosition = Precedence.floating.rawValue
        addChild(swapRunes)
        
        
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
        case .pickaxe:
            self.createRuneContainerView(mode: .storeHUD, playerData: viewModel.previewPlayerData)
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
//        selectedRune
        self.createRuneContainerView(mode: .storeHUD, playerData: self.viewModel.previewPlayerData)
//        let runeContainerViewModel = RuneContainerViewModel(runes: viewModel.pickaxe?.runes ?? [], numberOfRuneSlots: viewModel.pickaxe?.runeSlots ?? 0, runeWasTapped: nil, runeWasUsed: nil, runeUseWasCanceled: nil)
//        let pickaxeView = RuneContainerView(viewModel: runeContainerViewModel, mode: .storeHUD, size: quarterSize)
//        pickaxeView.position = CGPoint.position(currencyView.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: .left)
//        pickaxeView.zPosition = Precedence.aboveMenu.rawValue
//        runeContainerView = pickaxeView
//        addChild(pickaxeView)
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
