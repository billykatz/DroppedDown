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
        bossView.position = bossView.position.translateVertically(200)
        
        self.animator = Animator(foreground: foreground, bossSprite: bossView.bossSprite)
        
        foreground.addChild(bossView)
        
        let echoEffectButton = ShiftShaft_Button(size: CGSize.buttonMedium, delegate: self, identifier: .echoEffect, fontSize: .fontSmallSize)
        foreground.addChild(echoEffectButton)
        
        let walkEffectButton = ShiftShaft_Button(size: CGSize.buttonMedium, delegate: self, identifier: .walkEffect, fontSize: .fontSmallSize)
        walkEffectButton.position = CGPoint.alignHorizontally(walkEffectButton.frame, relativeTo: echoEffectButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: 10.0)
        foreground.addChild(walkEffectButton)
    }
    
    func buttonTapped(_ button: ShiftShaft_Button) {
        switch button.identifier {
        case .echoEffect:
            animator.animateEchoEffect { }
        case .walkEffect:
            animator.animateLegMovement { }
        default:
            fatalError()
        }
    }
    
}
