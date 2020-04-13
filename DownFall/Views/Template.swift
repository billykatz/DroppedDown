//
//  Template.swift
//  DownFall
//
//  Created by Katz, Billy on 4/11/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol TemplateViewModelable {}

struct TemplateViewModel: TemplateViewModelable {}

class TemplateBar: SKSpriteNode {
    let viewModel: TemplateViewModelable
    let contentView: SKSpriteNode
    
    init(size: CGSize, viewModel: TemplateViewModelable) {
        contentView = SKSpriteNode.init(texture: nil, color: .clear, size: size)
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



