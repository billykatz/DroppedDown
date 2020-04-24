//
//  BackpackView.swift
//  DownFall
//
//  Created by Katz, Billy on 1/17/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

/**
 The view containing the player's items
 */

class BackpackView: SKSpriteNode {
    
    private struct Constants {
        static let emptyItemMessage = "No items in backpack."
        static let restockMessage = "(Restock in the store)"
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
    
    //rune inventory container
    private var runeInventoryContainer: SKSpriteNode?
    
    // pick axe
    var pickaxeHandleView: SKSpriteNode?
    
    private lazy var targetBoard: SKSpriteNode = {
        let targetBoard = SKSpriteNode(texture: SKTexture(imageNamed: "targetBoard"), color: .clear, size: Style.Backpack.targetBoardSize)
        return targetBoard
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
        self.viewModel.updateCallback = { [weak self] in self?.updated() }
        self.viewModel.runeSlotsUpdated = runeSlotsUpdated
        
        // add children to view container
        viewContainer.addChild(self.background)
        
        // add out viewcontainter
        self.addChild(viewContainer)
        
        
        // enable user interaction
        self.isUserInteractionEnabled = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - public update function
    
    /**
     Passed into our viewModel as a callback function to "bind" everything together
     */
    func updated() {
        updateReticles()
        updateCancelButton(with: viewModel.ability)
        updateTargetArea()
    }
    
    //MARK: - private functions
    // TODO: should this be updated?
    private let maxRuneSlots = 4
    private func runeSlotsUpdated(_ runes: Int, _ abilities: [AnyAbility]) {
        /// TODO: we only ever want to do this once!!!
        /// Add an update method to the RuneContainer so if you get a rune mid-level or whatever, it will updated accordinly
        let viewModel = RuneContainerViewModel(abilities: abilities, numberOfRuneSlots: runes)
        let runeContainer = RuneContainerView(viewModel: viewModel, mode: .inventory, size: CGSize(width: playableRect.width, height: 300.0))
        
        runeContainer.position = CGPoint.position(runeContainer.frame, inside: playableRect, verticalAnchor: .bottom, horizontalAnchor: .center, padding: Style.Padding.most*3)
        
        viewModel.runeUseWasCanceled = runeUseWasCanceled
        viewModel.runeWasUsed = self.viewModel.didUse
        viewModel.runeWasTapped = runeWasTapped
        
        addChild(runeContainer)
    }
    
    func runeUseWasCanceled() {
        viewModel.didSelect(nil)
    }
    
    func runeWasTapped(ability: AnyAbility?) {
        print("$ Rune was tapped")
        viewModel.didSelect(ability)
    }
    
    
    /// grab the sprite or sprite sheet from an ability
    private func getSprite(of ability: AnyAbility?, detailView: Bool = false) -> SKSpriteNode? {
        var sprite: SKSpriteNode?
        let size = detailView ? Style.Backpack.itemDetailSize : Style.Backpack.itemSize
        if let abilityFrames = ability?.spriteSheet?.animationFrames(), let first = abilityFrames.first  {
            sprite = SKSpriteNode(texture: first, color: .clear, size: size)
            sprite?.run(SKAction.repeatForever(SKAction.animate(with: abilityFrames, timePerFrame: AnimationSettings.Store.itemFrameRate)))
            sprite?.name = ability?.type.humanReadable
            
        } else if let abilitySprite = ability?.sprite {
            sprite = abilitySprite
            sprite?.size = size
            sprite?.name = ability?.type.humanReadable
        }
        
        // add on the 1...Nx to display that you own multiple copies
        if let number = ability?.count, number > 1 {
            let numberXLabel = ParagraphNode(text: "\(number)x", paragraphWidth: size.width, fontColor: .darkText)
            numberXLabel.zPosition = Precedence.menu.rawValue
            numberXLabel.position = CGPoint.position(numberXLabel.frame, inside: sprite?.frame ?? .zero, verticalAnchor: .bottom, horizontalAnchor: .right)
            
            let backgroundColor = SKSpriteNode(color: .lightGray, size: numberXLabel.size)
            backgroundColor.position = .zero
            
            numberXLabel.addChildSafely(backgroundColor)
            sprite?.addChildSafely(numberXLabel)
            
        }
        
        return sprite
        
    }
    
    private func updateTargetArea() {
        if viewModel.ability == nil {
            targetingArea.removeFromParent()
        } else {
            addChildSafely(targetingArea)
        }
    }
    
    private func updateReticles() {
        targetingArea.removeAllChildren()
        
        for target in viewModel.currentTargets {
            let position = translateCoord(target.coord)
            let identifier: String = target.isLegal ? Identifiers.Sprite.greenReticle : Identifiers.Sprite.redReticle
            let reticle = SKSpriteNode(texture: SKTexture(imageNamed: identifier), size: CGSize(width: tileSize, height: tileSize))
            reticle.position = position
            reticle.zPosition = Precedence.menu.rawValue
            targetingArea.addChildSafely(reticle)
        }
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
    
    private func updateCancelButton(with ability: AnyAbility?) {
    }
}

extension BackpackView {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        
        for node in self.nodes(at: position) {
            if node.name == targetingAreaName && viewModel.ability != nil && !background.contains(position) {
                let tileCoord = translatePoint(position)
                viewModel.didTarget(tileCoord)
            }
        }
    }
}
