//
//  StoreHUD.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol PickaxeViewModelable {}

struct PickaxeViewModel: PickaxeViewModelable {
    
}

class PickaxeView: SKSpriteNode {
    let viewModel: PickaxeViewModelable
    
    init(viewModel: PickaxeViewModelable, size: CGSize) {
        self.viewModel = viewModel
        
        super.init(texture: nil, color: .lightBarPurple, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


protocol StoreHUDViewModelable {
    var currentHealth: Int { get }
    var totalHealth: Int { get }
    var totalGems: Int { get }
    var pickaxe: Pickaxe? { get }
    var healthText: String { get }
}

struct StoreHUDViewModel: StoreHUDViewModelable {
    
    var currentHealth: Int {
        return playerData.hp
    }
    
    var totalHealth: Int {
        return playerData.originalHp
    }
    
    var healthText: String {
        return "\(currentHealth)/\(totalHealth)"
    }
    
    var totalGems: Int {
        return playerData.carry.total(in: .gem)
    }
    
    var pickaxe: Pickaxe? {
        return playerData.pickaxe
    }
    
    let playerData: EntityModel
}

/// Visual representation of the player's current stats
/// This displays the player's
/// Health, number of gems and their pickace
/// In the future, this should display all the players stats like
/// Dodge, luck, armor, and status effects
class StoreHUD: SKSpriteNode {
    private let viewModel: StoreHUDViewModel
    private let contentView: SKSpriteNode
    
    init(viewModel: StoreHUDViewModel, size: CGSize) {
        self.viewModel = viewModel
        contentView = SKSpriteNode(texture: nil, size: size)
        
        super.init(texture: nil, color: .clear, size: size)
        
        setupContentView(size: size)
        
        contentView.color = .storeDarkGray
        
        addChild(contentView)
    }
    
    func setupContentView(size: CGSize) {
        let halfWidth = size.width/2
        let halfHeight = size.height/2
        let quarterSize = CGSize(width: halfWidth, height: halfHeight)
        
        /// Health Bar Container
        let healthBarContainer = SKSpriteNode(color: .clear, size: quarterSize)
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.fullHeart), size: Style.HUD.heartSize)
        heartNode.position = CGPoint.position(heartNode.frame, inside: healthBarContainer.frame, verticalAlign: .center, horizontalAnchor: .left)
        
        let healthBar = FillableBar(size: quarterSize.scale(by: 0.25), viewModel: FillableBarViewModel(total: viewModel.totalHealth, progress: viewModel.currentHealth, fillColor: .red, backgroundColor: nil, text: nil, horiztonal: true))
        healthBar.position = CGPoint.alignVertically(healthBar.frame, relativeTo: heartNode.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        healthBar.zPosition = Precedence.menu.rawValue
        
        let healthParagraph = ParagraphNode(text: viewModel.healthText, paragraphWidth: healthBarContainer.frame.maxX - healthBar.frame.maxX)
        healthParagraph.position = CGPoint.alignVertically(healthParagraph.frame, relativeTo: healthBar.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        
        healthBarContainer.addChild(healthParagraph)
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
