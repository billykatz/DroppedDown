//
//  Renderer.swift
//  DownFall
//
//  Created by William Katz on 1/27/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

struct Renderer {
    let playableRect: CGRect
    let foreground: SKNode
    var sprites: [[DFTileSpriteNode]] = []
    let bottomLeft: (Int, Int)
    let boardSize: Int
    let tileSize: Int = 75
    
//    func render(_ board: Board) -> SKNode {
//        
//    }
    
    init(playableRect: CGRect,
         foreground: SKNode,
         board: Board,
         size: Int) {
        self.playableRect = playableRect
        self.foreground = foreground
        self.boardSize = size
        self.bottomLeft = (Int(-1 * tileSize/2 * boardSize), Int(-1 * tileSize/2 * boardSize))
        self.sprites = createSprites(from: board)
        
        //rendering
        add(sprites: sprites, to: foreground)
        
        //DEBUG
        debugDrawPlayableArea()
    }
    
    func add(sprites: [[DFTileSpriteNode]], to foreground: SKNode) {
        sprites.forEach {
            $0.forEach { (sprite) in
                if sprite.type == TileType.player() {
                    let group = SKAction.group([SKAction.wait(forDuration:5), sprite.animatedPlayerAction()])
                    let repeatAnimation = SKAction.repeat(group, count: 500)
                    sprite.zPosition = 5
                    sprite.run(repeatAnimation)
                }
                
                //add it to the scene
                foreground.addChild(sprite)
            }
        }

    }
    
    func createSprites(from board: Board) -> [[DFTileSpriteNode]] {
        let tiles = board.tiles
        let bottomLeftX = bottomLeft.1
        let bottomLeftY = bottomLeft.0
        var x : Int = 0
        var y : Int = 0
        var sprites: [[DFTileSpriteNode]] = []
        for row in 0..<boardSize {
            y = row * tileSize + bottomLeftY
            sprites.append([])
            for col in 0..<boardSize {
                x = col * tileSize + bottomLeftX
                sprites[row].append(DFTileSpriteNode(type: tiles[row][col], size: CGFloat(tileSize)))
                sprites[row][col].position = CGPoint.init(x: x, y: y)
            }
        }
        return sprites

    }
}


//MARK: Debug

extension Renderer {
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        shape.zPosition = 10
        foreground.addChild(shape)
    }
}
