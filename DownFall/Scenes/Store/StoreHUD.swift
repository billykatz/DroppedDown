//
//  StoreHUD.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol StoreHUDViewModelable {
    var currentHealth: Int { get }
    var totalHealth: Int { get }
    var totalGems: Int { get }
    var pickaze: Pickaxe? { get }
}

struct StoreHUDViewModel: StoreHUDViewModelable {
    var currentHealth: Int {
        return playerData.hp
    }
    
    var totalHealth: Int {
        return playerData.originalHp
    }
    
    var totalGems: Int {
        return playerData.carry.total(in: .gem)
    }
    
    var pickaze: Pickaxe? {
        return playerData.pickaxe
    }
    
    let playerData: EntityModel
}

class StoreHUD: SKSpriteNode {
    private let viewModel: StoreHUDViewModel
    private let viewContainer: SKSpriteNode
    
    init(viewModel: StoreHUDViewModel, size: CGSize) {
        self.viewModel = viewModel
        viewContainer = SKSpriteNode(texture: nil, size: size)
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(viewContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
