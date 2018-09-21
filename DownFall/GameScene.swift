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
    //TODO: refactor this to either include all possible actions taken on the board, or indicate that this is only actions that the model cares about.  ie why isnt rotate in this?
}

protocol GameSceneDelegate: class {
    func display(alert: UIAlertController)
}

class GameScene: SKScene {
    
    let boardSize = 4
    
    private var foreground : SKNode!
    private var board : Board
    
    //buttons
    private var left : SKNode!
    private var right: SKNode!

    //animating
    private var animating: Bool = false
    
    //coordinates
    private var bottomLeft : (Int, Int)
    
    //deleagte
    weak var gameSceneDelegate: GameSceneDelegate?

    required init?(coder aDecoder: NSCoder) {
        self.board = Board.build(size: boardSize)
        let tileSize = board.getTileSize()
        bottomLeft = (-1 * tileSize/2 * boardSize, -1 * tileSize/2 * boardSize )
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func didMove(to view: SKView) {
        foreground = self.childNode(withName: "foreground")!
        addTileNodes(board.spriteNodes)
    }
    
    private func commonInit(){
        NotificationCenter.default.addObserver(self, selector: #selector(neighborsFound), name: .neighborsFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lessThanThreeNeighborsFound), name: .lessThanThreeNeighborsFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .rotated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(computeNewBoard), name: .computeNewBoard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gameWin), name: .gameWin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noMovesLeft), name: .noMovesLeft, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension GameScene {

    private func resetBoardUI() {
        let tileSize = board.getTileSize()
        
        //remove all tiles
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let point = CGPoint.init(x: tileSize*col+bottomLeft.1, y: tileSize*row+bottomLeft.1)
                for child in foreground.children {
                    if child.contains(point) {
                        child.removeFromParent()
                        break
                    }
                }
            }
        }
        addTileNodes(self.board.spriteNodes)
    }
    
    private func addTileNodes(_ given : [[DFTileSpriteNode]]) {
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
        
        for buttonIdx in 0..<board.buttons.count {
            //TODO: make this device indifferent
            let button = board.buttons[buttonIdx]
            let x = bottomLeft.0 + (300 * buttonIdx)
            let y = bottomLeft.1 - 300
            button.position = CGPoint.init(x: x, y: y)
            foreground.addChild(button)
        }
    }
    
    private func checkBoardState() {
        board.checkGameState()
    }

    
}

// MARK: Board notifications

extension GameScene {
    @objc private func computeNewBoard(notification: NSNotification) {
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
            let sprite = board.spriteNodes[endRow][endCol]
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
                strongSelf.checkBoardState()
                strongSelf.animating = false
            }
        }

    }

    @objc private func neighborsFound(notification: NSNotification) {
        //neighbors found means a new search was started, so remove blinking from other groups
        guard let tiles = notification.userInfo?["tiles"] as? [(Int, Int)] else { fatalError("No tiles in notification") }
        board.blinkTiles(at: tiles)
        animating = false
    }
    
    @objc private func lessThanThreeNeighborsFound(notification: NSNotification) {
        //player touched a non-blinking tile, remove blinking from other groups
        animating = false
    }
    
    @objc private func rotated(notification: NSNotification) {
        guard let transformation = notification.userInfo?["transformation"] as? [Transformation] else { fatalError("No transformations provided for rotate") }
        var animationCount = 0
        animate(transformation) { [weak self] in
            guard let strongSelf = self else { return }
            animationCount += 1
            if animationCount == transformation.count {
                strongSelf.checkBoardState()
                strongSelf.animating = false
            }
        }
    }
    
    @objc private func gameWin(notification: NSNotification) {
//        guard let transformation = notification.userInfo?["transformation"] as? [Transformation] else { fatalError("No transformations provided for game win") }
        //TODO: animate the actaull win, show a pop up and reset the board on click
    }
    
    @objc private func noMovesLeft(notification: NSNotification) {
        //TODO: show a pop that no moves left and reset boar don click
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
        var handledTouch = false
        defer {
            if !handledTouch {
                animating = false
            }
        }
        handledTouch = board.handledInput(touch.location(in: self))
    }
}

//MARK: - Communication from VC
extension GameScene {
    //TODO: figure out a way to not expose a reset function publically
    func reset() {
        self.board = self.board.reset() // this should likely be triggered by anothing notification
        self.resetBoardUI()
    }
}

