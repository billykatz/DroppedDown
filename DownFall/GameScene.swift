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

    //animating
    private var animating: Bool = false
    
    //save to pass to model
    private var selectedTiles: [(Int, Int)] = []
    
    //coordinates
    private var bottomLeft : (Int, Int)

    required init?(coder aDecoder: NSCoder) {
        self.board = Board.build(size: boardSize)
        let tileSize = board.getTileSize()
        bottomLeft = (-1 * tileSize/2 * boardSize, -1 * tileSize/2 * boardSize )
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
        NotificationCenter.default.addObserver(self, selector: #selector(neighborsFound), name: .neighborsFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .rotated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(computeNewBoard), name: .computeNewBoard, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension GameScene {
    
    func boardChanged(_ reason: BoardChange) {
        switch reason {
        case .findNeighbors(let x, let y):
            if board.getSelectedTiles().count > 0 {
                var count = 0
                board.removeActions() { [weak self] in
                    guard let strongSelf = self else { return }
                    count += 1
                    if count == strongSelf.board.getSelectedTiles().count {
                        strongSelf.board.findNeighbors(x, y)
                    }
                }
            } else {
                board.findNeighbors(x, y)
            }
        case .remove:
            board.removeAndRefill(selectedTiles)
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
            y = row * tileSize + bottomLeft.0
            for col in 0..<given.count {
                x = col * tileSize + bottomLeft.1
                given[row][col].position = CGPoint.init(x: x, y: y)
                foreground.addChild(given[row][col])
            }
        }
    }
    
    func checkForWin() {
        if (board.checkWinCondition()) {
            print("youwin")
        }
    }

    
}

// MARK: Board notifications

extension GameScene {
    @objc func computeNewBoard(notification: NSNotification) {
        guard let removed = notification.userInfo?["removed"] as? [TileCoord],
            let newTiles = notification.userInfo?["newTiles"] as? [Transformation],
            let shiftDown = notification.userInfo?["shiftDown"] as? [Transformation] else { fatalError("Unable to parse computed new board") }
        
        
        let tileSize = board.getTileSize()
        
        //remove "removed" tiles
        for (row, col) in removed {
            let point = CGPoint.init(x: tileSize*col+bottomLeft.1, y: tileSize*row+bottomLeft.1)
            for child in foreground.children {
                if child.contains(point) {
                    child.removeFromParent()
                    break
                }
            }
        }
        
        //add new tiles "newTiles"
        for trans in newTiles {
            let (startRow, startCol) = trans.initial
            let (endRow, endCol) = trans.end
            let sprite = board.sprites()[endRow][endCol]
            let x = tileSize * boardSize + ( startRow * tileSize ) + bottomLeft.0
            let y = tileSize * startCol + bottomLeft.1
            sprite.position = CGPoint.init(x: y, y: x)
            foreground.addChild(sprite)
        }
        
        //animation "shiftDown" transformation
        var count = shiftDown.count
        animate(shiftDown) { [weak self] in
            guard let strongSelf = self else { return }
            count -= 1
            if count == 0 {
                strongSelf.checkForWin()
                strongSelf.animating = false
            }
        }

    }

    @objc func neighborsFound(notification: NSNotification) {
        //neighbors found means a new search was started, so remove blinking from other groups
        board.removeActions()
        guard let tiles = notification.userInfo?["tiles"] as? [(Int, Int)] else { fatalError("No tiles in notification") }
        selectedTiles = tiles
        board.blinkTiles(at: tiles)
        animating = false
    }
    
    
    @objc func rotated(notification: NSNotification) {
        guard let transformation = notification.userInfo?["transformation"] as? [Transformation] else { fatalError("No transformations provided for rotate") }
        var animationCount = 0
        animate(transformation) { [weak self] in
            guard let strongSelf = self else { return }
            animationCount += 1
            if animationCount == transformation.count {
                strongSelf.checkForWin()
                strongSelf.animating = false
            }
        }
    }
    
}

//MARK: Transformation Animation

extension GameScene {
    func animate(_ transformation: [Transformation], _ completion: (() -> Void)? = nil) {
        var childActionDict : [SKNode : SKAction] = [:]
        for transIdx in 0..<transformation.count {
            let trans = transformation[transIdx]
            let tileSize = board.getTileSize()
            let outOfBounds = trans.initial.0 >= boardSize ? tileSize * boardSize : 0
            let point = CGPoint.init(x: tileSize*trans.initial.1+bottomLeft.1, y: outOfBounds + tileSize*trans.initial.0+bottomLeft.1)
            for child in foreground.children {
                if child.contains(point) {
                    let endPoint = CGPoint.init(x: tileSize*trans.end.1+bottomLeft.1, y: tileSize*trans.end.0+bottomLeft.0)
                    let animation = SKAction.move(to: endPoint, duration: AnimationSettings.fallSpeed)
                    childActionDict[child] = animation
                    break
                }
            }
            
        }
        for (child, action) in childActionDict {
            child.run(action) {
                completion?()
            }
        }
    }
    
    
    func animate(_ transformation: Transformation, _ completion: (() -> Void)? = nil) {
        let trans = transformation
        let tileSize = board.getTileSize()
        let point = CGPoint.init(x: tileSize*trans.initial.1+bottomLeft.1, y: tileSize*trans.initial.0+bottomLeft.1)
        
        for child in foreground.children {
            if child.contains(point) {
                let endPoint = CGPoint.init(x: tileSize*trans.end.1+bottomLeft.1, y: tileSize*trans.end.0+bottomLeft.0)
                let animation = SKAction.move(to: endPoint, duration: AnimationSettings.fallSpeed)
                child.run(animation) {
                    completion?()
                }
                return
            }
        }
    }

}

// MARK: Touch Relay

extension GameScene {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard !animating else { return }
        animating = true
        registerTouch(touch)
    }
    
    func registerTouch(_ touch: UITouch) {
        let touchPoint = touch.location(in: self)
        var handledTouch = false
        for col in 0..<board.sprites().count {
            for row in 0..<board.sprites()[col].count {
                if board.sprites()[col][row].contains(touchPoint) {
                    if board.sprites()[col][row].selected{
                        boardChanged(BoardChange.remove)
                        handledTouch = true
                    } else {
                        if board.sprites()[col][row].type != .player &&
                            board.sprites()[col][row].type != .exit {
                            boardChanged(BoardChange.findNeighbors(col, row))
                            handledTouch = true
                        } else {
                            handledTouch = false
                            
                        }
                    }
                }
            }
        }
    
        if left.contains(touchPoint) {
            board.rotate(.left)
            handledTouch = true
        }
        
        if right.contains(touchPoint) {
            board.rotate(.right)
            handledTouch = true
        }
        if !handledTouch {
            animating = false
        }
    }

}
