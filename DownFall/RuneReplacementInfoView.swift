//
//  RuneReplacementInfoView.swift
//  DownFall
//
//  Created by Billy on 10/4/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import UIKit
import SpriteKit

class RuneInfoViewModel{
    
    let rune: Rune
    let playerHasRune: Bool
    let runeRemoved: () -> Void
    
    
    var backgroundColor: UIColor {
        return rune.progressColor.forUI
    }
    
    var runeImage: SKSpriteNode {
        return SKSpriteNode(texture: SKTexture(imageNamed: rune.textureName), size: CGSize(width: 125, height: 125))
    }
    
    var body: String {
        return rune.description
    }
    
    var chargeTitle: String {
        return playerHasRune ? "Current Charge" : "Full Charge"
    }
    
    var chargeAmount: String {
        return playerHasRune ? "\(rune.rechargeCurrent) / \(rune.cooldown)" : "\(rune.cooldown)"
    }
    
    var title: String {
        return playerHasRune ? "Your Rune" : "Found Rune"
    }
    
    var titleBackgroudWidth: CGFloat {
        return playerHasRune ? 250 : 275
    }
    
    var bodyFontSize: CGFloat {
        if body.count > 55 {
            return .fontSmallSize
        } else {
            return .fontMediumSize
        }
    }
    
    
    init(rune: Rune, playerHasRune: Bool, runeRemoved: @escaping () -> Void) {
        self.rune = rune
        self.playerHasRune = playerHasRune
        self.runeRemoved = runeRemoved
    }
}

class RuneInfoView: SKSpriteNode, ButtonDelegate {
    
    let containerView: SKSpriteNode
    let viewModel: RuneInfoViewModel

    
    init(rect: CGRect, viewModel: RuneInfoViewModel) {
        containerView = SKSpriteNode(color: .clear, size: rect.size)
        containerView.zPosition = 100_000_000
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: rect.size)
        
        addBackground(size: rect.size)
        addBorder(rect: rect)
        addFoundRuneTitle()
        addRuneInfoPanel()
        
        addChild(containerView)
        
        if viewModel.playerHasRune {
            addXButton(rect: rect)
        }
        
    }
    
    func addBackground(size: CGSize) {
        let background = SKSpriteNode(color: .buttonGray, size: size)
        background.zPosition = -100
        containerView.addChild(background)
    }
    
    func addBorder(rect: CGRect) {
        let rect = CGRect(origin: CGPoint(x: -rect.width/2, y: -rect.height/2), size: rect.size)
        let border = SKShapeNode(rect: rect, cornerRadius: 16.0)
        border.lineWidth = 16.0
        border.strokeColor = .runeInfoBorder
        border.fillColor = .clear
        containerView.addChild(border)
    }
    
    func addFoundRuneTitle() {
        let titleBackground = SKShapeNode(rect: CGRect(origin: .zero, size: CGSize(width: viewModel.titleBackgroudWidth, height: 65)), cornerRadius: 12.0)
        let titleTitle = ParagraphNode(text: viewModel.title, paragraphWidth: 500, fontSize: 64)
        titleBackground.color = .runeInfoBorder
        
        titleBackground.position = CGPoint.position(titleBackground.frame, inside: containerView.frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: -titleBackground.frame.width/2, yOffset: titleBackground.frame.height/2)
        
        titleTitle.position = CGPoint.position(titleTitle.frame, inside: titleBackground.frame, verticalAlign: .center, horizontalAnchor: .left, xOffset: 45, translatedToBounds: true)
        
        containerView.addChild(titleTitle)
        containerView.addChild(titleBackground)
        
    }
    
    func addRuneInfoPanel() {
        let runeImage = viewModel.runeImage
        let runeBody = ParagraphNode(text: viewModel.body, paragraphWidth: 450, fontSize: viewModel.bodyFontSize, fontColor: .black)
        
        let backgroundRuneColor = SKShapeNode(rectOf: CGSize(width: 135, height: 135), cornerRadius: 25.0)
        backgroundRuneColor.zPosition = -1
        backgroundRuneColor.color = viewModel.backgroundColor
        
        runeImage.position = CGPoint.position(runeImage.frame, inside: containerView.frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: 50, yOffset: 100)
        
        backgroundRuneColor.position = CGPoint.position(backgroundRuneColor.frame, inside: runeImage.frame, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: -6.5, yOffset: -5, translatedToBounds: true)
        
        runeBody.position = CGPoint.alignVertically(runeBody.frame, relativeTo: runeImage.frame, horizontalAnchor: .right, verticalAlign: .top, verticalPadding: -5.0, horizontalPadding: Style.Padding.more * 2, translatedToBounds: true)
        
        containerView.addChild(backgroundRuneColor)
        containerView.addChild(runeImage)
        containerView.addChild(runeBody)
        
        let runeEnergizeTitle = ParagraphNode(text: "Energize", paragraphWidth: 300, fontSize: 48.0, fontColor: .black)
        let runeEnergizeColor = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 2.5)
        
        runeEnergizeTitle.position = CGPoint.alignVertically(runeEnergizeTitle.frame, relativeTo: runeImage.frame, horizontalAnchor: .right, verticalAlign: .bottom, horizontalPadding: Style.Padding.more * 2, translatedToBounds: true)
        runeEnergizeColor.position = CGPoint.alignHorizontally(runeEnergizeColor.frame, relativeTo: runeEnergizeTitle.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        runeEnergizeColor.color = viewModel.backgroundColor
        
        containerView.addChild(runeEnergizeTitle)
        containerView.addChild(runeEnergizeColor)
        
        let chargeTitle = ParagraphNode(text: viewModel.chargeTitle, paragraphWidth: 300, fontSize: 48.0, fontColor: .black)
        chargeTitle.position = CGPoint.alignVertically(chargeTitle.frame, relativeTo: runeEnergizeTitle.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most*2, translatedToBounds: true)
        
        let chargeText = ParagraphNode(text: viewModel.chargeAmount, paragraphWidth: 300, fontSize: 48.0, fontColor: .black)
        chargeText.position = CGPoint.alignHorizontally(chargeText.frame, relativeTo: chargeTitle.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        
        containerView.addChild(chargeTitle)
        containerView.addChild(chargeText)
    }
    
    func addXButton(rect: CGRect) {
        let xButtonImage = SKSpriteNode(texture: SKTexture(imageNamed: "clear-x-button"), size: CGSize(width: 35, height: 35))
        let xButton = ShiftShaft_Button(size: CGSize(width: 50, height: 50), delegate: self, identifier: .runeReplacementCancel, image: xButtonImage, shape: .rectangle, aspectFillToSize: false)
        
        let xButtonBackground = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 12)
        xButtonBackground.color = .runeInfoBorder
        
        xButtonBackground.position = CGPoint.position(xButtonBackground.frame, inside: rect, verticalAlign: .top, horizontalAnchor: .right)
        xButton.position = CGPoint.position(xButton.frame, inside: xButtonBackground.frame, verticalAlign: .center, horizontalAnchor: .center, translatedToBounds: true)
        
        containerView.addChild(xButton)
        containerView.addChild(xButtonBackground)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonTapped(_ button: ShiftShaft_Button) {
        print(button.identifier)
        if button.identifier == .runeReplacementCancel {
            viewModel.runeRemoved()
            self.removeFromParent()
        }
    }
    
}
