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
    
    struct Constants {
        static let rotateVisualCueSize: CGSize = .init(width: 850, height: 170)
    }
    
    /// PUBLIC
    public var backpackView: BackpackView
    
    /// PRIVATE
    private let playableRect: CGRect
    private let foreground: SKNode
    private var sprites: [[DFTileSpriteNode]] = []
    private let bottomLeft: CGPoint
    private let boardSize: CGFloat!
    private var tileSize: CGFloat
    private let precedence: Precedence
    private let tutorialConductor: TutorialConductor?
    
    // Used to determine what special UI consdierations to make for what level we are on
    private let level: Level
    
    // View for TileDetail
    private var tileDetailView: TileDetailView?
    
    private var spriteForeground = SKNode()
    private var menuForeground = SKNode()
    
    // Dialog for Tutorial and FTUE
    private var dialogueOverlay: DialogueOverlay?
    
    // Current Menu that will receive touch events
    var currentMenu: MenuSpriteNode?
    
    let gameRecapView: GameRecapView
    let runStatTracker: RunStatTracker
    
    // Rotate Visual Cue
    let rotateVisualCue: SKSpriteNode
    
    // Debug View for Boss
    private var bossDebugView: BossDebugView
    private lazy var bossView: BossView = {
        return BossView(playableRect: playableRect, tileSize: tileSize, spriteProvider: { [weak self] in
            return self?.sprites ?? []
        })
    }()
    
    /// MARK: - LAZY
    private lazy var safeArea: SKSpriteNode = {
        //create safe area
        let safeArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: 75.0))
        safeArea.position = CGPoint.position(safeArea.frame, centeredInTopOf: playableRect)
        return safeArea
    }()
    
    private lazy var hud: HUD = {
        let hud = HUD.build(color: .foregroundBlue,
                            size: CGSize(width: playableRect.width,
                                         height: Style.HUD.height),
                            delegate: self,
                            level: level)
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
                                          size: CGSize(width: playableRect.width,
                                                       height: Style.LevelGoalView.height))
        levelGoalView.position = CGPoint.alignHorizontally(levelGoalView.frame,
                                                           relativeTo: safeArea.frame,
                                                           horizontalAnchor: .left,
                                                           verticalAlign: .bottom,
                                                           verticalPadding: 200.0,
                                                           horizontalPadding: Style.Padding.less,
                                                           translatedToBounds: true)
        levelGoalView.zPosition = Precedence.flying.rawValue
        return levelGoalView
    }()
    
    //Animator
    private lazy var animator = {
        return Animator(foreground: foreground, tileSize: tileSize) { [weak self] tileType in
            guard let self = self else { return nil }
            if let goalIndex = self.levelGoalTracker.typeAdvancesGoal(type: tileType) {
                let goalOrigin = self.levelGoalView.originForGoalView(index: goalIndex)
                let targetPosition = self.levelGoalView.convert(goalOrigin, to: self.spriteForeground)
                return targetPosition
            }
            return nil
        }
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(playableRect: CGRect,
         foreground givenForeground: SKNode,
         boardSize theBoardSize: Int,
         precedence: Precedence,
         level: Level,
         levelGoalTracker: LevelGoalTracker,
         tutorialConductor: TutorialConductor?,
         runStatTracker: RunStatTracker) {
        
        self.precedence = precedence
        self.playableRect = playableRect
        self.boardSize = CGFloat(theBoardSize)
        self.level = level
        self.levelGoalTracker = levelGoalTracker
        self.tutorialConductor = tutorialConductor
        
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
        
        // debug view for Boss
        self.bossDebugView = BossDebugView(playableRect: playableRect)
        
        // recap view after win and loss
        self.gameRecapView = GameRecapView(playableRect: playableRect)
        self.runStatTracker = runStatTracker
        
        // rotate visual cue
        let rotateVisualCueSprite = SKSpriteNode(texture: SKTexture(imageNamed: "rotate-runes-decorative"), size: Constants.rotateVisualCueSize)
        self.rotateVisualCue = rotateVisualCueSprite
        rotateVisualCue.position = CGPoint.position(rotateVisualCue.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: 400)
        rotateVisualCue.zPosition = -1
        
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        
        //        let testBackground = SKSpriteNode(texture: SKTexture(imageNamed: "test-background"), size: CGSize(width: playableRect.size.width, height: playableRect.size.width*2.1))
        //        testBackground.position = CGPoint.alignHorizontally(testBackground.frame,
        //                                                            relativeTo: safeArea.frame,
        //                                                            horizontalAnchor: .right,
        //                                                            verticalAlign: .bottom,
        //                                                            translatedToBounds: true)
        //        testBackground.zPosition = 0
        //        foreground.addChild(testBackground)
        
        // tile detail view
        self.tileDetailView = TileDetailView(foreground: foreground, playableRect: playableRect, alignedTo: hud.frame, levelSize: level.boardSize)
        tileDetailView?.zPosition = 1_000_000
        
        self.isUserInteractionEnabled = true
        
        foreground.position = playableRect.center
        menuForeground.position = playableRect.center
        
        [spriteForeground, safeArea, hud, levelGoalView, backpackView, bossView, self.rotateVisualCue].forEach { foreground.addChild($0) }
        //        [spriteForeground, safeArea, hud, levelGoalView, backpackView, bossDebugView, bossView].forEach { foreground.addChild($0) }
        
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
                
            case .itemUsed(let ability, let allTarget):
                animateRuneUsed(input: inputType, transformations: transformations, rune: ability, targets: allTarget.allTargetAssociatedCoords)
                
            case .collectOffer(let tileCoord, let offer, let discardedCoord, let discardedOffer):
                if case let StoreOfferType.gems(amount) = offer.type {
                    collectItem(for: trans, amount: amount, atCoord: tileCoord, textureName: offer.textureName, inputType: inputType, randomColor: true)
                } else {
                    collectOffer(transformations, offer: offer, atTilecoord: tileCoord, discardOffer: discardedOffer, discardedOfferTileCoord: discardedCoord)
                }
                
            case let .collectItem(coord, item, _):
                collectItem(for: trans, amount: item.amount, atCoord: coord, textureName: item.textureName, inputType: inputType)
                
            case .decrementDynamites:
                decrementDynamite(in: transformations)
                
            case .refillEmpty:
                refillEmptyTiles(with: trans)
                
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
                
            case .bossTurnStart(let phase):
                switch phase.bossState.stateType {
                case .eats:
                    if trans.newTiles != nil {
                        computeNewBoard(for: trans)
                    }
                    
                case .targetEat:
                    animationsFinished(endTiles: trans.endTiles)
                    
                case .targetAttack:
                    animationsFinished(endTiles: trans.endTiles)
                    
                case .attack:
                    showBossAttacks(in: transformations, bossPhase: phase)
                    
                case .rests, .phaseChange, .superAttack, .targetSuperAttack:
                    //                    showBossPhaseChangeAttacks(in: trans, bossPhase: BossPhase)
                    animationsFinished(endTiles: trans.endTiles)
                }
                
            case .bossPhaseStart(let phase):
                showBossPhaseChangeAttacks(in: trans, bossPhase: phase)
                
            case .noMoreMoves:
                guard let endTiles = trans.endTiles,
                      let playerCoord = trans.tileTransformation?.first,
                      case TileType.player(let data) = endTiles[playerCoord.initial].type
                else {
                    return
                }
                showNoMoreMovesModal(playerData: data)
                
            case .noMoreMovesConfirm:
                shuffleBoard(transformations: transformations)
                
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
            removeMenu()
            
        case .pause:
            // show the menu
            foreground.addChild(menuForeground)
            if (tutorialConductor?.isTutorial ?? false) {
                let tutorialPauseMenu = createMenuSpriteNode(.tutorialPause)
                addMenu(tutorialPauseMenu)
            } else {
                let pauseMenu = createMenuSpriteNode(.pause)
                addMenu(pauseMenu)
            }
            
        case .gameLose(let type):
            gameRecapView.showGameRecap(win: false, killedBy: type, with: runStatTracker.runStats)
            menuForeground.addChild(gameRecapView)
            foreground.addChildSafely(menuForeground)
            
        case .playAgain:
            removeMenu()
            
        case .tutorialPhaseStart(let phase):
            showTutorial(phase: phase)
            
        case .levelGoalDetail:
            guard let phase = tutorialConductor?.phase else { return }
            if phase == .theseAreLevelGoals {
                showTutorial(phase: tutorialConductor?.phase)
            }
            
        default:
            ()
        }
    }
    private func addMenu(_ menuSprite: MenuSpriteNode) {
        self.currentMenu = menuSprite
        foreground.addChildSafely(menuSprite)
        menuSprite.playMenuBounce()
        
        foreground.addChildSafely(menuForeground)
    }
    
    private func removeMenu() {
        menuForeground.removeFromParent()
        menuForeground.removeAllChildren()
        currentMenu = nil
    }
    
    private func createMenuSpriteNode(_ menuType: MenuType) -> MenuSpriteNode {
        return MenuSpriteNode(menuType, playableRect: self.playableRect, precedence: .menu, level: self.level)
    }
    
    
    private func showTutorial(phase: TutorialPhase?) {
        guard let phase = phase else { return }
        
        let dialogueOverlay = DialogueOverlay(playableRect: playableRect, foreground: foreground, tutorialPhase: phase, levelGoalViewOrigin: levelGoalView.position) { [weak self] tileType in
            // convert the sprites to tile types
            guard let _ = phase.highlightTileType else { return nil }
            guard let sprites = self?.sprites,
                  let first = typeCount(for: sprites.map{ $0.map { $0.type } }, of: tileType).first else { return nil }
            
            return positionInForeground(at: first)
        }
        
        let wait = SKAction.wait(forDuration: phase.waitDuration)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        fadeIn.timingMode = .easeInEaseOut
        
        
        self.dialogueOverlay = dialogueOverlay
        dialogueOverlay.alpha = 0
        spriteForeground.addChild(dialogueOverlay)
        dialogueOverlay.run(SKAction.sequence([wait, fadeIn]))
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
            self?.computeNewBoard(for: transformations)
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
                } else if case TileType.item = tiles[row][col].type {
                    sprite.showAmount()
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
                
                // Boss stuff
                if tiles[row][col].bossTargetedToEat ?? false {
                    sprite.indicateSpriteWillBeEaten()
                }
                
                if case TileType.dynamite(let fuse) = tiles[row][col].type {
                    sprite.showFuseTiming(fuse.count)
                }
            }
        }
        return sprites
    }
    
    
    private func debugMenu() -> MenuSpriteNode {
        return MenuSpriteNode(.debug, playableRect: self.playableRect, precedence: .menu, level: self.level)
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
                
                return
            }
            
            else if let endTiles = trans.first?.endTiles,
//                    let playerCoord = getTilePosition(.player(.zero), tiles: endTiles),
                    let oldPlayerCoord = getTilePosition(.player(.zero), sprites: self.sprites),
                    case TileType.player(let data) = sprites[oldPlayerCoord].type {
                // animate received the health, dodge or luck and then compute the new board
                let targetSprite = hud.targetSprite(for: offer.type)
                let targetPoint = hud.convert(targetSprite?.frame.center ?? .zero, to: foreground)// ?? .zero
                let sprite = sprites[atTilecoord.x][atTilecoord.y]
                animator.animateCollectOffer(offerType: offer.type, offerSprite: sprite, targetPosition: targetPoint, to: hud, updatedPlayerData: data) { [weak self] in
                    self?.computeNewBoard(for: trans.first) { [weak self] in self?.animationsFinished(endTiles: endTiles) }
                }
                
                return
            }
            
            self.computeNewBoard(for: trans.first) { [weak self] in self?.animationsFinished(endTiles: trans.first?.endTiles) }
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
    
    private func collectItem(for transformation: Transformation, amount: Int, atCoord coord: TileCoord, textureName: String, inputType: InputType, randomColor: Bool = false) {
        computeNewBoard(for: transformation) { [weak self] in
            guard let self = self, let endTiles = transformation.endTiles  else {
                self?.animationsFinished(endTiles: transformation.endTiles)
                return
            }
            
            // by recreating sprites we effectively remove the gem from the board.
            self.sprites = self.createSprites(from: endTiles)
            self.add(sprites: self.sprites, tiles: endTiles)
            
            //            if case let InputType.collectItem(coord, item, amount) = inputType {
            // add a bunch of gem sprites to the board
            if let startPoint = self.positionsInForeground(at: [coord]).first {
                var addedSprites: [SKSpriteNode] = []
                for _ in 0..<amount {
                    let identifier: String = randomColor ?  Item.randomColorGem : textureName
                    let sprite = SKSpriteNode(texture: SKTexture(imageNamed: identifier),
                                              color: .clear,
                                              size: Style.Board.goldGainSize)
                    sprite.position = startPoint
                    sprite.zPosition = 10_000
                    self.spriteForeground.addChild(sprite)
                    addedSprites.append(sprite)
                }
                
                var targetPosition = self.hud.convert(self.hud.gemSpriteNode?.frame.center ?? .zero, to: self.foreground)
                
                if case let InputType.collectItem(_, item, _) = inputType,
                   let goalIndex = self.levelGoalTracker.typeAdvancesGoal(type: TileType.item(item)) {
                    let goalOrigin = self.levelGoalView.originForGoalView(index: goalIndex)
                    let gemGoalPosition  = self.levelGoalView.convert(goalOrigin, to: self.spriteForeground)
                    
                    targetPosition = gemGoalPosition
                }
                self.animator.animateGold(goldSprites: addedSprites, gained: amount, from: startPoint, to: targetPosition, in: self.hud) { [weak self] in self?.animationsFinished(endTiles: transformation.endTiles) }
            }
        }
        
    }
    
    //MARK: Compute New Board Logic
    
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
        guard let removed = transformation.removed,
              let newTiles = transformation.newTiles,
              let shiftDown = transformation.shiftDown
        else {
            #warning("I removed the precondition failure here because I wanted to use this function to end all rune use animations.  I would check here for any strange bugs around animating.")
            animationsFinished(endTiles: endTiles)
            return
        }
        
        // remove "removed" tiles from sprite storage
        var removedAnimations: [SpriteAction] = []
        
        /// data needed to remember where we found gems
        var tilesWithGem: [TileCoord] = []
        var removedColor: ShiftShaft_Color?
        
        /// additional waiting time for certain actions
        var additionalWaiting: Double = 0.0
        
        // MARK: Monsters killed during the board shuffle
        if case InputType.noMoreMovesConfirm? = transformation.inputType {
            let mineralSpritsKillMonstersTuple = animator.animateMineralSpirits(targetTileCoords: removed.map { $0.initial }, playableRect: playableRect, spriteForeground: spriteForeground, tileSize: tileSize, sprites: sprites, positionInForeground: positionInForeground(at:))
            removedAnimations.append(contentsOf: mineralSpritsKillMonstersTuple.1)
            
            additionalWaiting += mineralSpritsKillMonstersTuple.waitDuration
        }
        
        
        // MARK: Removal animations
        for tileTrans in removed {
            
            let currentSprite = sprites[tileTrans.end.x][tileTrans.end.y]
            
            // keep track of whre we find gems
            if case TileType.rock(color: _, holdsGem: let holdsGem, _) = currentSprite.type,
               holdsGem {
                tilesWithGem.append(tileTrans.end)
            }
            
            
            // MARK: The player tapped on something
            if case InputType.touch(_, let type)? = transformation.inputType {
                
                // if rocks mined progress a goal then we want to have them fly up to the level goal view
                if let goalIndex = levelGoalTracker.typeAdvancesGoal(type: type) {
                    let goalOrigin = levelGoalView.originForGoalView(index: goalIndex)
                    let targetPosition = self.levelGoalView.convert(goalOrigin, to: self.spriteForeground)
                    
                    removedColor = type.color
                    
                    sprites[tileTrans.end.x][tileTrans.end.y].zPosition = 100_000
                    
                    let animation = animator.createAnimationCompletingGoals(sprite: sprites[tileTrans.end.x][tileTrans.end.y], to: targetPosition)
                    
                    removedAnimations.append(animation)
                    
                }
                /// crumble should happen when the rocks are not needed for the goal.
                else if let crumble = sprites[tileTrans.end.x][tileTrans.end.y].crumble() {
                    // set the position way in the background so that new nodes come in over
                    sprites[tileTrans.end.x][tileTrans.end.y].zPosition = Precedence.underground.rawValue
                    
                    removedColor = type.color
                    removedAnimations.append(crumble)
                }
            }
            
            // MARK: Monster died
            else if let monstersKilled = transformation.monstersDies,
                    monstersKilled.contains(where: { $0.tileCoord == tileTrans.initial } ) {
                sprites[tileTrans.end.x][tileTrans.end.y].zPosition = 100_000
                
                var shouldSkipDyingAnimation = false
                if case InputType.itemUsed(let rune, _)? = transformation.inputType {
                    switch rune.type {
                        // these aniamtions take care of the death animation themselves
                    case .fireball, .rainEmbers, .fieryRage, .drillDown, .monsterCrush:
                        shouldSkipDyingAnimation = true
                    default:
                        break
                    }
                }
                
                let animation = animator.createMonsterDyingAnimation(sprite: sprites[tileTrans.end.x][tileTrans.end.y], durationWaitBefore: 0.0, skipDyingAnimation: shouldSkipDyingAnimation)
                
                additionalWaiting += (animation.duration ?? 0.0) * 0.55 // dont wait for the entire animation
                
                removedAnimations.append(animation)
            
            }
            
            // MARK: Decremt the dynamite fuses and explode
            if case InputType.decrementDynamites? = transformation.inputType {
                // when a rock with a gem is blown up, so is the gem inside of it
                tilesWithGem = []
                
                // Some of the removed rocks could be rocks, we want to make them crumble
                if let crumble = sprites[tileTrans.end.x][tileTrans.end.y].crumble() {
                    // set the position way in the background so that new nodes come in over
                    sprites[tileTrans.end.x][tileTrans.end.y].zPosition = Precedence.underground.rawValue
                    
                    removedAnimations.append(crumble)
                }
                
            }
            
            // MARK: Poofing sprites
            // The rune discarded during RuneReplacement should poof
            if case InputType.foundRuneDiscarded? = transformation.inputType,
               let poof = sprites[tileTrans.end.x][tileTrans.end.y].poof() {
                removedAnimations.append(poof)
            }
            // The offer that is not collected should poof
            else if case InputType.collectOffer(_, _, let disardedCoord, _)? = transformation.inputType,
                    let poof = sprites[disardedCoord.x][disardedCoord.y].poof() {
                removedAnimations.append(poof)
            }
        }
        
        // MARK: Add gem sprites to the board
        // add the gems after everything else has been animated for removal
        for coord in tilesWithGem {
            // we need to add the gem to the board or else shit is weird
            let sprite = DFTileSpriteNode(type: .item(Item(type: .gem, amount: 0, color: removedColor!)), height: tileSize, width: tileSize)
            
            sprite.alpha = 0.0
            
            // place the gem on the board where the rock was
            sprite.position = positionInForeground(at: coord)
            
            // add the gem sprite to our data store
            sprites[coord.x][coord.y] = sprite
            
            // add the gem sprite to the foreground
            spriteForeground.addChild(sprite)
        }
        
        // MARK: Add new tiles with the new tiles TileTransformation
        for trans in newTiles {
            let (startRow, startCol) = trans.initial.tuple
            let (endRow, endCol) = trans.end.tuple
            
            // get sprite from the target sprites row and col
            let sprite = spriteNodes[endRow][endCol]
            
            // place the tile at the "start" which could be above the visible board
            // the animation will then move them to the correct place in the foreground
            let x = tileSize * boardSize + ( CGFloat(startRow) * tileSize ) + bottomLeft.x
            let y = tileSize * CGFloat(startCol) + bottomLeft.y
            sprite.position = CGPoint.init(x: y, y: x)
            
            // add it to the scene
            spriteForeground.addChild(spriteNodes[endRow][endCol])
        }
        
        // track where the tiles move to after shifting down
        var newTilesWithGems: [TileCoord] = []
        
        
        // MARK: Create shift down animations for the tiles
        // map the shift down tile transformation array to [(SKSpriteNode, SKAction)] to work Animator world
        var shiftDownActions: [SpriteAction] = []
        for trans in shiftDown {
            
            let (startRow, startCol) = trans.initial.tuple
            let (endRow, endCol) = trans.end.tuple
            let sprite: SKSpriteNode
            
            // Some tiles have an inital row that is outside the board limits.  In that case we need to grab the sprite from the spriteNodes array which has been created with sprites from the "endTiles" of this transformation
            if trans.initial.row >= Int(boardSize) {
                sprite = spriteNodes[endRow][endCol]
            }
            // Otherwise, the sprite is already on the board and we can just grab it from our local sprites storage
            else {
                sprite = sprites[startRow][startCol]
            }
            
            // track where the gems are moving to so that we can target the gem in an animation
            // gems dont always move so this code path does always get hit
            if tilesWithGem.contains(trans.initial) {
                let currentSprite = sprites[startRow][startCol]
                if case TileType.item = currentSprite.type {
                    newTilesWithGems.append(TileCoord(endRow, endCol))
                    
                    // basically if there are 2+ rocks with gems, and one of them moves and the other does not
                    // then we ran into an edge case where we would have only animated the formation of one of the gems
                    tilesWithGem.removeFirst(where: { $0 == trans.initial })
                }
            }
            
            //create the action
            let endPoint = CGPoint.init(x: tileSize * CGFloat(trans.end.column) + bottomLeft.x,
                                        y: tileSize * CGFloat(trans.end.row) + bottomLeft.y)
            let animation = SKAction.move(to: endPoint, duration: AnimationSettings.fallSpeed)
            animation.timingMode = .easeIn
            
            // Add in additionalWaiting duration so that we can time some removal animations before the shift down animations
            let wait = SKAction.wait(forDuration: 0.33 + additionalWaiting)
            shiftDownActions.append(SpriteAction(sprite: sprite, action: SKAction.sequence([wait, animation])))
        }
        
        if case InputType.touch? = transformation.inputType {
            if let removedColor = removedColor {
                // sometimes gems dont shift down so we need to use the original tile with gems array
                newTilesWithGems.append(contentsOf: tilesWithGem)
                // mining gems animations
                let miningGemAnimations = animator.createAnimationForMiningGems(from: removed.map { $0.end }, tilesWithGems: newTilesWithGems, color: removedColor, spriteForeground: spriteForeground, sprites: sprites, amountPerRock: numberOfGemsPerRockForGroup(size: removed.count), tileSize: tileSize) { [weak self] tileCoord in
                    guard let self = self else { return .zero }
                    return self.positionInForeground(at: tileCoord)
                }
                removedAnimations.append(contentsOf: miningGemAnimations)
            }
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

//MARK: - Shuffle board logic

extension Renderer {
    
    // show a modal that asks the player to make an offer to the Mineral Spirits
    private func showNoMoreMovesModal(playerData: EntityModel) {
        let noMoreMovesModal = ConfirmShuffleView(playableRect: playableRect, canPayTwoHearts: playerData.hp > 2, playersGemAmount: playerData.carry.totalGem, sprites: sprites, spriteForeground: spriteForeground, tileSize: tileSize)
        noMoreMovesModal.zPosition = 100_000_000
        
        foreground.addChild(noMoreMovesModal)
        
    }
    
    
    private func shuffleBoard(transformations: [Transformation]) {
        guard let shuffleTrans = transformations.first,
              let shuffleTileTrans = shuffleTrans.tileTransformation,
              let removeAndReplace = transformations.last
        else {
            animationsFinished(endTiles: transformations.last?.endTiles)
            return
        }
        
        // animate all the tiles swapping positions
        animator.animateBoardShuffle(tileTransformations: shuffleTileTrans, sprites: sprites, positionInForeground: positionInForeground(at:)) { [weak self] in
            guard let self = self,
                  let tiles = shuffleTrans.endTiles else {
                      return
                  }
            // we need to reset the the sprites in between these animations before animaing remove and replace
            let newSprites = self.createSprites(from: tiles)
            self.sprites = newSprites
            self.add(sprites: self.sprites, tiles: tiles)
            // animate the removal and replacement of the monsters
            self.computeNewBoard(for: removeAndReplace)
        }
    }
    
}

//MARK: - Boss logic

extension Renderer {
    
    
    private func showBossPhaseChangeAttacks(in transformation: Transformation, bossPhase: BossPhase) {
        guard let grownPillars = bossPhase.phaseChangeTagets.createPillars else {
            animationsFinished(endTiles: transformation.endTiles)
            return
        }
        
        animator.showPillarsGrowing(sprites: sprites, spriteForeground: spriteForeground, bossTileAttacks: grownPillars, tileSize: tileSize) { [weak self] in
            self?.animationsFinished(endTiles: transformation.endTiles)
        }
        
    }
    
    private func showBossAttacks(in transformation: [Transformation], bossPhase: BossPhase) {
        guard let trans = transformation.first, let endTiles = trans.endTiles else {
            animationsFinished(endTiles: transformation.first?.endTiles)
            return
        }
        
        func animateDyamiate(completion:  @escaping () -> Void) {
            if let dynamiteAttacks = bossPhase.bossState.targets.attack?[.dynamite] {
                let dynaTypes: [TileType] = tileTypesOf(TileType.dynamite(DynamiteFuse.init(count: 3, hasBeenDecremented: false)), in: endTiles)
                let targets = positionsInForeground(at: dynamiteAttacks)
                
                let targetSprites = dynamiteAttacks.map { [sprites] in sprites[$0] }
                
                animator.animateBossSingleTargetAttack(foreground: spriteForeground, tileTypes: dynaTypes, tileSize: tileSize, startingPosition: bossDebugView.center, targetPositions: targets, targetSprites: targetSprites, completion: completion)
            } else { completion() }
        }
        
        func animateSpawnSpider(completion:  @escaping () -> Void) {
            if let spiderAttacks = bossPhase.bossState.targets.attack?[.spawnSpider] {
                var spiderTypes: [TileType] = []
                for row in 0..<endTiles.count {
                    for col in 0..<endTiles[row].count {
                        let coord = TileCoord(row, col)
                        if spiderAttacks.contains(coord) {
                            // this is a new spider
                            spiderTypes.append(endTiles[coord].type)
                        }
                    }
                }
                let targets = positionsInForeground(at: spiderAttacks)
                
                let targetSprites = spiderAttacks.map { [sprites] in sprites[$0] }
                
                animator.animateBossSingleTargetAttack(foreground: spriteForeground, tileTypes: spiderTypes, tileSize: tileSize, startingPosition: bossDebugView.center, targetPositions: targets, targetSprites: targetSprites, completion: completion)
            } else { completion() }
            
        }
        
        func animatePoison(completion: @escaping () -> Void) {
            if let attackedColumns = bossPhase.bossState.poisonAttackColumns,
               let affectedTiles = trans.tileTransformation {
                animator.animateBossPoisonAttack(spriteForeground, targetedColumns: attackedColumns, targetedTiles: affectedTiles, sprites: sprites, tileSize: tileSize, completion: completion)
            } else { completion() }
        }
        
        
        /// First drop poison
        animatePoison {
            /// Then spiders
            animateSpawnSpider {
                /// Then dynamites
                animateDyamiate { [weak self] in
                    self?.animationsFinished(endTiles: transformation.first?.endTiles)
                }
            }
        }
    }
    
    
    private func decrementDynamite(in transformations: [Transformation]) {
        guard let dynamiteTransformation = transformations.first else {
            preconditionFailure("we need a transformation to be here")
        }
        
        // when we dont explode, then just refresh the sprites and move on
        guard !(dynamiteTransformation.tileTransformation ?? []).isEmpty else {
            animationsFinished(endTiles: dynamiteTransformation.endTiles)
            return
        }
        
        
        // at this point we should have the dynamite explosion and remove and replace
        // it would be extremely hard to set up a siutation where the explosion of Dynamite doesnt lead to a remove and replace of some sort- but it is possible
        guard let dynamiteTileTrans = dynamiteTransformation.tileTransformation,
              transformations.count == 2,
              let removeAndReplaceTrans = transformations.last else {
                  animationsFinished(endTiles: dynamiteTransformation.endTiles)
                  return
                  //            preconditionFailure("This is hardcoded to work with two transformations. The first for exploding the dynamite and the second for the remove and replace") }
              }
        
        let dynamiteCoords = dynamiteTileTrans.map { $0.initial }
        
        let dynamiteSprites = dynamiteCoords.map { [sprites] in sprites[$0.row][$0.column] }
        
        animator.animateDynamiteExplosion(dynamiteSprites: dynamiteSprites, dynamiteCoords: dynamiteCoords, foreground: foreground, boardSize: level.boardSize, sprites: sprites,
                                          positionInForeground: {
            [weak self] in
            guard let self = self else { return .zero }
            return self.positionInForeground(at: $0)
        }) { [weak self] in
            self?.computeNewBoard(for: removeAndReplaceTrans)
        }
        
    }
    
}

//MARK: - Touch logic
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
        
        if dialogueOverlay?.isUserInteractionEnabled ?? false {
            dialogueOverlay?.touchesEnded(touches, with: event)
        } else if tileDetailView?.isUserInteractionEnabled ?? false {
            tileDetailView?.touchesEnded(touches, with: event)
        } else if let currentMenu = currentMenu {
            currentMenu.touchesEnded(touches, with: event)
        }
        else {
            // one of these should get it
            backpackView.touchesEnded(touches, with: event)
            levelGoalView.touchesEnded(touches, with: event)
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
        animator.gameWin(transformation: transformation, sprites: sprites) { [weak self] in
            
            guard let self = self else { return }
            self.menuForeground.removeAllChildren()
            let gameWinMenu = MenuSpriteNode(.gameWin, playableRect: self.playableRect, precedence: .menu, level: self.level)
            
            self.addMenu(gameWinMenu)
        }
    }
}

extension Renderer: SettingsDelegate {
    func settingsTapped() {
        InputQueue.append(Input(.pause))
    }
}
