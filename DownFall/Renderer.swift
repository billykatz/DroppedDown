//
//  Renderer.swift
//  DownFall
//
//  Created by William Katz on 1/27/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit


protocol RendererDelegate {
    func gameWin()
}

class Renderer : SKSpriteNode {
    private let playableRect: CGRect
    private var foreground: SKNode = SKNode()
    private var sprites: [[DFTileSpriteNode]] = []
    private let bottomLeft: CGPoint
    private let boardSize: CGFloat!
    private let tileSize: CGFloat = 125
    
    public var isAnimating = false
    
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
        
        
        super.init(texture: nil, color: .clear, size: CGSize.zero)
    
        
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func add(sprites: [[DFTileSpriteNode]], to foreground: SKNode) -> SKNode {
        for child in foreground.children {
            if child is DFTileSpriteNode {
                child.removeFromParent()
            }
        }
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
    
    private func createSprites(from board: Board) -> [[DFTileSpriteNode]] {
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
    
    
    /// Animate each tileTransformation to display rotation
    func rotate(for transformation: Transformation) {
        guard let trans = transformation.tileTransformation?.first else { return }
        var animationCount = 0
        self.sprites = createSprites(from: transformation.endBoard)
        animate(trans) { [weak self] in
            guard let strongSelf = self else { return }
            animationCount += 1
            if animationCount == trans.count {
                strongSelf.animationsFinished(for: strongSelf.sprites)
                strongSelf.foreground = strongSelf.add(sprites: strongSelf.sprites, to: strongSelf.foreground)
            }
        }
    }
    
    private func animationsFinished(for endBoard: [[DFTileSpriteNode]]) {
        isAnimating = false
    }
    
    func animate(_ transformation: [TileTransformation]?, _ completion: (() -> Void)? = nil) {
        guard let transformation = transformation else { return }
        var childActionDict : [SKNode : SKAction] = [:]
        for transIdx in 0..<transformation.count {
            let trans = transformation[transIdx]
            let outOfBounds: CGFloat = CGFloat(trans.initial.x) >= boardSize ? tileSize * boardSize : 0
            let point = CGPoint.init(x: tileSize * CGFloat(trans.initial.tuple.1) + bottomLeft.x,
                                     y: outOfBounds + tileSize * CGFloat(trans.initial.x) + bottomLeft.y)
            for child in foreground.children {
                if child.contains(point), child is DFTileSpriteNode {
                    let endPoint = CGPoint.init(x: tileSize * CGFloat(trans.end.y) + bottomLeft.x,
                                                y: tileSize * CGFloat(trans.end.x) + bottomLeft.y)
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

extension Renderer {
    
    func computeNewBoard(for transformation: Transformation) {
        guard let transformations = transformation.tileTransformation else {
            isAnimating = false
            return
        }
        let spriteNodes = createSprites(from: transformation.endBoard)
        //TODO: don't hardcode this
        let removed = transformations[0]
        let newTiles = transformations[1]
        let shiftDown = transformations[2]
        
        //remove "removed" tiles from sprite storage
        for tileTrans in removed {
            sprites[tileTrans.end.x][tileTrans.end.y].removeFromParent()
        }
        
        
        //add new tiles "newTiles"
        for trans in newTiles {
            let (startRow, startCol) = trans.initial.tuple
            let (endRow, endCol) = trans.end.tuple
            
            // get sprite from the target sprites row and col
            let sprite = spriteNodes[endRow][endCol]
            
            // place the tile at the "start" which is above the visible board
            // the animation will then move them to the correct place in the foreground
            let x = tileSize * boardSize + ( CGFloat(startRow) * tileSize ) + bottomLeft.x
            let y = tileSize * CGFloat(startCol) + bottomLeft.y
            sprite.position = CGPoint.init(x: y, y: x)
            
            //add it to the scene
            self.foreground.addChild(spriteNodes[endRow][endCol])
        }
        
        //animation "shiftDown" transformation
        var count = shiftDown.count
        animate(shiftDown) { [weak self] in
            guard let strongSelf = self else { return }
            count -= 1
            if count == 0 {
                strongSelf.animationsFinished(for: spriteNodes)
                strongSelf.sprites = spriteNodes
                
                //TODO: Figure out why we need the following line of code.  this will solve the bug that the player sprite reanimates on every remove and refill
                strongSelf.foreground = strongSelf.add(sprites: strongSelf.sprites, to: strongSelf.foreground)
            }
        }
    }
    
    func compare(_ a: [[DFTileSpriteNode]], _ b: [[DFTileSpriteNode]]) {
        var output = ""
        for (ridx, _) in a.enumerated() {
            for (cidx, _) in a[ridx].enumerated() {
                if a[ridx][cidx].type !=  b[ridx][cidx].type {
                    output += "\n-----\nRow \(ridx), Col \(cidx) are different.\nBefore is \(a[ridx][cidx].type) \nAfter is \(b[ridx][cidx].type)"
                }
            }
        }
        if output == "" { output = "\n-----\nThere are no differences" }
        print(output)
    }
}


extension Renderer {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let positionInScene = touch.location(in: self.foreground)
        let nodes = self.foreground.nodes(at: positionInScene)
        
        for node in nodes {
            if node.name == "rotateRight" {
                //want to append to Input queue
                InputQueue.append(.rotateRight)
            }
            
            if node.name == "rotateLeft" {
                //want to append to Input queue
                InputQueue.append(.rotateLeft)
            }
            
            if node is DFTileSpriteNode {
                for index in 0..<sprites.reduce([],+).count {
                    let boardSize = Int(self.boardSize)
                    let row = index / boardSize
                    let col = (index - row * boardSize) % boardSize
                    if sprites[row][col].contains(positionInScene) {
                        InputQueue.append(.touch(TileCoord(row, col)))
                    }
                }
            }
        }
    }
}

extension Renderer {
    func gameWin() {
        let menu = MenuSpriteNode(playableRect: playableRect)
        menu.zPosition = 10
        foreground.addChild(menu)
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
    
    func debugBoardSprites() -> String {
        var outs = "\nTop of Sprites"
        for (i, _) in sprites.enumerated().reversed() {
            outs += "\n"
            for (j, _) in sprites[i].enumerated() {
                outs += "\t\(sprites[i][j].type)"
            }
        }
        outs += "\nbottom of Sprites"
        return outs
    }
}
