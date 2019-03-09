//
//  GameScene.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit
import UIKit

protocol GameSceneDelegate: class {
    func shouldShowMenu(win: Bool)
}

class GameScene: SKScene {
    
    private var tileSize = 100
    private var boardSize: Int?
    private var board: Board? {
        didSet {
            if board != nil {
                referee = Referee(board!)
            }
        }
    }
    private var spriteNodes: [[DFTileSpriteNode]]?
    
    //coordinates
    private var bottomLeft: (Int, Int)?
    
    //foreground
    private var foreground: SKNode!
    private var setting: SKNode!

    //animating
    private var animating: Bool = false
    
    //input queue
//    private var inputQueue: InputQueue!
    
    //diffculty
    private var difficulty: Difficulty?
    
    //deleagte
    weak var gameSceneDelegate: GameSceneDelegate?
    
    //game referee
    private var referee: Referee?
    
    //renderer
    private var renderer: Renderer?
    
    //playable margin
    private var playableRect: CGRect?

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparationg necessary for didMove(to:) to be called
    public func commonInit(boardSize bsize: Int, difficulty: Difficulty = .normal){
        //TODO: the  order of the following lines of code matter.  (bottom left has to happen before create and position. Consider refactoring
        self.difficulty = difficulty
        board = Board.build(size: bsize)
        boardSize = bsize
        bottomLeft = (-1 * tileSize/2 * bsize, -1 * tileSize/2 * bsize)
        
        referee = Referee(board!)
    }
    
    override func didMove(to view: SKView) {
        foreground = self.childNode(withName: "foreground")!
        setting = self.childNode(withName: "setting")!
        
        //Adjust the playbale rect depending on the size of the device
        let maxAspectRatio : CGFloat = 19.5/9.0
        let playableWidth = size.height / maxAspectRatio
        let playableRect = CGRect(x: -playableWidth/2,
                              y: -size.height/2,
                              width: playableWidth,
                              height: size.height)
        self.renderer = Renderer(playableRect: playableRect,
                                 foreground: foreground,
                                 board: self.board!)
    }
    
    /// Called every frame
    /// We try to digest the top of the queue every frame
    override func update(_ currentTime: TimeInterval) {
        guard let input = InputQueue.pop() else { return }
        guard let transformation = board?.handle(input: input) else { animating = false; return }
        referee = Referee(transformation.endBoard)
        render(transformation, for: input)
    }
    
    
    /// Switches on input type and calls the appropriate function to determine the new board
    private func render(_ transformation: Transformation?, for input: Input) {
        guard let trans = transformation else { return }
        switch input{
        case .touch(_):
            board = trans.endBoard
            computeNewBoard(for: trans)
        case .rotateLeft, .rotateRight:
            board = trans.endBoard
            renderer?.rotate(for: trans)
        case .playerAttack:
            // we should just render the new board here
            render(board: trans.endBoard)
            return
        case .monsterAttack:
            self.animating = false
            return
        case .monsterDies(_):
            board = trans.endBoard
            computeNewBoard(for: trans)
        case .gameWin:
            gameWin(trans)
        case .gameLose:
            gameLost()
        case .animationFinished:
            animationsFinished()
        }
    }
}

//MARK: - Adding and Calculating Sprite Tiles

extension GameScene {
    
    /// Adds all sprite nodes from the store of [[DFTileSpriteNodes]] to the foreground
    private func addSpriteTilesToScene() {
        spriteNodes?.forEach { $0.forEach { (sprite) in
            if sprite.type == TileType.player() {
                let group = SKAction.group([SKAction.wait(forDuration:5), sprite.animatedPlayerAction()])
                let repeatAnimation = SKAction.repeat(group, count: 500)
                sprite.zPosition = 5
                sprite.run(repeatAnimation)
            }
            foreground.addChild(sprite)
            }
        }
    }
    
    /// Create sprite nodes from a 2d list of TileTypes and calculates their positions
    private func createAndPositionSprites(from tiles: [[TileType]]?) -> [[DFTileSpriteNode]]? {
        guard let tiles = tiles,
            let bottomLeftX = bottomLeft?.1,
            let bottomLeftY = bottomLeft?.0,
            let boardSize = boardSize else { return nil }
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

// MARK: -  Board Transformations

extension GameScene {
    private func computeNewBoard(for transformation: Transformation) {
        guard let transformations = transformation.tileTransformation,
            let bottomLeftX = bottomLeft?.1,
            let bottomLeftY = bottomLeft?.0,
            let spriteNodes = createAndPositionSprites(from: transformation.endTiles),
            let boardSize = boardSize else { animating = false; return }
        //TODO: don't hardcode this
        let removed = transformations[0]
        let newTiles = transformations[1]
        let shiftDown = transformations[2]
        
        //remove "removed" tiles from sprite storage
        for tileTrans in removed {
            self.spriteNodes?[tileTrans.end.x][tileTrans.end.y].removeFromParent()
        }
        
        //add new tiles "newTiles"
        for trans in newTiles {
            let (startRow, startCol) = trans.initial.tuple
            let (endRow, endCol) = trans.end.tuple
            
            // create a sprite based on the endTileType injected into this method
            let sprite = spriteNodes[endRow][endCol]
            
            // place the tile at the "start" which is above the visible board
            // the animation will then move them to the correct place in the foreground
            let x = tileSize * boardSize + ( startRow * tileSize ) + bottomLeftX
            let y = tileSize * startCol + bottomLeftY
            sprite.position = CGPoint.init(x: y, y: x)
            
            //add it to the scene
            foreground.addChild(spriteNodes[endRow][endCol])
        }
        
        //animation "shiftDown" transformation
        var count = shiftDown.count
        animate(shiftDown) { [weak self] in
            guard let strongSelf = self else { return }
            count -= 1
            if count == 0 {
//                strongSelf.animationsFinished(for: spriteNodes)
            }
        }
    }
    
//    /// Animate each tileTransformation to display rotation
    private func rotate(for transformation: Transformation) {
        var animationCount = 0
        guard let trans = transformation.tileTransformation?.first,
            let spriteNodes = createAndPositionSprites(from: transformation.endTiles) else { return }
        animate(trans) { [weak self] in
            guard let strongSelf = self else { return }
            animationCount += 1
            if animationCount == trans.count {
                strongSelf.animationsFinished()
            }
        }
    }
    
    //MARK: - Helper Methods
    private func animationsFinished() {
        animating = false
        
        //TODO: Update Referee
//        referee?.enforceRules().forEach { InputQueue.append($0) }
    }
    
    private func render(board: Board) {
        guard let newBoard = createAndPositionSprites(from: board.tiles) else { return }
        animationsFinished()
    }
}

//MARK: -  Animation

extension GameScene {
    private func animate(_ transformation: [TileTransformation], _ completion: (() -> Void)? = nil) {
        guard let boardSize = boardSize,
            let bottomLeftX = bottomLeft?.1,
            let bottomLeftY = bottomLeft?.0 else { fatalError("no board") }
        var childActionDict : [SKNode : SKAction] = [:]
        for transIdx in 0..<transformation.count {
            let trans = transformation[transIdx]
            let outOfBounds = trans.initial.x >= boardSize ? tileSize * boardSize : 0
            let point = CGPoint.init(x: tileSize*trans.initial.tuple.1+bottomLeftX, y: outOfBounds + tileSize*trans.initial.x+bottomLeftY)
            for child in foreground.children {
                if child.contains(point) {
                    let endPoint = CGPoint.init(x: tileSize*trans.end.y+bottomLeftX, y: tileSize*trans.end.x+bottomLeftY)
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
}

// MARK: - Touch Relay

extension GameScene {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.renderer?.touchesEnded(touches, with: event)
//        guard let touch = touches.first else { return }
//        registerTouch(touch)
    }
//
//    private func registerTouch(_ touch: UITouch) {
//        var handledTouch = false
//        defer {
//            if !handledTouch {
//                animating = false
//            }
//        }
//        var input: Input? = nil
//        if setting.contains(touch.location(in: self)) {
//            //self.reset()
//            print(self.board as Any)
//            print(self.debugBoardSprites())
//            return
//        }
//
//        handledTouch = true
//        guard let inputReal = input else { return }
//        InputQueue.append(inputReal)
//    }
}

//MARK: - Game win and Game loss

extension GameScene {
    private func gameWin(_ transformation: Transformation) {
        guard let trans = transformation.tileTransformation?.first else { return }
        animate(trans) { [weak self] in
            guard let strongSelf = self else { return }
            let wait = SKAction.wait(forDuration:0.5)
            let action = SKAction.run { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.gameSceneDelegate?.shouldShowMenu(win: true)
            }
            strongSelf.run(SKAction.sequence([wait,action]))
        }
    }
    
    private func gameLost() {
        let wait = SKAction.wait(forDuration:0.5)
        let action = SKAction.run { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.gameSceneDelegate?.shouldShowMenu(win: false)
        }
        self.run(SKAction.sequence([wait,action]))
    }
}

extension GameScene {
    func debugBoardSprites() -> String {
//        var outs = "\nTop of SpriteNodes"
//        for (i, _) in spriteNodes!.enumerated().reversed() {
//            outs += "\n"
//            for (j, _) in spriteNodes![i].enumerated() {
//                outs += "\t\(spriteNodes![i][j].type)"
//            }
//        }
//        outs += "\nbottom of SpriteNodes"
//        return outs
        return ""
    }
}

//MARK: - Communication from VC
extension GameScene {
    /// Debug only, use to reset the board easily
    private func reset() {
        board = Board.build(size: boardSize!)
        spriteNodes = createAndPositionSprites(from: board!.tiles)
        foreground.removeAllChildren()
        addSpriteTilesToScene()
    }
}

