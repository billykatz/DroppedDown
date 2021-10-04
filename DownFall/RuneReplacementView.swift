//
//  RuneReplacementView.swift
//  DownFall
//
//  Created by Katz, Billy on 11/14/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Combine
import CoreGraphics
import SpriteKit

struct RuneReplacementViewModel {
    let foundRune: Rune
    let pickaxe: Pickaxe
    var runeToSwap: Rune?
}

class RuneReplacementView: SKSpriteNode, ButtonDelegate {
    
    private var viewModel: RuneReplacementViewModel
    private let playableRect: CGRect
    
    /// rune container view
    private var runeInventoryContainer: SKSpriteNode?
    
    private let emptyPanelView: SKSpriteNode
    private var swapRunesButton: ShiftShaft_Button?
    
    init(size: CGSize, playableRect: CGRect, viewModel: RuneReplacementViewModel) {
        self.playableRect = playableRect
        self.viewModel = viewModel
        emptyPanelView = RuneReplacementEmptyPanelView(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 680, height: 320)), foundRune: viewModel.foundRune)
        
        super.init(texture: nil, color: .clear, size: size)
        /// add the pickaxe container view
        addRuneContainerView()
        
        
        let runeInfoView = RuneInfoView(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 680, height: 320)), viewModel: RuneInfoViewModel(rune: viewModel.foundRune, playerHasRune: false, runeRemoved: {}))
        runeInfoView.zPosition = 1000
        
        let totalHeight: CGFloat = 1150
        
        let xPadding = (playableRect.width - 780) / 2
        let yPadding = (playableRect.height - totalHeight) / 2
        let runeReplacementContainer = SKShapeNode(rect: CGRect(origin: CGPoint(x: playableRect.minX + xPadding, y: playableRect.minY+yPadding), size: CGSize(width: 780, height: totalHeight)), cornerRadius: 24)
        runeReplacementContainer.fillColor = .runeReplacementBackgroundFillBlue
        runeReplacementContainer.strokeColor = .runeReplacementBackgroundStrokeBlue
        runeReplacementContainer.lineWidth = 18.0
        runeReplacementContainer.zPosition = -1
        
        
        runeInfoView.position = CGPoint.position(runeInfoView.frame, inside: runeReplacementContainer.frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: 50, yOffset: 260)
        emptyPanelView.position = CGPoint.alignHorizontally(emptyPanelView.frame, relativeTo: runeInfoView.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: 60.0, translatedToBounds: true)
        
        addChild(emptyPanelView)
        addChild(runeInfoView)
        addChild(runeReplacementContainer)

        let title = ParagraphNode(text: "Rune Slots Full", fontSize: 78, fontColor: .white)
        let subtitle = ParagraphNode(text: "Discard the found Rune or swap it", fontSize: 64, fontColor: .white)
        
        title.position = CGPoint.position(title.frame, inside: runeReplacementContainer.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: 48, translatedToBounds: true)
        subtitle.position = CGPoint.alignHorizontally(subtitle.frame, relativeTo: title.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: 20, translatedToBounds: true)
        title.zPosition = 1000
        subtitle.zPosition = 1000
        
        addChild(title)
        addChild(subtitle)
        
        
        let swapRunesButton = ShiftShaft_Button(size: CGSize(width: 300, height: 100), delegate: self, identifier: .swapRunes, precedence: .floating, fontSize: 65, fontColor: .black, backgroundColor: .buttonGray)
        swapRunesButton.position = CGPoint.position(swapRunesButton.frame, inside: runeReplacementContainer.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: 65, translatedToBounds: true)
        swapRunesButton.name = "swapRunesButton"
        self.swapRunesButton = swapRunesButton
        
        
        let backgroundOverlay = SKSpriteNode(color: .black, size: playableRect.size)
        backgroundOverlay.alpha = 0.5
        backgroundOverlay.zPosition = -10
        addChild(backgroundOverlay)
        
    }
    
    private func addRuneContainerView() {
        /// Routes Rune container outputs to TargetingViewModel input
        let runeContainverViewModel = RuneContainerViewModel(runes: viewModel.pickaxe.runes,
                                                             numberOfRuneSlots: viewModel.pickaxe.runeSlots,
                                               runeWasTapped: runeWasTapped,
                                               runeWasUsed: { _ in },
                                               runeUseWasCanceled: {  },
                                               disableDetailView: true)
        
        /// create the rune container view
        let runeContainer = RuneContainerView(viewModel: runeContainverViewModel,
                                              mode: .inventory,
                                              size: CGSize(width: playableRect.width,
                                                           height: Style.Backpack.runeInventorySize))
        
        /// name it so we can remove it later
        runeContainer.name = "runeContainer"
        
        runeContainer.position = CGPoint.position(runeContainer.frame, inside: playableRect, verticalAnchor: .bottom, horizontalAnchor: .center, padding: Style.Padding.most*3)
        
        /// position it high up to catch user interaction
        runeContainer.zPosition = 10_000
        
        /// remove the old rune container
        self.removeChild(with: "runeContainer")
        
        /// update our variable
        runeInventoryContainer = runeContainer
        
        /// finally add it to the screen
        addChildSafely(runeContainer)
    }
    
    private func runeWasTapped(_ rune: Rune) {
        removeChild(with: "myRuneInfoView")
        removeChild(with: "swapRunesButton")
        
        let runeInfoView = RuneInfoView(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 680, height: 320)), viewModel: RuneInfoViewModel(rune: rune, playerHasRune: true, runeRemoved: { [weak self] in
            self?.removeChild(with: "swapRunesButton")
        }))
        runeInfoView.position = emptyPanelView.position
        runeInfoView.name = "myRuneInfoView"
        
        viewModel.runeToSwap = rune
        
        runeInfoView.zPosition = 10000
        
        addChild(swapRunesButton!)
        addChild(runeInfoView)
    }
    
    func buttonTapped(_ button: ShiftShaft_Button) {
        if button.identifier == .swapRunes {
            InputQueue.append(Input(.runeReplaced(viewModel.pickaxe, viewModel.runeToSwap!)))
            self.removeFromParent()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
