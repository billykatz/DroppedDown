//
//  RuneViewModel.swift
//  DownFall
//
//  Created by Katz, Billy on 4/19/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

class RuneSlotViewModel {
    var rune: AnyAbility?
    
    init(rune: AnyAbility?) {
        self.rune = rune
        
        Dispatch.shared.register { [weak self] (input) in
            self?.handle(input: input)
        }
    }
    
    private func handle(input: Input) {
        switch input.type {
        case .transformation(let trans):
            trackRuneProgress(with: trans)
            return
        default:
            return
        }
    }
    
    private func trackRuneProgress(with trans: [Transformation]) {
        if let inputType = trans.first?.inputType {
            switch inputType {
            case InputType.touch(_, let type):
                if let count = trans.first?.tileTransformation?.first?.count,
                type == rune?.tileType {
                    advanceGoal(units: count)
                }
            default:
                return
            }
        }
    }
}

class RuneSlot: SKSpriteNode {
    let viewModel: RuneSlotViewModel
    
    struct Constants {
        static let backgroundScale = CGFloat(0.9)
        static let runeScale = CGFloat(0.8)
    }
    
    private lazy var outline: SKShapeNode = {
        let goldOutline = SKShapeNode(rectOf: self.frame.size)
        goldOutline.color = .goldOutlineDull
        
        return goldOutline
    }()
    
    private lazy var background: SKShapeNode = {
        let background = SKShapeNode(rectOf: self.frame.size.scale(by: Constants.backgroundScale))
        background.color = .runeBackgroundColor
        
        return background
    }()
    
    private lazy var runeSprite: SKSpriteNode? = {
        if let rune = viewModel.rune {
            let textureName = rune.textureName
            let sprite = SKSpriteNode(texture: SKTexture(imageNamed: textureName), size: self.frame.size.scale(by: Constants.runeScale))
            
            return sprite
        }
        
        return nil
    }()
    
    init(viewModel: RuneSlotViewModel, size: CGSize) {
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        
        setupView()
    }
    
    func setupView() {
        addChild(outline)
        addChild(background)
        addChildSafely(runeSprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
