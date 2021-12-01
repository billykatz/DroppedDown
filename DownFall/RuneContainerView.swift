//
//  RuneContainerView.swift
//  DownFall
//
//  Created by Katz, Billy on 4/23/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit
import Combine

protocol RuneContainerViewModelable: AnyObject {
    var runeWasTapped: ((Rune) -> ())? { get }
    var runeWasUsed: ((Rune) -> ())? { get }
    var runeUseWasCanceled: (() -> ())? { get }
    
    var runes: [Rune] { get }
    var numberOfRuneSlots: Int { get }
    var disableDetailView: Bool { get }
}

class RuneContainerViewModel: RuneContainerViewModelable {
    let runeWasTapped: ((Rune) -> ())?
    let runeWasUsed: ((Rune) -> ())?
    let runeUseWasCanceled: (() -> ())?
    
    let runes: [Rune]
    let numberOfRuneSlots: Int
    let disableDetailView: Bool
    
    init(runes: [Rune],
         numberOfRuneSlots: Int,
         runeWasTapped: ((Rune) -> ())?,
         runeWasUsed: ((Rune) -> ())?,
         runeUseWasCanceled: (() -> ())?,
         disableDetailView: Bool = false) {
        self.runes = runes
        self.numberOfRuneSlots = numberOfRuneSlots
        self.runeWasTapped = runeWasTapped
        self.runeWasUsed = runeWasUsed
        self.runeUseWasCanceled = runeUseWasCanceled
        self.disableDetailView = disableDetailView
    }
}

class RuneContainerView: SKSpriteNode {
    let viewModel: RuneContainerViewModelable
    var runeSlotViewModels: [RuneSlotViewModel] = []
    private var runeSlotViews:  [RuneSlotView] = []
    var disposables = Set<AnyCancellable>()
    
    struct Constants {
        static let runeName = "rune"
        static let runeDetailViewName = "runeDetailView"
    }
    
    init(viewModel: RuneContainerViewModelable, size: CGSize) {
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        isUserInteractionEnabled = true
        
        setupView()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func firstEmptyRuneSlotNode() -> RuneSlotView? {
        let runeSlotView = runeSlotViews.first { runeSlotView in
            return runeSlotView.viewModel.rune == nil
        }
        return runeSlotView
    }
    
    
    public func enableButton(_ enabled: Bool) {
        runeDetailView?.enableButton(enabled)
    }
    
    private func runeWasTapped(rune: Rune?, progress: Int) {
        /// They have tapped on a rune slot, it maybe empty or have a rune
        if let rune = rune {
            // The player tapped on a full rune slot.  Let someone know that we should etner targeting move
            viewModel.runeWasTapped?(rune)
        }
        
        // TODO: I dont like that we have to set this flag.  Butttt, it is simple.  Potential refactor may be necessary
        if viewModel.disableDetailView { return }
        
        setupRuneDetailView(rune: rune, progress: progress)
        toggleRuneSlots()
    }
    
    private func runeWasUsed(rune: Rune) {
        viewModel.runeWasUsed?(rune)
        removeChild(with: Constants.runeDetailViewName)
        toggleRuneSlots()
    }
    
    private func runeUseWasCanceled() {
        viewModel.runeUseWasCanceled?()
        removeChild(with: Constants.runeDetailViewName)
        toggleRuneSlots()
    }
    var runeDetailView: RuneDetailView?
    
    private func setupRuneDetailView(rune: Rune?, progress: Int) {
        let runeDetailView = RuneDetailView(viewModel: RuneDetailViewModel(rune: rune,
                                                                           progress: CGFloat(progress),
                                                                           confirmed: runeWasUsed,
                                                                           canceled: runeUseWasCanceled
                                                                          ),
                                            size: size)
        runeDetailView.name = Constants.runeDetailViewName
        addChild(runeDetailView)
        self.runeDetailView = runeDetailView
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
            let size: CGSize = .oneFifty
            let rune = viewModel.runes.optionalElement(at: index)
            let viewModel = RuneSlotViewModel(rune: rune)
            let runeSlotView = RuneSlotView(viewModel: viewModel, size: size)
            runeSlotViewModels.append(viewModel)
            let runeY = CGFloat(0.0)
            let runeX = frame.minX + frame.width/CGFloat(8) + (frame.width/4.0 * CGFloat(index))
            
            runeSlotView.position = CGPoint(x: runeX, y: runeY)
            runeSlotView.zPosition = 200
            runeSlotView.name = Constants.runeName
            addChild(runeSlotView)
            runeSlotViews.append(runeSlotView)
            
            viewModel.runeWasTapped.sink(receiveValue: { [weak self] (value) in
                guard let rune = value.0, let self = self else { return }
                self.runeWasTapped(rune: rune, progress: value.1)
                print(rune)
            }).store(in: &disposables)

        }
    }
}
