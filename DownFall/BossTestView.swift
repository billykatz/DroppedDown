//
//  BossTestView.swift
//  DownFall
//
//  Created by Billy on 12/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class BossTestView: ButtonDelegate {
    
    let foreground: SKNode
    let playableRect: CGRect
    
    let bossView: BossView
    let animator: Animator
    
    init(foreground: SKNode, playableRect: CGRect) {
        self.foreground = foreground
        self.playableRect = playableRect
        
        bossView = BossView(playableRect: playableRect, tileSize: 100, spriteProvider: { [] })
        bossView.position = bossView.position.translateVertically(-100)
        
        self.animator = Animator(foreground: foreground, bossSprite: bossView.bossSprite)
        let verticalPadding = 20.0
        
        foreground.addChild(bossView)
        let buttonZPosition: CGFloat = 10_000
        let buttonSize: CGSize = .buttonExtralarge
        let fontSize: CGFloat = .fontMediumSize
        
        let echoEffectButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .echoEffect, fontSize: fontSize)
        echoEffectButton.zPosition = buttonZPosition
        foreground.addChild(echoEffectButton)
        
        let walkEffectButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .walkEffect, fontSize: fontSize)
        walkEffectButton.position = CGPoint.alignHorizontally(walkEffectButton.frame, relativeTo: echoEffectButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding)
        walkEffectButton.zPosition = buttonZPosition
        foreground.addChild(walkEffectButton)
        
        let tiltHeadButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .tiltHead, fontSize: fontSize)
        tiltHeadButton.position = CGPoint.alignHorizontally(tiltHeadButton.frame, relativeTo: walkEffectButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        tiltHeadButton.zPosition = buttonZPosition
        foreground.addChild(tiltHeadButton)
        
        let toothChompButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .chompTeeth, fontSize: fontSize)
        toothChompButton.position = CGPoint.alignHorizontally(toothChompButton.frame, relativeTo: tiltHeadButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        toothChompButton.zPosition = buttonZPosition
        foreground.addChild(toothChompButton)
        
        let tootleBiteButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .lightBite, fontSize: fontSize)
        tootleBiteButton.position = CGPoint.alignHorizontally(tootleBiteButton.frame, relativeTo: toothChompButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        tootleBiteButton.zPosition = buttonZPosition
        foreground.addChild(tootleBiteButton)
    }
    
    func buttonTapped(_ button: ShiftShaft_Button) {
        switch button.identifier {
        case .echoEffect:
            animator.animateEchoEffect { }
        case .walkEffect:
            animator.animateLegMovement { }
        case .tiltHead:
            animator.animateTwistingHead { }
        case .chompTeeth:
            animator.animateToothChomp { }
        case .lightBite:
            animator.animateToothClose { }
        default:
            fatalError()
        }
    }
    
}
