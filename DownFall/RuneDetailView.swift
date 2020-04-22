//
//  RuneDetailView.swift
//  DownFall
//
//  Created by Katz, Billy on 4/21/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit
import SpriteKit

class RuneDetailViewModel {
    
    // delegation
    var cancel: (() -> ())? = nil
    
    var isCharged: Bool { return progress >= rune.cooldown }
    var textureName: String { return rune.textureName }
    var progressRatio: CGFloat { return CGFloat(progress) / CGFloat(rune.cooldown) }
    let rune: AnyAbility
    let progress: Int
    let progressColor: UIColor = .lightBarRed
    
    init(rune: AnyAbility, progress: Int) {
        self.rune = rune
        self.progress = progress
    }
}

class RuneDetailView: SKSpriteNode {
    
    struct Constants {
        static let backgroundScale = CGFloat(0.9)
        static let detailScale = CGFloat(0.5)
        static let runeScale = CGFloat(0.8)
        static let outlineSize = CGSize.oneFifty
    }
    
    let viewModel: RuneDetailViewModel
    
    init(viewModel: RuneDetailViewModel, size: CGSize) {
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var outline: SKShapeNode {
        let goldOutline = SKShapeNode(rectOf: Constants.outlineSize)
        goldOutline.color = viewModel.isCharged ? .goldOutlineBright : .goldOutlineDull
        goldOutline.zPosition = Precedence.background.rawValue
        
        return goldOutline
    }
    
    private var background: SKShapeNode {
        let background = SKShapeNode(rectOf: outline.frame.size.scale(by: Constants.backgroundScale))
        background.color = .runeBackgroundColor
        background.zPosition = 1
        
        return background
    }
    
    private var progress: SKShapeNode {
        let height = outline.frame.size.height * viewModel.progressRatio
        let size = CGSize(width: outline.frame.size.width, height: height)
        let progress = SKShapeNode(rectOf: size)
        progress.color = viewModel.progressColor
        progress.zPosition = Precedence.foreground.rawValue
        
        return progress
    }
    
    private var runeSprite: SKSpriteNode {
        let textureName = viewModel.textureName
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: textureName), size: outline.frame.size.scale(by: Constants.runeScale))
        sprite.zPosition = Precedence.menu.rawValue
        
        return sprite
    }
    
    
    private var detailContainer: SKSpriteNode {
        let detailArea = SKSpriteNode(texture: nil, color: UIColor.runeDetailColor, size: self.size.scale(by: Constants.detailScale))
        return detailArea
    }
    
    private lazy var cancelButton: Button = {
        let cancel = Button(size: CGSize.oneHundred, delegate: self, identifier: ButtonIdentifier.backpackCancel, precedence: .foreground)
        
        return cancel
    }()
    
    
    func setupView() {
        outline.position = CGPoint.position(runeSprite.frame, inside: self.frame, verticalAlign: .center, horizontalAnchor: .left)
        background.position = outline.position
        runeSprite.position = outline.position
        progress.position = CGPoint.position(progress.frame, inside: outline.frame, verticalAlign: .bottom, horizontalAnchor: .center)

        /// add the rune image view
        addChild(outline)
        addChild(background)
        addChild(runeSprite)
        addChild(progress)
        
        
        /// Add the detail container
        detailContainer.position = .zero
        addChild(detailContainer)
        
        //add button
        cancelButton.position = CGPoint.position(cancelButton.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .right)
        addChild(cancelButton)
        
    }
    
    
}

extension RuneDetailView: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        viewModel.cancel?()
    }
}
