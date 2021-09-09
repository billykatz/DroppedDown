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

protocol RuneReplacementViewModelInputs {
    
}

protocol RuneReplacementViewModelOutputs {
    
}

struct RuneReplacementViewModel {
    let newRune: Rune
    let pickaxe: Pickaxe
    var runeToSwap: Rune?
}


class RuneReplacementView: SKSpriteNode, ButtonDelegate {
    func buttonTapped(_ button: ShiftShaft_Button) {
        switch button.identifier {
        case .swapRunes:
            InputQueue.append(Input(.runeReplaced(viewModel.pickaxe, viewModel.runeToSwap!)))
            self.removeFromParent()
        case .discardFoundRune:
            viewModel.runeToSwap = nil
            InputQueue.append(Input(.foundRuneDiscarded(viewModel.newRune)))
            self.removeFromParent()
        default:
            // ignore
            ()
        }
    }
    
    private var viewModel: RuneReplacementViewModel
    private let playableRect: CGRect
    
    /// rune container view
    private var runeInventoryContainer: SKSpriteNode?
    
    /// replacement menu view
    private var replacementMenuView: SKSpriteNode?
    
    init(size: CGSize, playableRect: CGRect, viewModel: RuneReplacementViewModel) {
        self.playableRect = playableRect
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        
        /// add the rune container view
        addRuneContainerView()
        
        /// create and add the menu
        createAndAddReplacementMenuView()
    }
    
    private let backgroundWidth = CGFloat(800.0)
    private var swapButton: ShiftShaft_Button?
    
    /// save these values to set up the swap rune view
    var secondVerticalLine: SKSpriteNode?
    var chargedLabelYPosition: CGFloat?
    var currentChargeLabelYPosition: CGFloat?
    var targetChargeLabelYPosition: CGFloat?
    var effectLabelYPosition: CGFloat?
    var runeSpriteYPosition: CGFloat?
    var foundRuneYPosition: CGFloat?
    
    private func createAndAddReplacementMenuView() {
        
        /// create and add background
        let background = SKSpriteNode(color: .foregroundBlue, size: CGSize(width: backgroundWidth, height: 1200.0))
        background.zPosition = Precedence.background.rawValue
        
        addChild(background)
        
        /// create and add border
        let border = SKShapeNode(rect: background.frame)
        border.fillColor = .clear
        border.strokeColor = .eggshellWhite
        border.lineWidth = 2.0
        border.zPosition = Precedence.foreground.rawValue
        
        addChild(border)
        
        /// create and add title
        let title = ParagraphNode(text: "Rune Slots Full", paragraphWidth: background.frame.width - 2 * Style.Padding.normal)
        
        title.position = .position(title.frame, inside: background.frame, verticalAlign: .top, horizontalAnchor: .center)
        title.zPosition = Precedence.foreground.rawValue
        addChild(title)
        
        /// create and add the description
        let description = ParagraphNode(text: "Discard the found Rune or swap it.", paragraphWidth: background.frame.width - 2 * Style.Padding.normal, fontSize: .fontMediumSize)
        
        description.position = .position(description.frame, inside: background.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: title.frame.height)
        description.zPosition = Precedence.foreground.rawValue
        addChild(description)
        
        /// add some buttons
        let discardButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .discardFoundRune)
        discardButton.position = CGPoint.position(discardButton.frame, inside: background.frame, verticalAlign: .bottom, horizontalAnchor: .left)
        
        let swapButton = ShiftShaft_Button(size: .buttonExtralarge, delegate: self, identifier: .swapRunes, disable: true)
        swapButton.position = CGPoint.position(swapButton.frame, inside: background.frame, verticalAlign: .bottom, horizontalAnchor: .right)
        self.swapButton = swapButton
        
        addChild(discardButton)
        addChild(swapButton)
        
        /// add the rune effect/charge labels
        let fontSize = CGFloat(65.0)
        let chargedLabel = ParagraphNode(text: "Energize", paragraphWidth: background.frame.width, fontSize: fontSize)
        let currentChargeLabel = ParagraphNode(text: "Current Charge", paragraphWidth: background.frame.width, fontSize: fontSize)
        let targetChargeLabel = ParagraphNode(text: "Full Charge", paragraphWidth: background.frame.width, fontSize: fontSize)
        let effectLabel = ParagraphNode(text: "Effect", paragraphWidth: background.frame.width, fontSize: fontSize)
        
        chargedLabel.position = CGPoint.position(chargedLabel.frame, inside: background.frame, verticalAlign: .center, horizontalAnchor: .left, xOffset: 25.0, yOffset: 100.0, translatedToBounds: true)
        
        currentChargeLabel.position = CGPoint.alignHorizontally(currentChargeLabel.frame, relativeTo: chargedLabel.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        
        targetChargeLabel.position = CGPoint.alignHorizontally(targetChargeLabel.frame, relativeTo: currentChargeLabel.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        
        effectLabel.position = CGPoint.alignHorizontally(effectLabel.frame, relativeTo: targetChargeLabel.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        
        addChild(chargedLabel)
        addChild(currentChargeLabel)
        addChild(targetChargeLabel)
        addChild(effectLabel)
        
        /// add a vertical line
        let verticalLine = SKSpriteNode(color: .eggshellWhite, size: CGSize(width: 1.0, height: background.size.height * 0.75))
        verticalLine.position = CGPoint.position(verticalLine.frame, inside: currentChargeLabel.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: -1.0, translatedToBounds: true)
        
        addChild(verticalLine)
        
        /// add the found rune and label
        let foundRuneSprite = SKSpriteNode(texture: SKTexture(imageNamed: viewModel.newRune.textureName), size: .oneFifty)
        
        foundRuneSprite.position = CGPoint.alignHorizontally(foundRuneSprite.frame, relativeTo: description.frame, horizontalAnchor: .right, verticalAlign: .bottom, verticalPadding: Style.Padding.normal, translatedToBounds: true)
        foundRuneSprite.position.x = verticalLine.position.x + background.frame.width/3/2
        addChild(foundRuneSprite)
        
        /// add exclamation to found rune cuz exciting!
        let exclamationSprite = SKSpriteNode(texture: SKTexture(imageNamed: "exclamation"), size: .oneHundred)
        exclamationSprite.position = CGPoint.position(exclamationSprite.frame, inside: foundRuneSprite.frame, verticalAlign: .bottom, horizontalAnchor: .right, xOffset: -Style.Padding.more, yOffset: -Style.Padding.normal, translatedToBounds: true)
        exclamationSprite.zPosition = Precedence.menu.rawValue
        addChild(exclamationSprite)
        
        
        /// add the effect .labels for the found rune
        let foundRuneCharge = SKSpriteNode(texture: SKTexture(imageNamed: viewModel.newRune.rechargeType.first!.textureString()), size: .fifty)
        foundRuneCharge.position = CGPoint.alignVertically(foundRuneCharge.frame, relativeTo: chargedLabel.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        foundRuneCharge.position.x = verticalLine.position.x + background.frame.width/3/2
        
        let foundRuneChargedLabel = ParagraphNode(text: "\(viewModel.newRune.rechargeCurrent)", paragraphWidth: background.frame.width, fontSize: .fontLargeSize)
        foundRuneChargedLabel.position = CGPoint.alignVertically(foundRuneChargedLabel.frame, relativeTo: currentChargeLabel.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        foundRuneChargedLabel.position.x = verticalLine.position.x + background.frame.width/3/2
        
        let foundRuneFullCharge = ParagraphNode(text: "\(viewModel.newRune.cooldown)", paragraphWidth: background.frame.width, fontSize: .fontLargeSize)
        foundRuneFullCharge.position = CGPoint.alignVertically(foundRuneFullCharge.frame, relativeTo: targetChargeLabel.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        foundRuneFullCharge.position.x = verticalLine.position.x + background.frame.width/3/2
        
        let foundRuneEffect = ParagraphNode(text: "\(viewModel.newRune.description)", paragraphWidth: background.frame.width/3, fontSize: .fontMediumSize)
        foundRuneEffect.position.y = effectLabel.position.y - foundRuneEffect.frame.height/2
        foundRuneEffect.position.x = verticalLine.position.x + Style.Padding.most + foundRuneEffect.frame.width/2
        
        
        addChild(foundRuneCharge)
        addChild(foundRuneChargedLabel)
        addChild(foundRuneFullCharge)
        addChild(foundRuneEffect)
        
        /// add a vertical line
        let secondVerticalLine = SKSpriteNode(color: .eggshellWhite, size: CGSize(width: 1.0, height: background.size.height * 0.75))
        secondVerticalLine.position = CGPoint.position(secondVerticalLine.frame, inside: verticalLine.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: -background.frame.width/3, translatedToBounds: true)
        
        addChild(secondVerticalLine)
        
        /// save these for later use
        self.secondVerticalLine = secondVerticalLine
        self.chargedLabelYPosition = chargedLabel.position.y
        self.currentChargeLabelYPosition = currentChargeLabel.position.y
        self.targetChargeLabelYPosition = targetChargeLabel.position.y
        self.effectLabelYPosition = effectLabel.position.y
        self.foundRuneYPosition = foundRuneSprite.position.y
        
        //question-mark
        
        let questionMarkSprite = SKSpriteNode(texture: SKTexture(imageNamed: "question-mark"), size: .oneHundred)
        questionMarkSprite.position.x = secondVerticalLine.position.x + backgroundWidth/3/2
        questionMarkSprite.position.y = foundRuneSprite.position.y
        questionMarkSprite.zPosition = Precedence.background.rawValue
        
        addChild(questionMarkSprite)
        
        let helperText = ParagraphNode(text: "Select a Rune from your Pickaxe Handle (bottom of screen)", paragraphWidth: backgroundWidth/3, fontSize: .fontLargeSize)
        helperText.name = "helperText"
        helperText.position = CGPoint.alignHorizontally(helperText.frame, relativeTo: questionMarkSprite.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        
        addChild(helperText)
    }
    
    func addSwapRuneData(_ rune: Rune) {
        guard
            let secondVerticalLine = secondVerticalLine,
            let chargedLabelYPosition = chargedLabelYPosition,
            let currentChargeLabelYPosition = currentChargeLabelYPosition,
            let targetChargeLabelYPosition = targetChargeLabelYPosition,
            let effectLabelYPosition = effectLabelYPosition,
            let foundRuneYPosition = foundRuneYPosition
        else { return }
        
        let swapRuneSprite = SKSpriteNode(texture: SKTexture(imageNamed: rune.textureName), size: .oneFifty)
        swapRuneSprite.position.x = secondVerticalLine.position.x + backgroundWidth/3/2
        swapRuneSprite.position.y = foundRuneYPosition
        swapRuneSprite.zPosition = Precedence.menu.rawValue
        
        let swapRuneChargeSprite = SKSpriteNode(texture: SKTexture(imageNamed: rune.rechargeType.first!.textureString()), size: .fifty)
        swapRuneChargeSprite.position.x = secondVerticalLine.position.x + backgroundWidth/3/2
        swapRuneChargeSprite.position.y = chargedLabelYPosition
        
        let swapRuneChargedLabel = ParagraphNode(text: "\(rune.rechargeCurrent)", paragraphWidth: backgroundWidth, fontSize: .fontLargeSize)
        swapRuneChargedLabel.position.x = secondVerticalLine.position.x + backgroundWidth/3/2
        swapRuneChargedLabel.position.y = currentChargeLabelYPosition
        
        let swapRuneFullCharge = ParagraphNode(text: "\(rune.cooldown)", paragraphWidth: backgroundWidth, fontSize: .fontLargeSize)
        swapRuneFullCharge.position.x = secondVerticalLine.position.x + backgroundWidth/3/2
        swapRuneFullCharge.position.y = targetChargeLabelYPosition
        
        let swapRuneEffect = ParagraphNode(text: "\(rune.description)", paragraphWidth: backgroundWidth/3, fontSize: .fontMediumSize)
        swapRuneEffect.position.x = secondVerticalLine.position.x + Style.Padding.most + swapRuneEffect.frame.width/2
        swapRuneEffect.position.y = effectLabelYPosition - swapRuneEffect.frame.height/2

        swapRuneSprite.name = "swapRuneSprite"
        swapRuneChargeSprite.name = "swapRuneChargeSprite"
        swapRuneChargedLabel.name = "swapRuneChargedLabel"
        swapRuneFullCharge.name = "swapRuneFullCharge"
        swapRuneEffect.name = "swapRuneEffect"
        
        removeChild(with: "helperText")
        removeChild(with: "swapRuneSprite")
        removeChild(with: "swapRuneChargeSprite")
        removeChild(with: "swapRuneChargedLabel")
        removeChild(with: "swapRuneFullCharge")
        removeChild(with: "swapRuneEffect")
        
        addChild(swapRuneSprite)
        addChild(swapRuneChargeSprite)
        addChild(swapRuneChargedLabel)
        addChild(swapRuneFullCharge)
        addChild(swapRuneEffect)
        
        viewModel.runeToSwap = rune
        
        // enable the swap button
        swapButton?.enable(true)
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
        addSwapRuneData(rune)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
