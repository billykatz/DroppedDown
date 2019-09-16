//
//  Renderer.swift
//  DownFall
//
//  Created by William Katz on 1/27/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

class Renderer : SKSpriteNode {
    private let playableRect: CGRect
    private let foreground: SKNode
    private var sprites: [[DFTileSpriteNode]] = []
    private let bottomLeft: CGPoint
    private let boardSize: CGFloat!
    private let tileSize: CGFloat = 100
    private let precedence: Precedence
    
    private var spriteForeground = SKNode()
    private var menuForeground = SKNode()
    
    //Animator
    private let animator = Animator()
    
    private var menuSpriteNode: MenuSpriteNode {
        return MenuSpriteNode(.pause, playableRect: playableRect, precedence: .menu)
    }
    
    private var gameWinSpriteNode: MenuSpriteNode {
        return MenuSpriteNode(.gameWin, playableRect: playableRect, precedence: .menu)
    }
    
    private var header  = Header()
    private var hud = HUD()
    private var helperTextView = HelperTextView()
    
    init(playableRect: CGRect,
         foreground givenForeground: SKNode,
         board: Board,
         precedence: Precedence) {
        
        self.precedence = precedence
        self.playableRect = playableRect
        self.boardSize = CGFloat(board.boardSize)
        
        //center the board in the playable rect
        let marginWidth = playableRect.width - CGFloat(tileSize * boardSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * boardSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        self.bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        foreground = givenForeground
        
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        
        isUserInteractionEnabled = true

        //create sprite representations based on the given board.tiles
        self.sprites = createSprites(from: board.tiles)
        //place the created sprites onto the foreground
        let _ = add(sprites: sprites)
        foreground.position = playableRect.center
        menuForeground.position = playableRect.center
        menuForeground.addChild(menuSpriteNode)
        
        // add settings button to board
        header = Header.build(color: .black,
                              size: CGSize(width: playableRect.width, height: 200.0),
                              precedence: precedence)
        header.position = CGPoint(x: playableRect.midX, y: playableRect.maxY - 100.0)
        header.zPosition = precedence.rawValue
        
        // add left and right rotate button to board
        let controls = Controls.build(color: .black,
                                      size: CGSize(width: playableRect.width, height: 400.0),
                                      precedence: precedence)
        controls.position = CGPoint(x: playableRect.midX, y: playableRect.minY + 100.0)
        controls.isUserInteractionEnabled = true
        controls.zPosition = precedence.rawValue
        
        //create the hud
        hud = HUD.build(color: .lightGray, size: CGSize(width: playableRect.width * 0.9, height: 150))
        hud.position = CGPoint(x: playableRect.midX, y: playableRect.minY + controls.size.height + 16)
        
        //create the helper text view
        helperTextView = HelperTextView.build(color: UIColor(rgb: 0x9c461f), size: CGSize(width: playableRect.width * 0.9, height: 200))
        helperTextView.position = CGPoint(x: playableRect.midX, y: playableRect.maxY - header.size.height - 116)
        

        [spriteForeground, header, controls, hud, helperTextView].forEach { foreground.addChild($0) }
        
        // Register for Dispatch
        Dispatch.shared.register { [weak self] input in
            switch input.type{
            case .transformation(let trans):
                self?.renderTransformation(trans)
            default:
                self?.renderInput(input)
            }
        }
    }
    
    private func renderTransformation(_ trans: Transformation) {
        if let inputType = trans.inputType {
            switch inputType {
            case .rotateLeft, .rotateRight:
                rotate(for: trans)
            case .touch:
                computeNewBoard(for: trans)
            case .attack:
                animateAttack(attackInput: inputType, endTiles: trans.endTiles)
            case .gameWin:
                animate(trans.tileTransformation?.first) { [weak self] in
                    self?.gameWin()
                }
            case .monsterDies:
                let sprites = createSprites(from: trans.endTiles)
                animationsFinished(for: sprites, endTiles: trans.endTiles)
            case .collectItem:
                computeNewBoard(for: trans)
            case .reffingFinished:
                () // Purposely left blank.
            default:
                // Transformation assoc value should ony exist for certain inputs
                fatalError()
            }
        } else {
            animationsFinished(for: sprites, endTiles: trans.endTiles)
        }

    }
    
    private func renderInput(_ input: Input) {
        switch input.type {
        case .play:
            // remove the menu
            menuForeground.removeFromParent()
        case .pause:
            // show the menu
            foreground.addChild(menuForeground)
        case .gameLose:
            gameWin()
        case .playAgain:
            menuForeground.removeFromParent()
        case .touch(_, _), .rotateLeft, .rotateRight,
             .monsterDies, .attack, .gameWin,
             .animationsFinished, .reffingFinished,
             .boardBuilt,. collectItem, .selectLevel,
             .newTurn, .transformation:
            ()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateAttack(attackInput: InputType, endTiles: [[TileType]]?) {
        guard let tiles = endTiles else {
            animationsFinished(for: sprites)
            return
        }
        
        animator.animate(attackInputType: attackInput,
                         foreground: foreground,
                         tiles: tiles,
                         sprites: sprites,
                         positions: positionsInForeground) { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.animationsFinished(for: strongSelf.sprites, endTiles: tiles)
        }
        
    }
    
    private func add(sprites: [[DFTileSpriteNode]]) {
        spriteForeground.removeAllChildren()
        sprites.forEach { spriteRow in
            spriteRow.forEach { sprite in
                spriteForeground.addChild(sprite)
            }
        }
    }
    
    private func positionsInForeground(at coords: [TileCoord]) -> [CGPoint] {
        var x : CGFloat = 0
        var y : CGFloat = 0
        var points: [CGPoint] = []
        for coordinate in coords {
            x = CGFloat(coordinate.y) * tileSize + bottomLeft.x
            y = CGFloat(coordinate.x) * tileSize + bottomLeft.y
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
    
    private func createSprites(from tiles: [[TileType]]?) -> [[DFTileSpriteNode]] {
        guard let tiles = tiles else { fatalError() }
        var x : CGFloat = 0
        var y : CGFloat = 0
        var sprites: [[DFTileSpriteNode]] = []
        for row in 0..<Int(boardSize) {
            y = CGFloat(row) * tileSize + bottomLeft.y
            sprites.append([])
            for col in 0..<Int(boardSize) {
                x = CGFloat(col) * tileSize + bottomLeft.x
                if tiles[row][col] == TileType.player(.zero) {
                    //TODO: Don't hardcode height and width
                    sprites[row].append(DFTileSpriteNode(type: tiles[row][col], height: 160, width: 80))
                } else {
                    sprites[row].append(DFTileSpriteNode(type: tiles[row][col], size: CGFloat(tileSize)))
                }
                sprites[row][col].position = CGPoint(x: x, y: y)
            }
        }
        return sprites
    }
    
    /// Animate each tileTransformation to display rotation
    private func rotate(for transformation: Transformation?) {
        guard let transformation = transformation,
            let trans = transformation.tileTransformation?.first,
            let endTiles = transformation.endTiles else { return }
        var animationCount = 0
        animate(trans) { [weak self] in
            guard let strongSelf = self else { return }
            animationCount += 1
            if animationCount == trans.count {
                strongSelf.animationsFinished(for: strongSelf.sprites, endTiles: endTiles)
            }
        }
    }
    
    private func animationsFinished(for endBoard: [[DFTileSpriteNode]], endTiles: [[TileType]]? = nil) {
        sprites = createSprites(from: endTiles)
        let _ = add(sprites: sprites)
        InputQueue.append(Input(.animationsFinished, endTiles))
    }
    
    private func animate(_ transformation: [TileTransformation]?, _ completion: (() -> Void)?) {
        animator.animate(transformation,
                         boardSize: boardSize,
                         bottomLeft: bottomLeft,
                         spriteForeground: spriteForeground,
                         tileSize: tileSize,
                         completion)
    }

}

extension Renderer {
    
    private func computeNewBoard(for transformation: Transformation?) {
        guard let transformation = transformation,
            let transformations = transformation.tileTransformation,
            let endTiles = transformation.endTiles else {
                InputQueue.append(Input(.animationsFinished))
            return
        }
        let spriteNodes = createSprites(from: endTiles)
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
            spriteForeground.addChild(spriteNodes[endRow][endCol])
        }
        
        //animation "shiftDown" transformation
        var count = shiftDown.count
        animate(shiftDown) { [weak self] in
            guard let strongSelf = self else { return }
            count -= 1
            if count == 0 {
                strongSelf.animationsFinished(for: strongSelf.sprites, endTiles: endTiles)
            }
        }
    }
    
}


extension Renderer {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let positionInScene = touch.location(in: self.foreground)
        let nodes = foreground.nodes(at: positionInScene)

        for node in nodes {
            if node is DFTileSpriteNode {
                for index in 0..<sprites.reduce([],+).count {
                    let boardSize = Int(self.boardSize)
                    let row = index / boardSize
                    let col = (index - row * boardSize) % boardSize
                    if sprites[row][col].contains(positionInScene) {
                        InputQueue.append(
                            Input(.touch(TileCoord(row, col),
                                         sprites[row][col].type))
                        )
                    }
                }
            }
            
            if node.name == "setting" {
                header.touchesEnded(touches, with: event)
            }
        }
    }
}

extension Renderer {
    private func gameWin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.menuForeground.removeAllChildren()
            strongSelf.menuForeground.addChild(strongSelf.gameWinSpriteNode)
            strongSelf.foreground.addChild(strongSelf.menuForeground)
        }
    }
}

//MARK: Debug

extension Renderer {
    
    private func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        shape.zPosition = precedence.rawValue
        foreground.addChild(shape)
    }
    
    private func debugBoardSprites() -> String {
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
    
    private func compare(_ a: [[DFTileSpriteNode]], _ b: [[DFTileSpriteNode]]) {
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
