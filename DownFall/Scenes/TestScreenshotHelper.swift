//
//  ScreenshotHelper.swift
//  DownFall
//
//  Created by Billy on 3/10/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import CoreGraphics
import Foundation
import SpriteKit

class ScreenshotHelper {
    
    var rotatePreview: RotatePreviewView?
    var foreground: SKNode
    var playableRect: CGRect
    
    init(rotatePreview: RotatePreviewView?, foreground: SKNode, playableRect: CGRect) {
        self.rotatePreview = rotatePreview
        self.foreground = foreground
        self.playableRect = playableRect
        
        Dispatch.shared.register { [weak self] input in
            self?.handleInput(input)
        }
    }
    
    func handleInput(_ input: Input) {
        
        if case InputType.boardBuilt = input.type {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                InputQueue.append(.init(.rotateClockwise(preview: true)))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self, rotatePreview] in
                let distance: CGFloat = -250
                rotatePreview?.touchesMoved(distance: distance)
                self?.showFingerSwiping()
                
            }
        }
        
    }
    
    func showFingerSwiping() {
        let fingerSize = CGSize(widthHeight: 150.0)
        let fingerSwiping = SKSpriteNode(texture: SKTexture(imageNamed: "finger-swiping"), size: fingerSize)
        let fingerSwiping2 = SKSpriteNode(texture: SKTexture(imageNamed: "finger-swiping"), size: fingerSize)
        let fingerSwiping3 = SKSpriteNode(texture: SKTexture(imageNamed: "finger-swiping"), size: fingerSize)
        let fingerSwiping4 = SKSpriteNode(texture: SKTexture(imageNamed: "finger-swiping"), size: fingerSize)
        fingerSwiping.alpha = 1.0
        fingerSwiping2.alpha = 0.8
        fingerSwiping3.alpha = 0.6
        fingerSwiping4.alpha = 0.4
        
        let yOffset: CGFloat = 370
        let fingerPosition = CGPoint.position(fingerSwiping.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: 150, yOffset: yOffset)
        let fingerPosition2 = CGPoint.position(fingerSwiping2.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: 275, yOffset: yOffset)
        let fingerPosition3 = CGPoint.position(fingerSwiping3.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: 400, yOffset: yOffset)
        let fingerPosition4 = CGPoint.position(fingerSwiping4.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: 525, yOffset: yOffset)
        
        fingerSwiping.xScale = -1
        fingerSwiping2.xScale = -1
        fingerSwiping3.xScale = -1
        fingerSwiping4.xScale = -1
        
        fingerSwiping.position = fingerPosition
        fingerSwiping.zPosition = 10_000_000
        
        fingerSwiping2.position = fingerPosition2
        fingerSwiping2.zPosition = 9_000_000
        
        fingerSwiping3.position = fingerPosition3
        fingerSwiping3.zPosition = 8_000_000
        
        fingerSwiping4.position = fingerPosition4
        fingerSwiping4.zPosition = 7_000_000
        
        
        foreground.addChild(fingerSwiping)
        foreground.addChild(fingerSwiping2)
        foreground.addChild(fingerSwiping3)
        foreground.addChild(fingerSwiping4)
    }
}
