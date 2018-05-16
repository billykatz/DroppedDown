//
//  GameScene.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let boardSize = 5
    
    private var foreground : SKNode!
    private var resetButton : SKNode!
    private var board : Board
    private var tileNodes : [[SKSpriteNode]]

    
    override func didMove(to view: SKView) {
        foreground = self.childNode(withName: "foreground")!
        resetButton = self.childNode(withName: "reset")!
        addTileNodes(tileNodes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.board = Board.build(size: boardSize)
        tileNodes = SpriteBuilder.buildSprites(for: board)
        super.init(coder: aDecoder)
    }
    
    func addTileNodes(_ given: [[SKSpriteNode]]) {
        var x = 0
        var y = 0
        for row in 0..<given.count {
            y = row * Tile.tileSize
            for col in 0..<given.count {
                x = col * Tile.tileSize
                given[row][col].position = CGPoint.init(x: x, y: y)
                foreground.addChild(given[row][col])
            }
        }
    }
    
    func blinkTiles(at locations: [(Int, Int)], for texture: SKTexture) {
        let blinkOff = SKAction.fadeOut(withDuration: 0.2)
        let blinkOn = SKAction.fadeIn(withDuration: 0.2)
        let blink = SKAction.repeatForever(SKAction.sequence([blinkOn, blinkOff]))

        for locale in locations {
            tileNodes[locale.0][locale.1].run(blink)
        }
    }
    
    func removeActions() {
        for i in 0..<tileNodes.count {
            for j in 0..<tileNodes[i].count {
                tileNodes[i][j].removeAllActions()
                tileNodes[i][j].run(SKAction.fadeIn(withDuration: 0.2))
            }
        }
    }
}


extension GameScene {

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        registerTouch(touch)
    }
    
    func registerTouch(_ touch: UITouch) {
        let touchPoint = touch.location(in: self)
        for row in 0..<tileNodes.count {
            for col in 0..<tileNodes[row].count {
                if tileNodes[row][col].contains(touchPoint) {
                    if board.selectedTiles.contains(where: { (locale) -> Bool in
                        return (row, col) == locale
                    }) {
                        board.shiftReplaceTiles()
                        foreground.removeAllChildren()
                        tileNodes = SpriteBuilder.buildSprites(for: board)
                        addTileNodes(tileNodes)
                    } else {
                        removeActions()
                        let texture = board.tiles[row][col].texture
                        blinkTiles(at: board.findNeighbors(row, col), for: texture)
                    }
                }
            }
        }
        if resetButton.contains(touchPoint) {
            board.reset(size: boardSize)
            foreground.removeAllChildren()
            tileNodes = SpriteBuilder.buildSprites(for: board)
            addTileNodes(tileNodes)
        }
    }
    
}
