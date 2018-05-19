//
//  DFTileSpriteNode.swift
//  DownFall
//
//  Created by William Katz on 5/11/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

enum Search : Int {
    case white
    case gray
    case black
}

enum Color : String {
    case blue = "blue"
    case black = "black"
    case green = "green"
    case empty = "empty"
    
    static let allValues = [blue, black, green, empty]
}

class DFTileSpriteNode : SKSpriteNode {
    
    
    var rockColor : Color
    var search : Search
    var selected : Bool = false
    
    init(color: Color, search: Search = .white, texture: SKTexture = SKTexture.init(imageNamed: "emptyTexture")) {
        self.rockColor = color
        self.search = search
        super.init(texture: texture, color: .clear, size: CGSize.init(width: 75.0, height: 75.0))
    }

    class func randomTile() -> DFTileSpriteNode {
        let randomNumber = Int(arc4random() % 3)
        let newColor = Color.allValues[randomNumber]
        let texture = SKTexture.init(imageNamed: "\(newColor)Rock")
        return DFTileSpriteNode.init(color: newColor, texture: texture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Aint implemented")
    }
}
