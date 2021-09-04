//
//  PickaxeView.swift
//  DownFall
//
//  Created by Katz, Billy on 5/3/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol PickaxeViewModelable {}

struct PickaxeViewModel: PickaxeViewModelable {
    
}

class PickaxeView: SKSpriteNode {
    let viewModel: PickaxeViewModelable
    
    init(viewModel: PickaxeViewModelable, size: CGSize) {
        self.viewModel = viewModel
        
        super.init(texture: nil, color: .lightBarPurple, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
