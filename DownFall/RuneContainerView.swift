//
//  RuneContainerView.swift
//  DownFall
//
//  Created by Katz, Billy on 4/23/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol RuneContainerViewModelable {
    var runeWasTapped: ((AnyAbility) -> ())? { get }
    var runeWasUsed: ((AnyAbility) -> ())? { get }
    var runeUseWasCanceled: (() -> ())? { get }
    
    var abilities: [AnyAbility] { get }
    var numberOfRuneSlots: Int { get }
}

struct RuneContainerViewModel: RuneContainerViewModelable {
    let runeWasTapped: ((AnyAbility) -> ())?
    let runeWasUsed: ((AnyAbility) -> ())?
    let runeUseWasCanceled: (() -> ())?
    
    let abilities: [AnyAbility]
    let numberOfRuneSlots: Int
    
    init(abilities: [AnyAbility],
         numberOfRuneSlots: Int,
         runeWasTapped: ((AnyAbility) -> ())?,
         runeWasUsed: ((AnyAbility) -> ())?,
         runeUseWasCanceled: (() -> ())?) {
        self.abilities = abilities
        self.numberOfRuneSlots = numberOfRuneSlots
        self.runeWasTapped = runeWasTapped
        self.runeWasUsed = runeWasUsed
        self.runeUseWasCanceled = runeUseWasCanceled
    }
}

class RuneContainerView: SKSpriteNode {
    let viewModel: RuneContainerViewModelable
    let mode: ViewMode
    
    struct Constants {
        static let runeName = "rune"
        static let runeDetailViewName = "runeDetailView"
    }
    
    init(viewModel: RuneContainerViewModelable, mode: ViewMode, size: CGSize) {
        self.viewModel = viewModel
        self.mode = mode
        super.init(texture: nil, color: .clear, size: size)
        isUserInteractionEnabled = true
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func runeWasTapped(ability: AnyAbility?, progress: Int) {
        /// They have tapped on a rune slot, it maybe empty or have a rune
        if let ability = ability {
            // The player tapped on a full rune slot.  Let someone know that we should etner targeting move
            viewModel.runeWasTapped?(ability)
        }
        
        setupRuneDetailView(ability: ability, progress: progress)
        toggleRuneSlots()
    }
    
    private func runeWasUsed(ability: AnyAbility) {
        viewModel.runeWasUsed?(ability)
        removeChild(with: Constants.runeDetailViewName)
        toggleRuneSlots()
    }
    
    private func runeUseWasCanceled() {
        viewModel.runeUseWasCanceled?()
        removeChild(with: Constants.runeDetailViewName)
        toggleRuneSlots()
    }
    
    private func setupRuneDetailView(ability: AnyAbility?, progress: Int) {
        let runeDetailView = RuneDetailView(viewModel: RuneDetailViewModel(ability: ability,
                                                                           progress: CGFloat(progress),
                                                                           confirmed: runeWasUsed,
                                                                           canceled: runeUseWasCanceled), size: size)
        runeDetailView.name = Constants.runeDetailViewName
        addChild(runeDetailView)
    }
    
    private func toggleRuneSlots() {
        for child in children {
            if child.name == Constants.runeName {
                child.isHidden = !child.isHidden
                child.alpha = isHidden ? 0.0 : 1.0
            }
        }
    }
    
    private func setupView() {
        setupBackground()
        setupRuneSlots()
    }
    
    private func setupBackground() {
        /// Pickaxe Handle
        let identifier = Identifiers.backgroundPickaxeHandle
        
        /// the pixaxe sprite is 1:1.5 width:height ratio
        let width = frame.width
        let height = CGFloat(48)/CGFloat(128) * width
        let pickaxeHandlePiece = SKSpriteNode(texture: SKTexture(imageNamed: identifier),
                                              size: CGSize(width: width, height: height))
        pickaxeHandlePiece.position = .zero
        pickaxeHandlePiece.zPosition = Precedence.underground.rawValue
        
        pickaxeHandlePiece.position = CGPoint.position(pickaxeHandlePiece.frame,
                                                       inside: frame,
                                                       verticalAlign: .center,
                                                       horizontalAnchor: .center)
        
        addChild(pickaxeHandlePiece)
    }
    
    private func setupRuneSlots() {
        //TODO: get rune slots from the player data
        for index in 0..<4 {
            guard index < viewModel.numberOfRuneSlots else { return }
            
            let ability = viewModel.abilities.optionalElement(at: index)
            let viewModel = RuneSlotViewModel(rune: ability)
            let rune = RuneSlotView(viewModel: viewModel, size: .oneFifty)
            
            let runeY = CGFloat(0.0)
            let runeX = frame.minX + frame.width/CGFloat(8) + (frame.width/4.0 * CGFloat(index))
            
            rune.position = CGPoint(x: runeX, y: runeY)
            rune.zPosition = Precedence.menu.rawValue
            rune.name = Constants.runeName
            addChild(rune)
            
            viewModel.runeWasTapped = runeWasTapped
        }
    }
}
