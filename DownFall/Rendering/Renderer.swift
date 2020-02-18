//
//  Renderer.swift
//  DownFall
//
//  Created by William Katz on 1/27/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

class Renderer: SKSpriteNode {
    private let playableRect: CGRect
    private let foreground: SKNode
    private var sprites: [[DFTileSpriteNode]] = []
    private let bottomLeft: CGPoint
    private let boardSize: CGFloat!
    private var tileSize: CGFloat
    private let precedence: Precedence
    
    // Used to determine what special UI consdierations to make for what level we are on
    private let level: Level
    
    private var spriteForeground = SKNode()
    private var menuForeground = SKNode()
    
    //Animator
    private let animator = Animator()
    
    private lazy var menuSpriteNode: MenuSpriteNode = {
        return MenuSpriteNode(.pause, playableRect: self.playableRect, precedence: .menu, level: self.level)
    }()
    
    private lazy var gameWinSpriteNode: MenuSpriteNode = {
        return MenuSpriteNode(.gameWin, playableRect: self.playableRect, precedence: .menu, level: self.level)
    }()
    
    private lazy var gameLoseSpriteNode: MenuSpriteNode = {
        return MenuSpriteNode(.gameLose, playableRect: self.playableRect, precedence: .menu, level: self.level)
    }()
    
    private lazy var rotateSprite: MenuSpriteNode = {
        return MenuSpriteNode(.rotate, playableRect: self.playableRect, precedence: .menu, level: self.level)
    }()
    
    private lazy var tutorial1WinSprite: MenuSpriteNode = {
        return MenuSpriteNode(.tutorial1Win, playableRect: self.playableRect, precedence: .menu, level: self.level)
    }()
    
    private lazy var tutorial2WinSprite: MenuSpriteNode = {
        return MenuSpriteNode(.tutorial2Win, playableRect: self.playableRect, precedence: .menu, level: self.level)
    }()

    
    private var header  = Header()
    private var hud = HUD()
    private var helperTextView = HelperTextView()
    public var backpackView: BackpackView
    
    init(playableRect: CGRect,
         foreground givenForeground: SKNode,
         boardSize theBoardSize: Int,
         precedence: Precedence,
         level: Level) {
        
        self.precedence = precedence
        self.playableRect = playableRect
        self.boardSize = CGFloat(theBoardSize)
        self.level = level
        
        self.tileSize = GameScope.boardSizeCoefficient * (playableRect.width / boardSize)
        
        //center the board in the playable rect
        let marginWidth = playableRect.width - CGFloat(tileSize * boardSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * boardSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        self.bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        foreground = givenForeground
        
        self.backpackView = BackpackView(playableRect: playableRect, viewModel: TargetingViewModel(), levelSize: level.boardSize)

        
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        
        
        self.backpackView.touchDelegate = self
        self.isUserInteractionEnabled = true

        foreground.position = playableRect.center
        menuForeground.position = playableRect.center
        
//        // add settings button to board
//        header = Header.build(color: .black,
//                              size: CGSize(width: playableRect.width, height: Style.Header.height),
//                              precedence: precedence,
//                              delegate: self)
//        header.position = CGPoint.position(header.frame, centeredInTopOf: playableRect)
//        header.zPosition = precedence.rawValue
        
        //create safe area
        let safeArea = SKSpriteNode.init(color: .foregroundBlue, size: CGSize(width: playableRect.width, height: 75.0))
        safeArea.position = CGPoint.position(safeArea.frame, centeredInTopOf: playableRect)
        
        //create the hud
        hud = HUD.build(color: .foregroundBlue, size: CGSize(width: playableRect.width, height: Style.HUD.height), delegate: self)
        hud.position = CGPoint.alignHorizontally(hud.frame, relativeTo: safeArea.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        hud.zPosition = Precedence.foreground.rawValue
        
        //create the helper text view
//        helperTextView = HelperTextView.build(color: UIColor.clayRed, size: CGSize(width: playableRect.width * 0.8, height: 400))
//        helperTextView.position = CGPoint.position(this: helperTextView.frame, centeredInBottomOf: playableRect)
        

        [spriteForeground, safeArea, hud, self.backpackView].forEach { foreground.addChild($0) }
        
        // Register for Dispatch
        Dispatch.shared.register { [weak self] input in
            switch input.type {
            case .transformation(let trans):
                self?.renderTransformation(trans)
            case .boardBuilt:
                guard let self = self,
                    let tiles = input.endTilesStruct else { return }
                self.sprites = self.createSprites(from: tiles)
                self.add(sprites: self.sprites, tiles: tiles)

            default:
                self?.renderInput(input)
            }
        }
    }
    
    private func renderTransformation(_ transformations: [Transformation]) {
        
        if let trans = transformations.first, let inputType = trans.inputType {
            switch inputType {
            case .rotateCounterClockwise, .rotateClockwise:
                rotate(for: transformations)
            case .touch:
                //TODO: sometimes remove and replace has a monster for the touch(_, type).  not sure why
                if let _ = trans.tileTransformation {
                    computeNewBoard(for: trans)
                } else {
                    animationsFinished(for: sprites,
                                       endTiles: trans.endTiles,
                                       ref: false)
                }
            case .attack:
                animateAttack(attackInput: inputType, endTiles: trans.endTiles)
            case .gameWin:
                animate(trans.tileTransformation?.first) { [weak self] in
                    self?.gameWin(transformation: trans)
                }
            case .monsterDies:
                let sprites = createSprites(from: trans.endTiles)
                animationsFinished(for: sprites, endTiles: trans.endTiles)
            case .itemUsed:
                let sprites = createSprites(from: trans.endTiles)
                animationsFinished(for: sprites, endTiles: trans.endTiles)
            case .collectItem:
                computeNewBoard(for: trans)
            case .reffingFinished:
                () // Purposely left blank.
            case .touchBegan, .itemUseSelected:
                ()
            case .newTurn:
                let sprites = createSprites(from: trans.endTiles)
                animationsFinished(for: sprites, endTiles: trans.endTiles, ref: false)
            default:
                // Transformation assoc value should ony exist for certain inputs
                fatalError()
            }
        } else {
            animationsFinished(for: sprites, endTiles: transformations.first?.endTiles)
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
            menuForeground.addChildSafely(menuSpriteNode)
        case .gameLose:
            menuForeground.addChild(gameLoseSpriteNode)
            foreground.addChildSafely(menuForeground)
        case .playAgain:
            menuForeground.removeFromParent()
        case .tutorial(let step):
            renderTutorial(step)
        case .newTurn:
            let sprites = createSprites(from: input.endTilesStruct)
            animationsFinished(for: sprites, endTiles: input.endTilesStruct, ref: false)
        case .touch, .rotateCounterClockwise, .rotateClockwise,
             .monsterDies, .attack, .gameWin,
             .animationsFinished, .reffingFinished,
             .boardBuilt,. collectItem, .selectLevel, .transformation, .touchBegan,
             .visitStore, .itemUseSelected, .itemUseCanceled, .itemCanBeUsed, .itemUsed:
            ()
        }
    }
    
    private func renderTutorial(_ step: TutorialStep) {
        let types = step.highlightType
        let coords = step.highlightCoordinates
        let showFinger = step.showFingerWithHighlight
        for (row, spriteRow) in sprites.enumerated() {
            for (col, _) in spriteRow.enumerated() {
                let sprite = sprites[row][col]
                sprite.removeAllChildren()
                if types.contains(sprite.type) {
                    sprite.tutorialHighlight()
                    if showFinger {
                        sprite.showFinger()
                    }
                }
                
                if coords.contains(TileCoord(row, col)) {
                    sprite.indicateSpriteWillBeAttacked()
                }
            }
        }
        
        if step.showClockwiseRotate {
            menuForeground.addChildSafely(rotateSprite)
            foreground.addChildSafely(menuForeground)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateAttack(attackInput: InputType, endTiles: [[Tile]]?) {
        guard let tiles = endTiles else {
            animationsFinished(for: sprites, endTiles: endTiles)
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
    
    private func add(sprites: [[DFTileSpriteNode]], tiles: [[Tile]]) {
        spriteForeground.removeAllChildren()
        for (row, innerSprites) in sprites.enumerated() {
            for (col, sprite) in innerSprites.enumerated() {
                if tiles[row][col].shouldHighlight {
                    sprite.indicateSpriteWillBeAttacked()
                } else if let turns = tiles[row][col].type.turnsUntilAttack(),
                    let frequency = tiles[row][col].type.attackFrequency() {
                    sprite.showAttackTiming(frequency, turns)
                }
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
    
    private func createSprites(from tiles: [[Tile]]?) -> [[DFTileSpriteNode]] {
        guard let tiles = tiles else { preconditionFailure() }
        guard tiles.count == Int(boardSize) else { fatalError("For now, the board must be a square, and the boardSize must match the tiles.count") }
        var x : CGFloat = 0
        var y : CGFloat = 0
        var sprites: [[DFTileSpriteNode]] = []
        for row in 0..<Int(boardSize) {
            y = CGFloat(row) * tileSize + bottomLeft.y
            sprites.append([])
            for col in 0..<Int(boardSize) {
                x = CGFloat(col) * tileSize + bottomLeft.x
                let isPlayer = tiles[row][col].type == TileType.player(.zero)
                let height: CGFloat = isPlayer ? 160 : tileSize
                let width: CGFloat = isPlayer ? 80 : tileSize
                let sprite = DFTileSpriteNode(type: tiles[row][col].type,
                                              height: height,
                                              width: width)
                sprites[row].append(sprite)
                sprites[row][col].position = CGPoint(x: x, y: y)
            }
        }
        return sprites
    }

    /// Animate each tileTransformation to display rotation
    private func rotate(for transformations: [Transformation]) {
        guard let rotateTrans = transformations.first,
            let trans = transformations.first?.tileTransformation?.first,
            let rotateEndTiles = rotateTrans.endTiles else { return }
        
        guard transformations.count > 1 else {
            var animationCount = 0
            animate(trans) { [weak self] in
                guard let strongSelf = self else { return }
                animationCount += 1
                if animationCount == trans.count {
                    strongSelf.animationsFinished(for: strongSelf.sprites, endTiles: rotateEndTiles)
                }
            }
            return
        }
        
        if transformations.count > 1,
            let newTiles = transformations[1].tileTransformation?[0],
            let shiftDown = transformations[1].tileTransformation?[1],
            let finalTiles = transformations[1].endTiles
        {
            
            var animationCount = 0
            animate(trans) { [weak self] in
                guard let strongSelf = self else { return }
                animationCount += 1
                if animationCount == trans.count {
                    
                    // finish the rotate transformation
                    let spriteNodes = strongSelf.createSprites(from: rotateEndTiles)
                    strongSelf.sprites = spriteNodes
                    strongSelf.add(sprites: spriteNodes, tiles: rotateEndTiles)
                    
                    
                    // START THE SHIFT DOWN ANIMATION
                    
                    //add new tiles "newTiles"
                    for trans in newTiles {
                        let (startRow, startCol) = trans.initial.tuple
                        let (endRow, endCol) = trans.end.tuple
                        
                        // get sprite from the target sprites row and col
                        let sprite = spriteNodes[endRow][endCol]
                        
                        // place the tile at the "start" which is above the visible board
                        // the animation will then move them to the correct place in the foreground
                        let x = strongSelf.tileSize * strongSelf.boardSize + ( CGFloat(startRow) * strongSelf.tileSize ) + strongSelf.bottomLeft.x
                        let y = strongSelf.tileSize * CGFloat(startCol) + strongSelf.bottomLeft.y
                        sprite.position = CGPoint.init(x: y, y: x)
                        
                    }
                    
                    
                    /// map the shift down tile transformation array to [SKSpriteNode, SKAction)] to work Animator world
                    var shiftDownActions: [(SKSpriteNode, SKAction)] = []
                    for trans in shiftDown {

                        let (startRow, startCol) = trans.initial.tuple
                        let (endRow, endCol) = trans.end.tuple
                        let sprite: SKSpriteNode
                        if trans.initial.row >= Int(strongSelf.boardSize) {
                            // startRow may be out of bounds because we temprarily place the tile above the board to visually allow it to drop down.  In that case, use the end row to access the actualy sprite from storage
                            sprite = spriteNodes[endRow][endCol]
                        } else {
                            //sprite already exist in the board. so access it by it's start row
                            sprite = spriteNodes[startRow][startCol]
                        }

                        //create the action
                        let endPoint = CGPoint.init(x: strongSelf.tileSize * CGFloat(trans.end.column) + strongSelf.bottomLeft.x,
                                                    y: strongSelf.tileSize * CGFloat(trans.end.row) + strongSelf.bottomLeft.y)
                        let animation = SKAction.move(to: endPoint, duration: AnimationSettings.fallSpeed)
                        shiftDownActions.append((sprite, SKAction.sequence([animation])))
                    }

                    strongSelf.animator.animate(shiftDownActions) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.animationsFinished(for: spriteNodes, endTiles: finalTiles)
                    }
                }
            }
        }
    }
    
    private func animationsFinished(for endBoard: [[DFTileSpriteNode]],
                                    endTiles: [[Tile]]?,
                                    ref: Bool = true) {
        guard let endTiles = endTiles else { preconditionFailure("why dont we have end tiles at this point") }
        sprites = createSprites(from: endTiles)
        add(sprites: sprites, tiles: endTiles)
        InputQueue.append(Input(.animationsFinished(ref: ref), endTiles))
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
        guard let endTiles = transformation?.endTiles else {
            fatalError("We should always be passing through end tiles")
        }
        
        guard let transformation = transformation,
            let transformations = transformation.tileTransformation,
            let inputType = transformation.inputType else {
            animationsFinished(for: sprites, endTiles: endTiles)
            return
        }
        
        let spriteNodes = createSprites(from: endTiles)
        //TODO: don't hardcode this
        let removed = transformations[0]
        let newTiles = transformations[1]
        let shiftDown = transformations[2]
        
        //remove "removed" tiles from sprite storage
        var removedAnimations: [(SKSpriteNode, SKAction)] = []
        for tileTrans in removed {
            if let crumble = sprites[tileTrans.end.x][tileTrans.end.y].crumble() {
                // set the position way in the background so that new nodes come in over
                sprites[tileTrans.end.x][tileTrans.end.y].zPosition = Precedence.underground.rawValue
                removedAnimations.append(crumble)
            }
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
        
        /// map the shift down tile transformation array to [SKSpriteNode, SKAction)] to work Animator world
        
        var shiftDownActions: [(SKSpriteNode, SKAction)] = []
        for trans in shiftDown {
            
            let (startRow, startCol) = trans.initial.tuple
            let (endRow, endCol) = trans.end.tuple
            let sprite: SKSpriteNode
            if trans.initial.row >= Int(boardSize) {
                sprite = spriteNodes[endRow][endCol]
            } else {
                sprite = sprites[startRow][startCol]
            }
            
            //create the action
            let endPoint = CGPoint.init(x: tileSize * CGFloat(trans.end.column) + bottomLeft.x,
                                        y: tileSize * CGFloat(trans.end.row) + bottomLeft.y)
            let animation = SKAction.move(to: endPoint, duration: AnimationSettings.fallSpeed)
            let wait = SKAction.wait(forDuration: 0.25)
            shiftDownActions.append((sprite, SKAction.sequence([wait, animation])))
        }
        
        if case let InputType.collectItem(coord, _, amount) = inputType {
            // add a bunch of gold sprites to the board
            if let startPoint = positionsInForeground(at: [coord]).first {
                var goldSprites: [SKSpriteNode] = []
                for _ in 0..<amount {
                    let goldSprite = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gold),
                                                  color: .clear,
                                                  size: Style.Board.goldGainSize)
                    goldSprite.position = startPoint
                    spriteForeground.addChild(goldSprite)
                    goldSprites.append(goldSprite)
                }
                let endPosition = CGPoint.alignHorizontally(goldSprites.first?.frame, relativeTo: self.hud.frame, horizontalAnchor: .left, verticalAlign: .top, translatedToBounds: true)
                animator.animateGold(goldSprites: goldSprites, gained: amount, from: startPoint, to: endPosition)
            }
            
            
        }
        
        
        // animate the removal of rocks and rocks falling at the same time
        // they are quasi-sequenced because the faling rocks wait x seconds before falling
        // TODO: figure out if there is a better way to sequence animations
        // For example, it would be nice to say "start this animation at a certain key frame/progress of another animation"
        removedAnimations.append(contentsOf: shiftDownActions)
        animator.animate(removedAnimations) {  [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.animationsFinished(for: strongSelf.sprites, endTiles: endTiles)
        }
        
    }
    
}


extension Renderer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
                            Input(.touchBegan(TileCoord(row, col),
                                              sprites[row][col].type))
                        )
                    }
                }
            }
        }
    }
    
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
                        // create the new til coord
                        let newTileCoord = TileCoord(row, col)
                        
                        // Check to see if where out touch ends is where it began
                        guard let lastTouchInput = InputQueue.lastTouchInput(),
                            case let InputType.touchBegan(lastTileCoord, _) = lastTouchInput.type,
                            newTileCoord == lastTileCoord else { return }
                        
                        //special case for tutorial
                        if level.type != .tutorial2 {
                            InputQueue.append(
                                Input(.touch(TileCoord(row, col),
                                             sprites[row][col].type))
                            )
                        } else if level.type == .tutorial2, let data = level.tutorialData {
                            if InputType.fuzzyEqual(data.currentStep.inputToContinue,
                                                    .touch(TileCoord(row, col), sprites[row][col].type)) {
                                InputQueue.append(
                                    Input(.touch(TileCoord(row, col),
                                                 sprites[row][col].type))
                                )
                            }
                                
                                // the following logic is specific to the tutorial at hand.
                                // if we want to constrain where a user can click, then we need to
                                // understand where and when they are clicking
                                // where on the board
                                // and when in the tutorial
                            else if InputType.fuzzyEqual(data.currentStep.inputToContinue,
                                                         .monsterDies(.zero)) {
                                InputQueue.append(
                                    Input(.touch(TileCoord(row, col),
                                                 sprites[row][col].type))
                                )
                            }
    
                        }
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
    private func gameWin(transformation: Transformation?) {
        animator.gameWin(transformation: transformation, sprites: sprites) { [weak self] in
    
            guard let strongSelf = self else { return }
            strongSelf.menuForeground.removeAllChildren()
            let gameWinMenu: SKSpriteNode
            switch strongSelf.level.type {
            case .first, .second, .third, .boss:
                //TODO: program the boss win sprite
                gameWinMenu = strongSelf.gameWinSpriteNode
            case .tutorial1:
                gameWinMenu = strongSelf.tutorial1WinSprite
            case .tutorial2:
                gameWinMenu = strongSelf.tutorial2WinSprite
            }
            strongSelf.menuForeground.addChild(gameWinMenu)
            strongSelf.menuForeground.removeFromParent()
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

extension Renderer: SettingsDelegate {
    func settingsTapped() {
        InputQueue.append(Input(.pause))
    }
}
