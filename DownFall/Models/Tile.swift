//
//  Tile.swift
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

class Tile {
    
    static let tileSize = 50
    
    var color : Color
    var search : Search
    var texture : SKTexture
    
    init(color: Color, search: Search = .white, texture: SKTexture = SKTexture.init(imageNamed: "emptyTexture")) {
        self.color = color
        self.search = search
        self.texture = texture
    }

    class func randomTile() -> Tile {
        let randomNumber = Int(arc4random() % 3)
        let newColor = Color.allValues[randomNumber]
        let texture = SKTexture.init(imageNamed: "\(newColor)Rock")
        return Tile.init(color: newColor, texture: texture)
    }
}
