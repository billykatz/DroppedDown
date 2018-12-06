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
    
    //input queue
    private var inputQueue: InputQueue!
    
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
        inputQueue = InputQueue(queue: [])
        addTileNodes()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !self.animating, let input = inputQueue.pop() else { return }
        animating = true
        guard let transformation = board?.handle(input: input), transformation.tileTransformation != nil else { animating = false; return }
        render(transformation, for: input)
    }
    
    private func render(_ transformation: Transformation?, for input: Input) {
        guard let trans = transformation else { return }
        switch input{
        case .touch(_):
            computeNewBoard(for: trans)
        case .rotateLeft, .rotateRight:
            rotate(for: trans)
        }
    }
    
    public func commonInit(boardSize bsize: Int){
        board = Board.build(size: bsize)
        let tileSize = board!.getTileSize()
        bottomLeft = (-1 * tileSize/2 * bsize, -1 * tileSize/2 * bsize )
        self.boardSize = bsize
        
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
        board?.checkGameState()
    }

    
}

// MARK: Board notifications

extension GameScene {
    private func computeNewBoard(for transformation: Transformation) {
        guard let transformations = transformation.tileTransformation,
            let tileSize = board?.getTileSize(),
            let bottomLeftX = bottomLeft?.1,
            let bottomLeftY = bottomLeft?.0,
            let spriteNodes = board?.spriteNodes,
            let boardSize = boardSize else { return }
        //TODO: don't hardcode this
        let removed = transformations[0]
        let newTiles = transformations[1]
        let shiftDown = transformations[2]
        
        //remove "removed" tiles
        for tileTrans in removed {
            let row = tileTrans.initial.0
            let col = tileTrans.initial.1
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
    
    private func rotate(for transformation: Transformation) {
        var animationCount = 0
        guard let trans = transformation.tileTransformation?[0] else { return }
        animate(trans) { [weak self] in
            guard let strongSelf = self else { return }
            animationCount += 1
            if animationCount == trans.count {
                strongSelf.checkBoardState()
                strongSelf.animating = false
            }
        }
    }
    
    @objc private func gameWin(notification: NSNotification) {
        guard let transformation = notification.userInfo?["transformation"] as? [TileTransformation] else { fatalError("No transformations provided for game win") }
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
    func animate(_ transformation: [TileTransformation], _ completion: (() -> Void)? = nil) {
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
    
//    func animate(_ transformation: TileTransformation, _ completion: (() -> Void)? = nil) {
//        //TODO: pass tileSize into all of these or make it a global static variable
//        guard let tileSize = board?.getTileSize(),
//            let bottomLeftX = bottomLeft?.1,
//            let bottomLeftY = bottomLeft?.0 else { fatalError("no board") }
//        let trans = transformation
//        let point = CGPoint.init(x: tileSize*trans.initial.1+bottomLeftX, y: tileSize*trans.initial.0+bottomLeftY)
//        
//        for child in foreground.children {
//            if child.contains(point) {
//                let endPoint = CGPoint.init(x: tileSize*trans.end.1+bottomLeftX, y: tileSize*trans.end.0+bottomLeftY)
//                let animation = SKAction.move(to: endPoint, duration: AnimationSettings.fallSpeed)
//                child.run(animation) {
//                    completion?()
//                }
//                return
//            }
//        }
//    }

}

// MARK: Touch Relay

extension GameScene {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        registerTouch(touch)
    }
    
    func registerTouch(_ touch: UITouch) {
        var handledTouch = false
        defer {
            if !handledTouch {
                animating = false
            }
        }
        let input : Input
        if setting.contains(touch.location(in: self)) {
            self.reset()
            return
        } else if rotateRight.contains(touch.location(in: self)) {
            input = Input.rotateRight
        } else if rotateLeft.contains(touch.location(in:self)) {
            input = Input.rotateLeft
        } else {
            input = Input.touch(touch.location(in: self))
        }
        handledTouch = true
        inputQueue.append(input)
        print(inputQueue)
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
