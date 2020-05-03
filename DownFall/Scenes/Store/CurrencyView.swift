//
//  CurrencyView.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol CurrencyViewModelable {
    var currencySprite: SKSpriteNode { get }
    var amount: Int { get }
}

struct CurrencyViewModel: CurrencyViewModelable {
    let currency: Currency
    let amount: Int
    
    var textureName: String {
        return currency.rawValue
    }
    
    var textureSize: CGSize {
        return Style.HUD.heartSize
    }
    
    var currencySprite: SKSpriteNode {
        return SKSpriteNode(texture: SKTexture(imageNamed: textureName), size: textureSize)
    }
}

class CurrencyView: SKSpriteNode {
    let viewModel: CurrencyViewModelable
    
    init(viewModel: CurrencyViewModelable, size: CGSize) {
        self.viewModel = viewModel
                
        super.init(texture: nil, color: .lightBarBlue, size: size)
        
        let currencySprite = viewModel.currencySprite
        let currencyParagraph = ParagraphNode(text: "\(viewModel.amount)", paragraphWidth: self.frame.maxX - currencySprite.frame.maxX)
        
        currencySprite.position = CGPoint.position(currencySprite.frame, inside: self.frame, verticalAlign: .center, horizontalAnchor: .left)
        currencySprite.zPosition = Precedence.menu.rawValue
        
        currencyParagraph.position = CGPoint.alignVertically(currencyParagraph.frame, relativeTo: currencySprite.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        currencyParagraph.zPosition = Precedence.menu.rawValue
        
        addChild(currencySprite)
        addChild(currencyParagraph)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
