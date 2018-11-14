//
//  GameScene.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol GameSceneDelegate: class {
    func shouldShowMenu(win: Bool)
}

class GameScene: SKScene {
    
    private var boardSize: Int?
    private var board: Board? {
        didSet {
            // TODO: animate change render board
        }
    }
    
    //coordinates
    private var bottomLeft: (Int, Int)?
    
    //foreground
    private var foreground: SKNode!
    
    //buttons
    private var rotateLeft: SKNode!
    private var rotateRight: SKNode!
    private var setting: SKNode!

    //animating
    private var animating: Bool = false
    
    
    //deleagte
    weak var gameSceneDelegate: GameSceneDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        foreground = self.childNode(withName: "foreground")!
        setting = self.childNode(withName: "setting")!
        rotateRight = self.childNode(withName: "rotateRight")!
        rotateLeft = self.childNode(withName: "rotateLeft")!
        addTileNodes()
    }
    
    public func commonInit(boardSize bsize: Int){
        board = Board.build(size: bsize)
        let tileSize = board!.getTileSize()
        bottomLeft = (-1 * tileSize/2 * bsize, -1 * tileSize/2 * bsize )
        self.boardSize = bsize
        
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
        guard let tileSize = board?.getTileSize(),
            let boardSize = boardSize,
            let bottomLeftX = bottomLeft?.1,
            let bottomLeftY = bottomLeft?.0 else { fatalError("No board") }
        
        //remove all tiles
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let point = CGPoint.init(x: tileSize*col+bottomLeftX, y: tileSize*row+bottomLeftY)
                for child in foreground.children {
                    if child.contains(point) {
                        child.removeFromParent()
                        break
                    }
                }
            }
        }
        addTileNodes()
    }
    
    private func addTileNodes() {
        guard let board = board,
            let boardSize = boardSize,
            let bottomLeft = bottomLeft else { fatalError("no board/bottomLeft given") }
        let tileSize = board.getTileSize()
        let spriteNodes = board.spriteNodes
        var x : Int = 0
        var y : Int = 0
        for row in 0..<boardSize {
            y = row * tileSize + bottomLeft.0
            for col in 0..<boardSize {
                x = col * tileSize + bottomLeft.1
                spriteNodes[row][col].position = CGPoint.init(x: x, y: y)
                foreground.addChild(spriteNodes[row][col])
            }
        }
    }
    
    private func checkBoardState() {
        guard let board = board else { fatalError("No Board") }
        board.checkGameState()
    }

    
}

// MARK: Board notifications

extension GameScene {
    @objc private func computeNewBoard(notification: NSNotification) {
        guard let removed = notification.userInfo?["removed"] as? [TileCoord],
            let newTiles = notification.userInfo?["newTiles"] as? [Transformation],
            let shiftDown = notification.userInfo?["shiftDown"] as? [Transformation],
            let tileSize = board?.getTileSize(),
            let bottomLeftX = bottomLeft?.1,
            let bottomLeftY = bottomLeft?.0,
            let spriteNodes = board?.spriteNodes,
            let boardSize = boardSize else { fatalError("Unable to parse computed new board") }
        
        //remove "removed" tiles
        for (row, col) in removed {
            let point = CGPoint.init(x: tileSize*col+bottomLeftX, y: tileSize*row+bottomLeftY)
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
            let sprite = spriteNodes[endRow][endCol]
            let x = tileSize * boardSize + ( startRow * tileSize ) + bottomLeftX
            let y = tileSize * startCol + bottomLeftY
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
        guard let transformation = notification.userInfo?["transformation"] as? [Transformation] else { fatalError("No transformations provided for game win") }
        //TODO: can we do this without closures?
        animate(transformation) { [weak self] in
            guard let strongSelf = self else { return }
            let wait = SKAction.wait(forDuration:0.5)
            let action = SKAction.run { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.gameSceneDelegate?.shouldShowMenu(win: true)
            }
            strongSelf.run(SKAction.sequence([wait,action]))
        }
    }
    
    @objc private func noMovesLeft(notification: NSNotification) {
        let wait = SKAction.wait(forDuration:0.5)
        let action = SKAction.run { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.gameSceneDelegate?.shouldShowMenu(win: false)
        }
        self.run(SKAction.sequence([wait,action]))
        
    }
}

//MARK: Transformation Animation

extension GameScene {
    func animate(_ transformation: [Transformation], _ completion: (() -> Void)? = nil) {
        guard let tileSize = board?.getTileSize(),
            let boardSize = boardSize,
            let bottomLeftX = bottomLeft?.1,
            let bottomLeftY = bottomLeft?.0 else { fatalError("no board") }
        var childActionDict : [SKNode : SKAction] = [:]
        for transIdx in 0..<transformation.count {
            let trans = transformation[transIdx]
            let outOfBounds = trans.initial.0 >= boardSize ? tileSize * boardSize : 0
            let point = CGPoint.init(x: tileSize*trans.initial.1+bottomLeftX, y: outOfBounds + tileSize*trans.initial.0+bottomLeftY)
            for child in foreground.children {
                if child.contains(point) {
                    let endPoint = CGPoint.init(x: tileSize*trans.end.1+bottomLeftX, y: tileSize*trans.end.0+bottomLeftY)
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
        //TODO: pass tileSize into all of these or make it a global static variable
        guard let tileSize = board?.getTileSize(),
            let bottomLeftX = bottomLeft?.1,
            let bottomLeftY = bottomLeft?.0 else { fatalError("no board") }
        let trans = transformation
        let point = CGPoint.init(x: tileSize*trans.initial.1+bottomLeftX, y: tileSize*trans.initial.0+bottomLeftY)
        
        for child in foreground.children {
            if child.contains(point) {
                let endPoint = CGPoint.init(x: tileSize*trans.end.1+bottomLeftX, y: tileSize*trans.end.0+bottomLeftY)
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
        if setting.contains(touch.location(in: self)) {
            self.reset()
            return
        } else if rotateRight.contains(touch.location(in: self)) {
            board = board?.rotate(.right)
            return
        } else if rotateLeft.contains(touch.location(in:self)) {
            board = board?.rotate(.left)
            return
        }
        board = board?.handleInput(touch.location(in: self))
    }
}

//MARK: - Communication from VC
extension GameScene {
    //TODO: figure out a way to not expose a reset function publically
    // this should onyl be called the settings button as a debug quick restart
    func reset() {
        self.board = self.board?.resetNoMoreMoves() // this should likely be triggered by anothing notification
        self.resetBoardUI()
    }
}
