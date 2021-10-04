//
//  RuneReplacementEmptyPanelView.swift
//  DownFall
//
//  Created by Billy on 10/4/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import UIKit
import SpriteKit

class RuneReplacementEmptyPanelView: SKSpriteNode, ButtonDelegate {
    
    let containerView: SKSpriteNode
    let foundRune: Rune
    
    init(rect: CGRect, foundRune: Rune) {
        containerView = SKSpriteNode(color: .clear, size: rect.size)
        containerView.zPosition = 100
        self.foundRune = foundRune
        super.init(texture: nil, color: .clear, size: rect.size)
        
        addChild(containerView)
        
        addBackground(rect: rect)
        addDiscardButton()
        addOrSwapText()
        
    }
    
    func addBackground(rect: CGRect) {
        let background = SKShapeNode(rectOf: size, cornerRadius: 16)
        background.color = .runeReplacementEmptyPanelBackground
        background.zPosition = -100
        containerView.addChild(background)

    }
    
    func addDiscardButton() {
        let button = ShiftShaft_Button(size: CGSize(width: 380, height: 80), delegate: self, identifier: .discardFoundRune, precedence: Precedence.floating, fontSize: 60, fontColor: .black, backgroundColor: .buttonGray)
        button.position = CGPoint.position(button.frame, inside: containerView.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: 45)
        
        containerView.addChild(button)
        
    }
    
    func addOrSwapText() {
        let orText = ParagraphNode(text: "or", paragraphWidth: 500, fontSize: 60.0, fontColor: .white)
        orText.position = CGPoint.position(orText.frame, inside: containerView.frame, verticalAlign: .center, horizontalAnchor: .center, yOffset: -5)
        
        let selectText = ParagraphNode(text: "Select a Rune to swap", paragraphWidth: 1000, fontSize: 60.0, fontColor: .white)
        selectText.position = CGPoint.alignHorizontally(selectText.frame, relativeTo: orText.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: 15)
        
        containerView.addChild(orText)
        containerView.addChild(selectText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonTapped(_ button: ShiftShaft_Button) {
        print(button.identifier)
        InputQueue.append(Input(.foundRuneDiscarded(foundRune)))
    }


}
