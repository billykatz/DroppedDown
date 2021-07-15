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
    
    // View for TileDetail
    private var tileDetailView: TileDetailView?
    
    private var spriteForeground = SKNode()
    private var menuForeground = SKNode()
    
    //Animator
    private let animator = Animator()
    
    func debugMenu() -> MenuSpriteNode {
        return MenuSpriteNode(.debug, playableRect: self.playableRect, precedence: .menu, level: self.level)
    }
    
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
    
    private lazy var safeArea: SKSpriteNode = {
        //create safe area
        let safeArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: 75.0))
        safeArea.position = CGPoint.position(safeArea.frame, centeredInTopOf: playableRect)
        return safeArea
    }()
    
    private lazy var hud: HUD = {
        let hud = HUD.build(color: .foregroundBlue,
                            size: CGSize(width: playableRect.width/2,
                                         height: Style.HUD.height),
                            delegate: self, level: level)
        hud.position = CGPoint.alignHorizontally(hud.frame,
                                                 relativeTo: safeArea.frame,
                                                 horizontalAnchor: .right,
                                                 verticalAlign: .bottom,
                                                 translatedToBounds: true)
        hud.zPosition = Precedence.flying.rawValue
        return hud
    }()
    
    private var levelGoalTracker: LevelGoalTracker
    private lazy var levelGoalView: LevelGoalView = {
        let levelGoalView = LevelGoalView(viewModel: levelGoalTracker,
                                          size: CGSize(width: playableRect.width/2,
                                                       height: Style.LevelGoalView.height))
        levelGoalView.position = CGPoint.alignHorizontally(levelGoalView.frame,
                                                           relativeTo: safeArea.frame,
                                                           horizontalAnchor: .left,
                                                           verticalAlign: .bottom,
                                                           horizontalPadding: Style.Padding.more*2,
                                                           translatedToBounds: true)
        levelGoalView.zPosition = Precedence.flying.rawValue
        return levelGoalView
    }()
    
    public var backpackView: BackpackView
    
    init(playableRect: CGRect,
         foreground givenForeground: SKNode,
         boardSize theBoardSize: Int,
         precedence: Precedence,
         level: Level,
         levelGoalTracker: LevelGoalTracker) {
        
        self.precedence = precedence
        self.playableRect = playableRect
        self.boardSize = CGFloat(theBoardSize)
        self.level = level
        self.levelGoalTracker = levelGoalTracker
        
        self.tileSize = GameScope.boardSizeCoefficient * (playableRect.width / boardSize)
        
        //center the board in the playable rect
        let marginWidth = playableRect.width - CGFloat(tileSize * boardSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * boardSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        self.bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        foreground = givenForeground
        
        
        // backpack view
        self.backpackView = BackpackView(playableRect: playableRect,
                                         viewModel: TargetingViewModel(),
                                         levelSize: level.boardSize)
        
        
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        
        let testBackground = SKSpriteNode(texture: SKTexture(imageNamed: "test-background"), size: CGSize(width: playableRect.size.width, height: playableRect.size.width*2.1))
        testBackground.position = CGPoint.alignHorizontally(testBackground.frame,
                                                            relativeTo: safeArea.frame,
                                                            horizontalAnchor: .right,
                                                            verticalAlign: .bottom,
                                                            translatedToBounds: true)
        testBackground.zPosition = 0
        foreground.addChild(testBackground)
        
        // tile detail view
        self.tileDetailView = TileDetailView(foreground: foreground, playableRect: playableRect, alignedTo: hud.frame, levelSize: level.boardSize)
        tileDetailView?.zPosition = Precedence.flying.rawValue
        
        self.isUserInteractionEnabled = true
        
        foreground.position = playableRect.center
        menuForeground.position = playableRect.center
        
        [spriteForeground, safeArea, hud, levelGoalView, backpackView].forEach { foreground.addChild($0) }
        
        // Register for Dispatch
        Dispatch.shared.register { [weak self] input in
            switch input.type {
            case .transformation(let trans):
                self?.renderTransformation(trans)
            case .boardBuilt, .boardLoaded:
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
        print("Renderer will render a transformation. \(String(describing: transformations.first?.inputType))")
        if let trans = transformations.first, let inputType = trans.inputType {
            switch inputType {
            case .rotateCounterClockwise(let preview), .rotateClockwise(let preview):
                if !preview {
                    let tileTrans = trans.tileTransformation!
                    var spriteActions: [SpriteAction] = []
                    for tileTran in tileTrans {
                        let position = sprites[tileTran.end.row][tileTran.end.column].position
                        spriteActions.append(SpriteAction(sprite: sprites[tileTran.initial.row][tileTran.initial.column], action: SKAction.move(to: position, duration: AnimationSettings.RotatePreview.finishQuickRotateSpeed)))
                    }
                    animator.animate(spriteActions) { [weak self] in
                        guard let self = self else { return }
                        self.animationsFinished(endTiles: trans.endTiles, ref: true)
                    }
                    
                    return
                }
                rotatePreview(for: transformations)
            case .touch:
                //TODO: sometimes remove and replace has a monster for the touch(_, type).  not sure why
                if trans.newTiles != nil {
                    computeNewBoard(for: trans)
                } else {
                    var sprites: [DFTileSpriteNode] = []
                    if let tiles = trans.tileTransformation {
                        for coord in tiles {
                            sprites.append(self.sprites[coord.initial.row][coord.initial.column])
                        }
                    }
                    animator.animateCannotMineRock(sprites: sprites) { [weak self] in
                        self?.animationsFinished(endTiles: trans.endTiles,
                                           ref: false)
                    }
                }
            case .attack:
                animateAttack(attackInput: inputType, endTiles: trans.endTiles)
            case .gameWin:
                animate(trans.tileTransformation) { [weak self] in
                    self?.gameWin(transformation: trans)
                }
            case .monsterDies:
                computeNewBoard(for: trans)
            case .newTurn:
                animationsFinished(endTiles: trans.endTiles)
            case .unlockExit:
                animationsFinished(endTiles: trans.endTiles)

            case .itemUsed(let ability, let targets):
                animateRuneUsed(input: inputType, transformations: transformations, rune: ability, targets: targets)
            case .collectOffer(let tileCoord, let offer, let discardedCoord, let discardedOffer):
                collectOffer(transformations, offer: offer, atTilecoord: tileCoord, discardOffer: discardedOffer, discardedOfferTileCoord: discardedCoord)
            case .collectItem:
                collectItem(for: trans, inputType: inputType)
            case .decrementDynamites:
                computeNewBoard(for: transformations)
            case .refillEmpty:
                refillEmptyTiles(with: trans)
            case .shuffleBoard:
                computeNewBoard(for: trans)
            case .runeReplaced:
                animationsFinished(endTiles: trans.endTiles)
            case .foundRuneDiscarded:
                computeNewBoard(for: trans)
            case .goalCompleted(let goals, allGoalsCompleted: let allGoalsCompleted):
                var unlockTransformation: Transformation?
                if allGoalsCompleted {
                    unlockTransformation = transformations.last
                }
                animateCompletedGoals(goals, input: inputType, transformation: trans, unlockExitTransformation: unlockTransformation)
            case .rotatePreviewFinish(let spriteActions, let trans):
                /// We ARE rotating
                if let trans = trans {
                    animator.animate(spriteActions) { [weak self] in
                        guard let self = self else { return }
                        self.animationsFinished(endTiles: trans.endTiles, ref: true)
                    }
                }
                /// We ARE NOT Rotating
                else {
                    animator.animate(spriteActions) { [weak self] in
                        guard let self = self else { return }
                        self.animationsFinished(endTiles: trans?.endTiles, ref: false)
                    }
                }
            case .reffingFinished, .touchBegan, .itemUseSelected:
                () // Purposely left blank.

            default:
                // Transformation assoc value should ony exist for certain inputs
                fatalError()
            }
        } else {
            print("No transformation so we are here")
            animationsFinished(endTiles: transformations.first?.endTiles)
        }
        
    }
    
    private func renderInput(_ input: Input) {
        switch input.type {
        case .play:
            // remove the menu
            menuForeground.removeFromParent()
            menuForeground.removeAllChildren()
        case .pause:
            // show the menu
            foreground.addChild(menuForeground)
            menuForeground.addChildSafely(debugMenu())
        case .gameLose:
            menuForeground.addChild(gameLoseSpriteNode)
            foreground.addChildSafely(menuForeground)
        case .playAgain:
            menuForeground.removeFromParent()
        case .newTurn:
            ()
//            animationsFinished(endTiles: input.endTilesStruct, ref: false)
        default:
            ()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateCompletedGoals(_ goals: [GoalTracking], input: InputType, transformation: Transformation, unlockExitTransformation: Transformation?) {
        animator.animateCompletedGoals(goals,
                                       transformation: transformation,
                                       unlockExitTransformation: unlockExitTransformation,
                                       sprites: sprites,
                                       foreground: spriteForeground,
                                       levelGoalOrigin: self.levelGoalView.frame.origin.translate(xOffset: self.levelGoalView.frame.width/2, yOffset: -20.0)
                                       ) { [weak self] in
            self?.animationsFinished(endTiles: unlockExitTransformation?.endTiles ?? transformation.endTiles)
        }
        
    }
    
    private func animateRuneUsed(input: InputType, transformations: [Transformation], rune: Rune, targets: [TileCoord]) {
        animator.animateRune(rune, transformations: transformations, affectedTiles: targets, sprites: sprites, spriteForeground: spriteForeground) { [weak self] in
            self?.animationsFinished(endTiles: transformations.first?.endTiles)
        }
        
    }
    
    private func animateAttack(attackInput: InputType, endTiles: [[Tile]]?) {
        guard let tiles = endTiles else {
            animationsFinished(endTiles: endTiles)
            return
        }
        
        animator.animate(attackInputType: attackInput,
                         foreground: foreground,
                         tiles: tiles,
                         sprites: sprites,
                         positions: positionsInForeground) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.animationsFinished(endTiles: tiles)
        }
        
    }
    
    /// Removes all the sprites in the mine and then readds them based on the input array of Tiles
    private func add(sprites: [[DFTileSpriteNode]], tiles: [[Tile]]) {
        spriteForeground.removeAllChildren()
        for (row, innerSprites) in sprites.enumerated() {
            for (col, sprite) in innerSprites.enumerated() {
                if let turns = tiles[row][col].type.turnsUntilAttack(),
                   let frequency = tiles[row][col].type.attackFrequency() {
                    sprite.showAttackTiming(frequency, turns)
                } else if case let TileType.offer(offer) = tiles[row][col].type {
                    sprite.showOfferTier(offer)
                }
                spriteForeground.addChild(sprite)
            }
        }
    }
    
    private func positionsInForeground(at coords: [TileCoord]) -> [CGPoint] {
        return coords.map { positionInForeground(at: $0) }
    }
    
    private func positionInForeground(at coord: TileCoord) -> CGPoint {
        let x = CGFloat(coord.y) * tileSize + bottomLeft.x
        let y = CGFloat(coord.x) * tileSize + bottomLeft.y
        return CGPoint(x: x, y: y)
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
                
                if let (glow, spin) = sprite.glow() {
                    sprite.addChild(glow)
                    glow.run(spin)
                } else if let sparkle = sprite.sparkle() {
                    sprite.run(sparkle)
                }
            }
        }
        return sprites
    }
    
    /// Attach the sprites to the input so that another object can rotate the board for us
    private func rotatePreview(for transformations: [Transformation]) {
        guard let rotateTrans = transformations.first else {
            preconditionFailure("We should have a transformation")
        }
        InputQueue.append(Input(.rotatePreview(sprites, rotateTrans)))
    }
    
    private func refillEmptyTiles(with transformation: Transformation, completion: (() -> ())? = nil) {
        guard let shiftDown = transformation.shiftDown,
              let finalTiles = transformation.endTiles else {
            preconditionFailure("All these conditions must be met to refill empty tiles")
        }
        
        /// It is possible to create shift down without new tiles. Consider the scenario where there is one column with two pillars with at least one tile separating them. A player could destory the lower pillar and expect the tiles above it to fall down.
        /// [pillar]                  [pillar]
        /// [rock]        ->          [empty]
        /// [pillar]  (destroyed)     [rock]
        let newTiles = transformation.newTiles ?? []
        
        // START THE SHIFT DOWN ANIMATION
        
        //add new tiles "newTiles"
        for trans in newTiles {
            let (startRow, startCol) = trans.initial.tuple
            let (endRow, endCol) = trans.end.tuple
            
            // get sprite from the target sprites row and col
            let sprite = sprites[endRow][endCol]
            
            // place the tile at the "start" which is above the visible board
            // the animation will then move them to the correct place in the foreground
            let x = tileSize * boardSize + ( CGFloat(startRow) * tileSize ) + bottomLeft.x
            let y = tileSize * CGFloat(startCol) + bottomLeft.y
            sprite.position = CGPoint.init(x: y, y: x)
            
        }
        
        
        /// map the shift down tile transformation array to [SKSpriteNode, SKAction)] to work Animator world
        var shiftDownActions: [SpriteAction] = []
        for trans in shiftDown {
            
            let (startRow, startCol) = trans.initial.tuple
            let (endRow, endCol) = trans.end.tuple
            let sprite: SKSpriteNode
            if trans.initial.row >= Int(boardSize) {
                // startRow may be out of bounds because we temprarily place the tile above the board to visually allow it to drop down.  In that case, use the end row to access the actualy sprite from storage
                sprite = sprites[endRow][endCol]
            } else {
                //sprite already exist in the board. so access it by it's start row
                sprite = sprites[startRow][startCol]
            }
            
            //create the action
            let endPoint = CGPoint.init(x: tileSize * CGFloat(trans.end.column) + bottomLeft.x,
                                        y: tileSize * CGFloat(trans.end.row) + bottomLeft.y)
            let animation = SKAction.move(to: endPoint, duration: AnimationSettings.fallSpeed)
            shiftDownActions.append(SpriteAction(sprite: sprite,action: SKAction.sequence([animation])))
        }
        
        animator.animate(shiftDownActions) { [weak self] in
            guard let self = self else { return }
            completion?() ?? self.animationsFinished(endTiles: finalTiles)
        }
    }
    
    private func animationsFinished(endTiles: [[Tile]]?,
                                    ref: Bool = true) {
        
        /// endTiles is optional but almost always has a value
        /// However, with rotate previews, we don't have to create and add sprites like we normally do because some rotate previews return to the original state.  So in the case where there are no end tiles, act like nothing ever happened.
        if let endTiles = endTiles {
            sprites = createSprites(from: endTiles)
            add(sprites: sprites, tiles: endTiles)
            print("Renderer is calling animations finished")
            InputQueue.append(Input(.animationsFinished(ref: ref), endTiles))
        } else {
            print("Renderer is calling animations finished, no reffing")
            InputQueue.append(Input(.animationsFinished(ref: false), endTiles))
        }
        
        
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
    
    /// Renders and delegates animation of collecting store offers
    private func collectOffer(_ trans: [Transformation], offer: StoreOffer, atTilecoord: TileCoord, discardOffer: StoreOffer, discardedOfferTileCoord: TileCoord) {
        guard trans.count > 1 else {
            
            // in this case we have collected a upgrade for the run
            
            if case StoreOfferType.rune = offer.type {
                // get the target area to move the rune.
                let runeSlotView = backpackView.runeInventoryContainer?.firstEmptyRuneSlotNode()
                let targetPoint = runeSlotView?.convert(backpackView.frame.center, to: foreground) ?? .zero
                let sprite = sprites[atTilecoord.x][atTilecoord.y]
                
                animator.animateCollectRune(runeSprite: sprite, targetPosition: targetPoint) { [weak self] in
                    self?.computeNewBoard(for: trans.first) { [weak self] in self?.animationsFinished(endTiles: trans.first?.endTiles) }
                }
            }
            
            else {
                // animate received the health, dodge or luck and then compute the new board
                let targetSprite = hud.targetSprite(for: offer.type)
                let targetPoint = targetSprite?.convert(hud.gemSpriteNode?.frame.center ?? .zero, to: foreground) ?? .zero
                let sprite = sprites[atTilecoord.x][atTilecoord.y]
                animator.animateCollectOffer(offerType: offer.type, offerSprite: sprite, targetPosition: targetPoint, to: hud) { [weak self] in
                    self?.computeNewBoard(for: trans.first) { [weak self] in self?.animationsFinished(endTiles: trans.first?.endTiles) }
                }
            }
            return
        }
        
        
        guard trans.count < 3 else {
            preconditionFailure("This method is not set up to handle more than 2 transformations")
        }
        let first = trans.first!
        let second = trans.last!
        
        let potionAnimationFrames = SpriteSheet(texture: SKTexture(imageNamed: offer.textureName),
                                                rows: 1,
                                                columns: offer.spriteSheetColumns!)
        
        let placeholderSprite = SKSpriteNode(color: .clear, size: CGSize(width: tileSize, height: tileSize))
        placeholderSprite.run(SKAction.repeatForever(SKAction.animate(with: potionAnimationFrames.animationFrames(), timePerFrame: 0.2)))
        
        computeNewBoard(for: first) { [weak self] in
            guard let self = self else {
                preconditionFailure("this is bad")
            }
            /// add sprites from first one
            let sprites = self.createSprites(from: first.endTiles)
            self.add(sprites: sprites, tiles: first.endTiles!)
            
            
            /// add potion sprite to board
            let position = self.positionInForeground(at: atTilecoord)
            placeholderSprite.size = CGSize(width: self.tileSize/2, height: self.tileSize/2)
            placeholderSprite.position = position
            placeholderSprite.zPosition = Precedence.floating.rawValue
            self.spriteForeground.addChild(placeholderSprite)
            
            /// animate it moving to the affected tile
            if let affectedTile = second.tileTransformation?.first {
                
                /// determine target position
                let position = self.positionInForeground(at: affectedTile.initial)
                
                self.animator.animateMoveGrowShrinkExplode(sprite: placeholderSprite, to: position, tileSize: self.tileSize) {
                    [weak self] in
                    self?.animationsFinished(endTiles: second.endTiles)
                }
            }
            
        }
    }
    
    private func collectItem(for transformation: Transformation, inputType: InputType) {
        computeNewBoard(for: transformation) { [weak self] in
            guard let self = self, let endTiles = transformation.endTiles  else {
                self?.animationsFinished(endTiles: transformation.endTiles)
                return
            }
            
            // by recreating sprites we effectively remove the gem from the board.
            self.sprites = self.createSprites(from: endTiles)
            self.add(sprites: self.sprites, tiles: endTiles)
            
            if case let InputType.collectItem(coord, item, amount) = inputType {
                // add a bunch of gold sprites to the board
                if let startPoint = self.positionsInForeground(at: [coord]).first {
                    var addedSprites: [SKSpriteNode] = []
                    for _ in 0..<item.amount {
                        let identifier: String = item.type == .gold ? Identifiers.gold : item.textureName
                        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: identifier),
                                                  color: .clear,
                                                  size: Style.Board.goldGainSize)
                        sprite.position = startPoint
                        sprite.zPosition = 10_000
                        self.spriteForeground.addChild(sprite)
                        addedSprites.append(sprite)
                    }
                    self.animator.animateGold(goldSprites: addedSprites, gained: amount, from: startPoint, to: self.hud, in: self.foreground) { [weak self] in self?.animationsFinished(endTiles: transformation.endTiles) }
                }
            } else {
                self.animationsFinished(endTiles: transformation.endTiles)
            }
        }

    }
    
    /// Recursive wrapper for chaining animated transformations
    private func computeNewBoard(for transformations: [Transformation]) {
        computeNewBoard(for: transformations.first) { [weak self] in
            guard let self = self else { return }
            if transformations.count == 1 {
                self.animationsFinished(endTiles: transformations.first?.endTiles)
            } else {
                self.computeNewBoard(for: Array(transformations.dropFirst()))
            }
        }
    }
    
    /// Prepares the animation data to compute a new board.  This is hard coded to work with remove and replace animations
    /// Use the callback if you'd to do something on completion.  Youll want to call animationsFinished(for:endTiles:) in addition to whatever else you want to do.
    /// Implicitly depends on Animator
    private func computeNewBoard(for transformation: Transformation?, completion: ( () -> () )? = nil) {
        guard let endTiles = transformation?.endTiles else {
            fatalError("We should always be passing through end tiles")
        }
        
        guard let transformation = transformation else {
            completion?() ?? animationsFinished(endTiles: endTiles)
            return
        }
        
        let spriteNodes = createSprites(from: endTiles)
        // TODO: don't hardcode this
        guard let removed = transformation.removed,
              let newTiles = transformation.newTiles,
              let shiftDown = transformation.shiftDown else { preconditionFailure("We need these specific translations to do this.") }
        
        // remove "removed" tiles from sprite storage
        var removedAnimations: [SpriteAction] = []
        for tileTrans in removed {
            
            /// add crumble animation and add a gem if needed
            if let crumble = sprites[tileTrans.end.x][tileTrans.end.y].crumble() {
                // set the position way in the background so that new nodes come in over
                sprites[tileTrans.end.x][tileTrans.end.y].zPosition = Precedence.underground.rawValue
                
                removedAnimations.append(crumble)
                
                
                /// Add the gem if needed
                /// Grab the current rock on the board.
                /// If this rock contains a gem, then add it to the board
                let currentSprite = sprites[tileTrans.end.x][tileTrans.end.y]
                
                if case TileType.rock(color: let color, holdsGem: let holdsGem) = currentSprite.type,
                   holdsGem {
                    
                    /// we need to add the gem to the board or else shit is weird
                    let sprite = DFTileSpriteNode(type: .item(Item(type: .gem, amount: 10, color: color)), height: currentSprite.size.height, width: currentSprite.size.width)
                    
                    // place the gem on the board where the rock was
                    sprite.position = currentSprite.position
                    
                    /// add the gem sprite our data store
                    sprites[tileTrans.end.x][tileTrans.end.y] = sprite
                    
                    /// add the gem sprite to the foreground
                    spriteForeground.addChild(sprite)
                    
                }
                
            } else if let poof = sprites[tileTrans.end.x][tileTrans.end.y].poof(), case InputType.foundRuneDiscarded? = transformation.inputType {
                removedAnimations.append(poof)
            }
            // case for poofing the discarded store offer
            else if case InputType.collectOffer(_, _, let disardedCoord, _)? = transformation.inputType,
                      let poof = sprites[disardedCoord.x][disardedCoord.y].poof() {
                removedAnimations.append(poof)
            }

        }
        
        // add new tiles "newTiles"
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
        
        var shiftDownActions: [SpriteAction] = []
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
            let wait = SKAction.wait(forDuration: 0.33)
            shiftDownActions.append(SpriteAction(sprite: sprite, action: SKAction.sequence([wait, animation])))
        }
        
        // animate the removal of rocks and rocks falling at the same time
        // they are quasi-sequenced because the faling rocks wait x seconds before falling
        // TODO: figure out if there is a better way to sequence animations
        // For example, it would be nice to say "start this animation at a certain key frame/progress of another animation"
        removedAnimations.append(contentsOf: shiftDownActions)
        animator.animate(removedAnimations) {  [weak self] in
            guard let strongSelf = self else { return }
            print("Done with computeNewBoard")
            completion?() ?? strongSelf.animationsFinished(endTiles: endTiles)
            
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
        
        if self.tileDetailView?.isUserInteractionEnabled ?? false {
            self.tileDetailView?.touchesEnded(touches, with: event)
        } else {
            self.backpackView.touchesEnded(touches, with: event)
        }
        
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
                        
                        InputQueue.append(
                            Input(.touch(TileCoord(row, col),
                                         sprites[row][col].type))
                        )
                        
                    }
                }
            }
        }
    }
}

extension Renderer {
    private func gameWin(transformation: Transformation?) {
        guard case let InputType.gameWin(completedGoals)? = transformation?.inputType else { fatalError("Should we crash?") }
        animator.gameWin(transformation: transformation, sprites: sprites) { [weak self] in
            
            guard let self = self else { return }
            self.menuForeground.removeAllChildren()
            let gameWinMenu = MenuSpriteNode(.gameWin, playableRect: self.playableRect, precedence: .menu, level: self.level, completedGoals: completedGoals)
            self.menuForeground.addChild(gameWinMenu)
            self.foreground.addChildSafely(self.menuForeground)
        }
    }
}

extension Renderer: SettingsDelegate {
    func settingsTapped() {
        InputQueue.append(Input(.pause))
    }
}
