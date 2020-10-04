//
//  RuneSlot.swift
//  DownFall
//
//  Created by Katz, Billy on 4/21/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

class RuneSlotView: SKSpriteNode {
    
    struct Constants {
        static let backgroundScale = CGFloat(0.9)
        static let runeScale = CGFloat(0.8)
        static let outlineSize = CGSize.oneFifty
        static let progressName = "progressName"
        static let outlineName = "outlineName"
    }
    
    let viewModel: RuneSlotViewModel
    
    init(viewModel: RuneSlotViewModel, size: CGSize) {
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        
        isUserInteractionEnabled = true
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func displayProgress(progress: Int, cooldown: Int) {
        removeChild(with: Constants.progressName)
        addChildSafely(self.progress)
        
        removeChild(with: Constants.outlineName)
        addChildSafely(outline)
    }
    
    private var outline: SKShapeNode {
        let goldOutline = SKShapeNode(rectOf: self.size)
        goldOutline.color = viewModel.isCharged ? .goldOutlineBright : .goldOutlineDull
        goldOutline.zPosition = Precedence.background.rawValue
        goldOutline.name = Constants.outlineName
        
        return goldOutline
    }
    
    private var background: SKShapeNode {
        let background = SKShapeNode(rectOf: outline.frame.size.scale(by: Constants.backgroundScale))
        background.color = .runeBackgroundColor
        background.zPosition = 1
        
        return background
    }
    
    private var progress: SKShapeNode? {
        guard let cooldown = viewModel.rune?.cooldown, cooldown > 0 else { return nil }
        let progressRatio = CGFloat(viewModel.current) / CGFloat(cooldown)
        let size = outline.frame.size.scale(by: Constants.backgroundScale)
        let height = size.height * progressRatio
        let width = size.width
        let progress = SKShapeNode(rectOf: CGSize(width: width, height: height))
        
        // default to eggshellWhite if the rune does not have a color, although that would be a bug
        progress.position = CGPoint.position(progress.frame, inside: background.frame, verticalAlign: .bottom, horizontalAnchor: .center)
        progress.color = viewModel.progressColor ?? .eggshellWhite
        progress.zPosition = Precedence.foreground.rawValue
        progress.name = Constants.progressName
        
        return progress
    }
    
    private var runeSprite: SKSpriteNode? {
        guard let textureName = viewModel.textureName else { return nil }
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: textureName), size: outline.frame.size.scale(by: Constants.runeScale))
        sprite.zPosition = Precedence.menu.rawValue
        
        return sprite
    }
    
    func setupView() {

        /// add the rune image view
        addChildSafely(outline)
        addChildSafely(background)
        addChildSafely(runeSprite)
        addChildSafely(progress)
        
        /// show progress
        displayProgress(progress: viewModel.current, cooldown: viewModel.rune?.cooldown ?? 0)
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let translatedPosition = CGPoint(x: frame.center.x + position.x, y: frame.center.y + position.y)
        if self.contains(translatedPosition) {
            viewModel.wasTapped()
        }
    }
}
