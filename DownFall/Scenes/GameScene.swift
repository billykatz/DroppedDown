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
    
    private var tileSize = 75
    private var boardSize: Int?
    private var board: Board?
    private var spriteNodes: [[DFTileSpriteNode]]?
    
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

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparationg necessary for didMove(to:) to be called
    public func commonInit(boardSize bsize: Int){
        //TODO: the  order of the following lines of code matter.  (bottom left has to happen before create and position. Consider refactoring
        board = Board.build(size: bsize)
        self.boardSize = bsize
        bottomLeft = (-1 * tileSize/2 * bsize, -1 * tileSize/2 * bsize )
        spriteNodes = createAndPositionSprites(from: self.board!.tiles)
    }
    
    override func didMove(to view: SKView) {
        foreground = self.childNode(withName: "foreground")!
        setting = self.childNode(withName: "setting")!
        rotateRight = self.childNode(withName: "rotateRight")!
        rotateLeft = self.childNode(withName: "rotateLeft")!
        inputQueue = InputQueue(queue: [])
        addSpriteTilesToScene()
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
            board = trans.endBoard
            computeNewBoard(for: trans)
        case .rotateLeft, .rotateRight:
            board = trans.endBoard
            rotate(for: trans)
        }
    }
}


//MARK: - Adding and Calculating Sprite Tiles

extension GameScene {
    
    /// Adds all sprite nodes from the store of [[DFTileSpriteNodes]] to the foreground
    private func addSpriteTilesToScene() {
        spriteNodes?.forEach { $0.forEach { (sprite) in
            if sprite.type == .player {
                let group = SKAction.group([SKAction.wait(forDuration:5), sprite.animatedPlayerAction()])
                let repeatAnimation = SKAction.repeat(group, count: Int.max)
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
                sprites[row].append(DFTileSpriteNode(type: tiles[row][col]))
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
            let boardSize = boardSize else { return }
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
            guard let newRockType = trans.endTileType else { assertionFailure("Transformation of new tile has no nil value for endTileType."); return }
            let (startRow, startCol) = trans.initial.tuple
            let (endRow, endCol) = trans.end.tuple
            
            // create a sprite based on the endTileType injected into this method
            let sprite = DFTileSpriteNode(type: newRockType)
            
            // place the tile at the "start" which is above the visible board
            // the animation will then move them to the correct place in the foreground
            let x = tileSize * boardSize + ( startRow * tileSize ) + bottomLeftX
            let y = tileSize * startCol + bottomLeftY
            sprite.position = CGPoint.init(x: y, y: x)
            
            //add it to the scene
            foreground.addChild(sprite)
            
            //place the sprite in the appropriate place within the sprite storage
            self.spriteNodes?[endRow][endCol] = sprite
            
        }
        
        //animation "shiftDown" transformation
        var count = shiftDown.count
        animate(shiftDown) { [weak self] in
            guard let strongSelf = self,
                let bottomLeft = strongSelf.bottomLeft else { return }
            count -= 1
            if count == 0 {
                // the animations are done
                // we can remove all the children and redraw
                // set out sprites to reflect the new state
                strongSelf.foreground.removeAllChildren()
                
                //TODO: figure out why i cant use addSpriteNodes here
                strongSelf.spriteNodes = spriteNodes
                var x : Int = 0
                var y : Int = 0
                for row in 0..<boardSize {
                    y = row * strongSelf.tileSize + bottomLeft.0
                    for col in 0..<boardSize {
                        x = col * strongSelf.tileSize + bottomLeft.1
                        strongSelf.spriteNodes?[row][col].position = CGPoint.init(x: x, y: y)
                        strongSelf.foreground.addChild(spriteNodes[row][col])
                    }
                }
                strongSelf.checkGameState()
                strongSelf.animating = false
            }
        }
    }
    
    private func rotate(for transformation: Transformation) {
        var animationCount = 0
        guard let trans = transformation.tileTransformation?.first,
            let spriteNodes = createAndPositionSprites(from: transformation.endTiles) else { return }
        animate(trans) { [weak self] in
            guard let strongSelf = self else { return }
            animationCount += 1
            if animationCount == trans.count {
                strongSelf.foreground.removeAllChildren()
                strongSelf.spriteNodes = spriteNodes
                strongSelf.addSpriteTilesToScene()
                strongSelf.checkGameState()
                strongSelf.animating = false
            }
        }
    }
}

//MARK: -  Animation

extension GameScene {
    func animate(_ transformation: [TileTransformation], _ completion: (() -> Void)? = nil) {
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
        var input: Input? = nil
        if setting.contains(touch.location(in: self)) {
            //self.reset()
            print(self.board as Any)
            print(self.debugBoardSprites())
            return
        } else if rotateRight.contains(touch.location(in: self)) {
            input = Input.rotateRight
        } else if rotateLeft.contains(touch.location(in:self)) {
            input = Input.rotateLeft
        } else {
            for index in 0..<spriteNodes!.reduce([],+).count {
                let row = index / boardSize!
                let col = (index - row * boardSize!) % boardSize!
                let tile = spriteNodes![row][col]
                if tile.contains(touch.location(in: self.foreground)), tile.isTappable() {
                    input = Input.touch(TileCoord(row, col))
                    break
                }
            }
        }
        handledTouch = true
        guard let inputReal = input else { return }
        inputQueue.append(inputReal)
    }
}

//MARK: - Game win and Game loss

extension GameScene {
    func checkGameState() {
        if checkWinCondition() {
            //send game win notification
            guard let playerPosition = board?.playerPosition,
                let exitPosition = board?.exitPosition else { return }
            let trans = TileTransformation(playerPosition, exitPosition)
            animate([trans]) { [weak self] in
                guard let strongSelf = self else { return }
                let wait = SKAction.wait(forDuration:0.5)
                let action = SKAction.run { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.gameSceneDelegate?.shouldShowMenu(win: true)
                }
                strongSelf.run(SKAction.sequence([wait,action]))
            }
        } else if !boardHasMoreMoves() {
            let wait = SKAction.wait(forDuration:0.5)
            let action = SKAction.run { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.gameSceneDelegate?.shouldShowMenu(win: false)
            }
            self.run(SKAction.sequence([wait,action]))
        }
    }
    
    private func checkWinCondition() -> Bool {
        guard let playerRow = board?.playerPosition?.x,
            let playerCol = board?.playerPosition?.y,
            let exitRow = board?.exitPosition?.x,
            let exitCol = board?.exitPosition?.y else { return false }
        return playerRow == exitRow + 1 && playerCol == exitCol
    }
    
    func boardHasMoreMoves() -> Bool {
        guard let tiles = board?.tiles,
            let exitPosition = board?.exitPosition,
            let playerPosition = board?.playerPosition else { return false }
        for (i, row) in tiles.enumerated() {
            for (j, _) in row.enumerated() {
                if board?.findNeighbors(i, j)?.count ?? 0 > 2 || board?.valid(neighbor: exitPosition, for: playerPosition) ?? false {
                    return true
                }
            }
        }
        return false
    }
}

extension GameScene {
    func debugBoardSprites() -> String {
        var outs = "\nTop of SpriteNodes"
        for (i, _) in spriteNodes!.enumerated().reversed() {
            outs += "\n"
            for (j, _) in spriteNodes![i].enumerated() {
                outs += "\t\(spriteNodes![i][j].type)"
            }
        }
        outs += "\nbottom of SpriteNodes"
        return outs
    }
}

//MARK: - Communication from VC
extension GameScene {
    //TODO: figure out a way to not expose a reset function publically
    // this should onyl be called the settings button as a debug quick restart
    private func reset() {
        self.board = Board.build(size: boardSize!) // this should likely be triggered by anothing notification
        self.spriteNodes = createAndPositionSprites(from: board!.tiles)
        foreground.removeAllChildren()
        addSpriteTilesToScene()
    }
}
