//
//  Renderer.swift
//  DownFall
//
//  Created by William Katz on 1/27/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

class Renderer {
    let playableRect: CGRect
    var foreground: SKNode = SKNode()
    var sprites: [[DFTileSpriteNode]] = []
    let bottomLeft: CGPoint
    let boardSize: CGFloat!
    let tileSize: CGFloat = 125
    var animating = false
    
    init(playableRect: CGRect,
         foreground: SKNode,
         board: Board) {
        self.playableRect = playableRect
        self.boardSize = CGFloat(board.boardSize)
        
        //center the board in the playable rect
        let marginWidth = playableRect.width - CGFloat(tileSize * boardSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * boardSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        self.bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        //create sprite representations based on the given board.tiles
        self.sprites = createSprites(from: board)
        
        //place the created sprites onto the foreground
//        var centeredForeground = foreground
        foreground.position = playableRect.center
        self.foreground = add(sprites: sprites, to: foreground)
        
        // add settings button to board
        let header = Header.build(color: .black, size: CGSize(width: playableRect.width, height: 200.0))
        header.position = CGPoint(x: playableRect.midX, y: playableRect.maxY - 100.0)
        self.foreground.addChild(header)
        
        
        // add left and right rotate button to board
        let controls = Controls.build(color: .black, size: CGSize(width: playableRect.width, height: 400.0))
        controls.position = CGPoint(x: playableRect.midX, y: playableRect.minY + 100.0)
        self.foreground.addChild(controls)
        
        // add moves left label
        
        
        
        //DEBUG
        #if DEBUG
        if let _ = NSClassFromString("XCTest") {
        } else {
            debugDrawPlayableArea()
        }
        #endif
    }
    
    func add(sprites: [[DFTileSpriteNode]], to foreground: SKNode) -> SKNode {
        foreground.removeAllChildren()
        sprites.forEach {
            $0.forEach { (sprite) in
                if sprite.type == TileType.player() {
                    let group = SKAction.group([SKAction.wait(forDuration:5), sprite.animatedPlayerAction()])
                    let repeatAnimation = SKAction.repeat(group, count: 500)
                    sprite.zPosition = 5
                    sprite.run(repeatAnimation)
                }
                
                foreground.addChild(sprite)
            }
        }
        return foreground

    }
    
    func createSprites(from board: Board) -> [[DFTileSpriteNode]] {
        let tiles = board.tiles
        let bottomLeftX = bottomLeft.x
        let bottomLeftY = bottomLeft.y
        var x : CGFloat = 0
        var y : CGFloat = 0
        var sprites: [[DFTileSpriteNode]] = []
        for row in 0..<Int(boardSize) {
            y = CGFloat(row) * tileSize + bottomLeftY
            sprites.append([])
            for col in 0..<Int(boardSize) {
                x = CGFloat(col) * tileSize + bottomLeftX
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
