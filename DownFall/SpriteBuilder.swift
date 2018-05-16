//
//  SpriteBuilder.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

class SpriteBuilder {
    
//    static let sharedInstance = SpriteBuilder()
    
    class func buildSprites(for board: Board) -> [[SKSpriteNode]] {
        let tiles = board.tiles
        var tileSprites : [[SKSpriteNode]] = [[]]
        for row in 0..<tiles.count {
            if row != 0 { tileSprites.append([]) }
            for col in  0..<tiles[row].count {
                let tile = tiles[row][col]
                let texture = tile.texture
                let tileSprite = SKSpriteNode.init(texture: texture)
                tileSprites[row].append(tileSprite)
            }
        }
        return tileSprites
        
    }
}
