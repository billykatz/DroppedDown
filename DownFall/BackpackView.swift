//
//  BackpackView.swift
//  DownFall
//
//  Created by Katz, Billy on 1/17/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit
import Combine

/**
 The view containing the player's items
 */

class BackpackView: SKSpriteNode {
    
    //rune inventory container
    private(set) var runeInventoryContainer: RuneContainerView?
    
    private struct Constants {
        static let tag = String(describing: BackpackView.self)
        static let runeUseMaskSpriteName = "rune-use-mask"
    }
    
    // view model
    private let viewModel: TargetingViewModel
    
    // constants
    private let targetingAreaName = "targetingArea"
    
    // variables
    private var height: CGFloat = 0.0
    
    // tile sizes and coordinates
    private var tileSize: CGFloat
    private var boardSize: CGFloat
    private var bottomLeft: CGPoint
    private let playableRect: CGRect
    
    //container views
    private var background: SKSpriteNode
    private var viewContainer: SKSpriteNode
    
    // targeting area
    private var targetingArea: SKSpriteNode
    
    // dispose bag
    private var disposables = Set<AnyCancellable>()
    
    // targeting mask use
    private lazy var runeUseMask: SKSpriteNode = {
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: Constants.runeUseMaskSpriteName), size: CGSize(width: playableRect.width, height: playableRect.height))
        sprite.zPosition = 100
        return sprite
    }()
    
    init(playableRect: CGRect, viewModel: TargetingViewModel, levelSize: Int) {
        self.playableRect = playableRect
        self.boardSize = CGFloat(levelSize)
        //height and width set ups
        height = playableRect.height * Style.Backpack.heightCoefficient
        
        // get the view model
        self.viewModel = viewModel
        
        //get the tile size
        self.tileSize = GameScope.boardSizeCoefficient * (playableRect.width / CGFloat(levelSize))
        
        // view container
        self.viewContainer = SKSpriteNode(texture: nil, color: .clear, size: playableRect.size)
        self.viewContainer.zPosition = Precedence.foreground.rawValue
        self.viewContainer.position = .zero
        
        // background view
        self.background = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: height))
        self.background.position = CGPoint.position(this: background.frame, centeredInBottomOf: viewContainer.frame)
        
        //targeting area
        self.targetingArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: playableRect.height))
        self.targetingArea.position = self.viewContainer.frame.center
        self.targetingArea.name = self.targetingAreaName
        
        // center target area reticles
        let marginWidth = playableRect.width - CGFloat(tileSize * boardSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * boardSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        self.bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        
        // init ourselves
        super.init(texture: nil, color: .clear, size: CGSize(width: playableRect.width, height: height))
        
        // "bind" to to the view model
        viewModel.updateCallback = { [weak self] in self?.updated() }
        
        /// bind the rune container view to the targeting view model
        viewModel.runeSlotsUpdated = { [weak self] number, rune in self?.runeSlotsUpdated(number, rune) }
        
        // add children to view container
        viewContainer.addChild(self.background)
        
        // add out viewcontainter
        addChild(viewContainer)
        
        // enable user interaction
        isUserInteractionEnabled = true
        
        /// bind to view model
        viewModel.runeReplacementPublisher.sink { [weak self, height] (value) in
            let (pickaxe, rune) = value
            let viewModel = RuneReplacementViewModel(foundRune: rune, pickaxe: pickaxe, runeToSwap: nil)
            let view = RuneReplacementView(size: CGSize(width: playableRect.width, height: height),
                                           playableRect: playableRect,
                                           viewModel: viewModel)
            view.zPosition = 20_000
            view.position = .zero // centered 
            view.name = "runeReplacement"
            self?.removeChild(with: "runeReplacement")
            self?.addChild(view)
            
        }.store(in: &disposables)
        
        viewModel.foundRuneDiscardedPublisher.sink { [weak self] in
            self?.removeChild(with: "runeReplacement")
        }.store(in: &disposables)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - public update function
    
    
    /// Passed into our targeting viewModel as a callback function to "bind" everything together
    func updated() {
        updateReticles()
    }
    
    private func updateReticles() {
        /// removes or adds the targeting area based on the nullality of the view model rune
        /// if there is no rune then remove the targeting area
        /// else add the tareting area
        if viewModel.rune == nil {
            targetingArea.removeFromParent()
            runeUseMask.removeFromParent()
        } else {
            addChildSafely(targetingArea)
            runeUseMask.isUserInteractionEnabled = false
            addChildSafely(runeUseMask)
        }
        
        targetingArea.removeAllChildren()
        let areLegal = viewModel.currentTargets.areLegal
        for target in viewModel.currentTargets.targets {
            for coord in target.all {
                let position = translateCoord(coord)
                /// choose the reticle based on all targets legality and this individual target legality
                let identifier: String = (target.isLegal && areLegal) ? Identifiers.Sprite.greenReticle : Identifiers.Sprite.redReticle
                let reticle = SKSpriteNode(texture: SKTexture(imageNamed: identifier), size: CGSize(width: tileSize, height: tileSize))
                reticle.position = position
                reticle.zPosition = Precedence.menu.rawValue
                targetingArea.addChildSafely(reticle)
            }
        }
        
        runeInventoryContainer?.enableButton(areLegal, targets: viewModel.currentTargets)
    }
    
    
    // MARK: - private functions
    // TODO: should this be updated?
    private func runeSlotsUpdated(_ runeSlots: Int, _ runes: [Rune]) {
        
        /// Routes Rune container outputs to TargetingViewModel input
        let viewModel = RuneContainerViewModel(runes: runes,
                                               numberOfRuneSlots: runeSlots,
                                               runeWasTapped: self.viewModel.didSelect,
                                               runeWasUsed: self.viewModel.didUse,
                                               runeUseWasCanceled: self.viewModel.didDeselect)
        
        /// create the rune container view
        let runeContainer = RuneContainerView(viewModel: viewModel,
                                              size: CGSize(width: playableRect.width,
                                                           height: Style.Backpack.runeInventorySize))
        
        /// name it so we can remove it later
        runeContainer.name = "runeContainer"
        
        runeContainer.position = CGPoint.position(runeContainer.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most*3)
        
        /// position it high up to catch user interaction
        runeContainer.zPosition = 10_000_000
        
        /// remove the old rune container
        self.removeChild(with: "runeContainer")
        
        /// update our variable
        runeInventoryContainer = runeContainer
        
        /// finally add it to the screen
        addChildSafely(runeContainer)
    }
    
    private func translateCoord(_ coord: TileCoord) -> CGPoint {
        
        //tricky, but the row (x) corresponds to the column which start at 0 on the left with the n-1th the farthest right on the board. And the Y coordinate corresponds to the x-axis or the row, that starts at 0 and moves up the screen with the n-1th row at the top of the board.
        let x = CGFloat(coord.column) * tileSize + bottomLeft.x
        let y = CGFloat(coord.row) * tileSize + bottomLeft.y
        
        return CGPoint(x: x, y: y)
    }
    
    private func translatePoint(_ point: CGPoint) -> TileCoord {
        var x = Int(round((point.x - bottomLeft.x) / tileSize))
        
        var y = Int(round((point.y - bottomLeft.y) / tileSize))
        
        //ensure that the coords are in bounds because we allow some touches outside the board
        y = max(0, y)
        y = min(Int(boardSize-1), y)
        
        x = max(0, x)
        x = min(Int(boardSize-1), x)
        
        return TileCoord(y, x)
    }
}

extension BackpackView {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        
        for node in self.nodes(at: position) {
            if node.name == targetingAreaName && viewModel.rune != nil && !background.contains(position) {
                let tileCoord = translatePoint(position)
                viewModel.didTarget(tileCoord)
            }
        }
    }
}
