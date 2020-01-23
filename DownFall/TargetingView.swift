//
//  TargetingView.swift
//  DownFall
//
//  Created by Katz, Billy on 1/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit


class TargetingView: SKSpriteNode {
    
    private var viewModel: TargetingViewModel?
    private var tileSize: CGFloat?
    private var foreground: SKNode?
    private var targetingForeground: SKNode?
    private var toastMessageContainer: SKShapeNode?
    private var playableRect: CGRect?
    
    func update(with vm: TargetingViewModel?, levelSize: Int, playableRect: CGRect, foregound: SKNode) {
        self.viewModel = vm
        
        self.playableRect = playableRect
        self.tileSize = 0.9 * (playableRect.width / CGFloat(levelSize))
        
        self.isUserInteractionEnabled = true
        
        viewModel?.updateCallback = self.update
        
        self.targetingForeground = SKNode()
        self.targetingForeground?.isUserInteractionEnabled = true
        self.targetingForeground?.position = foreground?.position ?? .zero
        foregound.addOptionalChild(targetingForeground)
    }
    
    
    
    func update() {
        
        
        //dispaly the targeted coords with the correct reticles
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let translatedPosition = CGPoint(x: self.frame.center.x + position.x, y: self.frame.center.y + position.y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.wasTouched(touches, with: event) {
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
}
