//
//  GameScene.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit


enum BoardChange {
    case findNeighbors(Int, Int)
    case remove
}

class GameScene: SKScene {
    
    let boardSize = 6
    
    private var foreground : SKNode!
    private var board : Board
    
    //buttons
    private var left : SKNode!
    private var right: SKNode!

    required init?(coder aDecoder: NSCoder) {
        self.board = Board.build(size: boardSize)
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func didMove(to view: SKView) {
        foreground = self.childNode(withName: "foreground")!
        left = self.childNode(withName: "left")!
        right = self.childNode(withName: "right")!
        addTileNodes(board.sprites())
    }
    
    func commonInit(){
        NotificationCenter.default.addObserver(self, selector: #selector(newTiles), name: .newTiles, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeTiles), name: .removeTiles, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shiftDown), name: .shiftDown, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(neighborsFound), name: .neighborsFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .rotated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension GameScene {
    
    func boardChanged(_ reason: BoardChange) {
        switch reason {
        case .findNeighbors(let x, let y):
            board.removeActions()
            board.findNeighbors(x, y)
        case .remove:
            board.removeTiles()
        }
    }
    
    func getBoard() -> Board {
        return self.board
    }
    
    func addTileNodes(_ given : [[DFTileSpriteNode]]) {
        let tileSize = board.getTileSize()
        var x : Int = 0
        var y : Int = 0
        for row in 0..<given.count {
            y = row * tileSize + board.getBottomLeft().0
            for col in 0..<given.count {
                x = col * tileSize + board.getBottomLeft().1
                given[row][col].position = CGPoint.init(x: x, y: y)
                foreground.addChild(given[row][col])
            }
        }
    }

    
}

// MARK: Board notifications

extension GameScene {
    @objc func removeTiles(notification: NSNotification) {
        //Remove all tiles
        //reload the view with empty tiles shown
        //then shift down
        foreground.removeAllChildren()
        addTileNodes(board.sprites())
        board.shiftDown()
    }
    
    @objc func shiftDown(notification: NSNotification) {
        guard let transformation = notification.userInfo?["transformation"] as? [Transformation] else { fatalError() }
        animate(transformation)
        board.fillEmpty()
    }
    
    @objc func newTiles(notification: NSNotification) {
        guard let newTiles = notification.userInfo?["newTiles"] as? [(Int, Int)] else { fatalError("No new DFTileSpriteNode information") }
        let tileSize = board.getTileSize()
        for (row, col) in newTiles {
            let sprite = board.sprites()[row][col]
            //animate
            let x = tileSize * boardSize + ( row * tileSize ) + board.getBottomLeft().0
            let y = tileSize * col + board.getBottomLeft().1
            sprite.position = CGPoint.init(x: y, y: x)
            sprite.removeFromParent()
            foreground.addChild(sprite)
            let targetPosition = CGPoint.init(x: tileSize*col+board.getBottomLeft().0, y: tileSize*row+board.getBottomLeft().1)
            let moveTo = SKAction.move(to: targetPosition, duration: AnimationSettings.fallSpeed)
            sprite.run(moveTo)
            
        }
        
    }
    
    @objc func neighborsFound(notification: NSNotification) {
        //neighbors found means a new search was started, so remove blinking from other groups
        board.removeActions()
        guard let tiles = notification.userInfo?["tiles"] as? [(Int, Int)] else { fatalError("No tiles in notification") }
        board.blinkTiles(at: tiles)
    }
    
    @objc func rotated(notification: NSNotification) {
        guard let transformation = notification.userInfo?["transformation"] as? [Transformation] else { fatalError("No transformations provided for rotate") }
        animate(transformation)
    }
    
}

//MARK: Transformation Animation

extension GameScene {
    func animate(_ transformation: [Transformation]) {
        for trans in transformation {
            let tileSize = board.getTileSize()
            let point = CGPoint.init(x: tileSize*trans.initial.1+board.getBottomLeft().1, y: tileSize*trans.initial.0+board.getBottomLeft().1)
            for child in foreground.children {
                if child.contains(point) {
                    let endPoint = CGPoint.init(x: tileSize*trans.end.1+board.getBottomLeft().1, y: tileSize*trans.end.0+board.getBottomLeft().0)
                    let animation = SKAction.move(to: endPoint, duration: AnimationSettings.fallSpeed)
                    child.run(animation)
                    continue
                }
            }
            
        }
    }
}

// MARK: Touch Relay

extension GameScene {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        registerTouch(touch)
    }
    
    func registerTouch(_ touch: UITouch) {
        let touchPoint = touch.location(in: self)
        for col in 0..<board.sprites().count {
            for row in 0..<board.sprites()[col].count {
                if board.sprites()[col][row].contains(touchPoint) {
                    if board.getSelectedTiles().contains(where: { (locale) -> Bool in
                        return (col, row) == locale
                    }) {
                        boardChanged(BoardChange.remove)
                    } else {
                        if board.sprites()[col][row].type != .player {
                            boardChanged(BoardChange.findNeighbors(col, row))
                        }
                    }
                }
            }
        }
        if left.contains(touchPoint) {
            board.rotate(.left)
        }
        
        if right.contains(touchPoint) {
            board.rotate(.right)
        }
    }

}
