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
    
    // touch delegate
    weak var touchDelegate: SKScene?
    
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
    private var inventoryArea: SKSpriteNode

    // targeting area
    private var targetingArea: SKSpriteNode
    
    // views with content
    private var itemArea: SKSpriteNode
    private var toastMessageContainer: SKShapeNode?
    private var itemDetailView: SKSpriteNode
    private var emptyItemArea: SKSpriteNode
    
    // swipe values
    private var touchIsSwipe = false
    private let swipeThreshold = CGFloat(25)
    private var initialPosition = CGPoint.zero
    
    // buttons
    private lazy var cancelButton: Button = {
        let button = Button(size: CGSize(width: Style.Backpack.ctaButton, height: 100.0), delegate: self, identifier: .backpackCancel, precedence: .foreground, fontSize: UIFont.extraLargeSize, fontColor: UIColor.red, backgroundColor: UIColor.eggshellWhite)
        
        button.position = CGPoint.positionThis(button.frame,
                                               inBottomOf: self.inventoryArea.frame,
                                               anchored: .left,
                                               verticalPadding: Style.Padding.most)
        button.zPosition = Precedence.menu.rawValue
        return button
    }()
    
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
        self.background = SKSpriteNode(color: .foregroundBlue, size: CGSize(width: playableRect.width, height: height))
        self.background.position = CGPoint.position(this: background.frame, centeredInBottomOf: viewContainer.frame)
        
        //targeting area
        self.targetingArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: playableRect.height))
        self.targetingArea.position = self.viewContainer.frame.center
        self.targetingArea.name = self.targetingAreaName
        
        //inventory area
        self.inventoryArea = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: playableRect.width, height: height))
        self.inventoryArea.position = CGPoint.position(this: inventoryArea.frame, centeredInBottomOf: viewContainer.frame)
        
        // item detail view
        self.itemDetailView = SKSpriteNode(texture: nil, color: .clayRed, size: self.inventoryArea.size)
        self.itemDetailView.position = CGPoint.position(this: itemDetailView.frame, centeredInBottomOf: viewContainer.frame)

        // center target area reticles
        let marginWidth = playableRect.width - CGFloat(tileSize * boardSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * boardSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        self.bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        // item  areas
        itemArea = SKSpriteNode(color: .clear, size: CGSize(width: CGFloat(viewModel.inventory.count) * Style.Backpack.itemSize.width, height: height/2))
        itemArea.position = CGPoint.position(itemArea.frame, inside: inventoryArea.frame, verticaliy: .bottom, anchor: .left)
        
        self.emptyItemArea = SKSpriteNode(color: .clear,
                                          size: CGSize(width: playableRect.width, height: height))
        self.emptyItemArea.position = .zero
        emptyItemArea.isHidden = true
        
        let emptyItemLabel = ParagraphNode(text: Constants.emptyItemMessage, paragraphWidth: playableRect.width, fontColor: .black)
        emptyItemLabel.position = .zero
        emptyItemLabel.position = emptyItemLabel.position.translateVertically(Style.Padding.more)
        
        let restockLabel = ParagraphNode(text: Constants.restockMessage, paragraphWidth: playableRect.width, fontSize: UIFont.largeSize, fontColor: .black)
        restockLabel.position = CGPoint.alignHorizontally(restockLabel.frame, relativeTo: emptyItemLabel.frame, horizontalAnchor: .center, verticalAlign: .bottom)
        emptyItemArea.addChild(emptyItemLabel)
        emptyItemArea.addChild(restockLabel)

        // init ourselves
        super.init(texture: nil, color: .clear, size: CGSize(width: playableRect.width, height: height))
        // "bind" to to the view model
        self.viewModel.updateCallback = { [weak self] in self?.updated() }
        self.viewModel.inventoryUpdated = { [weak self] in self?.updateItemArea() }
        self.viewModel.targetsUpdated = { [weak self] in self?.updateShowDetailView() }
        self.viewModel.viewModeChanged = { [weak self] in self?.updateViewMode() }
        
        // add sprites to the inventory area
        inventoryArea.addChild(itemArea)
        inventoryArea.addChild(emptyItemArea)
        
        // add children to view container
        viewContainer.addChild(self.background)
        viewContainer.addChild(self.inventoryArea)
        
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
        updateToastMessage()
        updateReticles()
        updateCancelButton(with: viewModel.ability)
        updateTargetArea()
    }
    
    //MARK: - private functions
    
    private func updateViewMode() {
        let endPosition = CGPoint.position(this: itemDetailView.frame, centeredInBottomOf: viewContainer.frame)
        if viewModel.viewMode == .itemDetail {
            let initialPosition = endPosition.translateVertically(-itemDetailView.frame.height)
            
            itemDetailView.position = initialPosition
            
            itemDetailView.run(SKAction.move(to: endPosition, duration: AnimationSettings.Backpack.itemDetailMoveRate))
            viewContainer.addChildSafely(itemDetailView)
            
            
            itemArea.isHidden = true
            
        } else {
            let endPosition = CGPoint.position(this: itemDetailView.frame, centeredInBottomOf: viewContainer.frame)
            let initialPosition = endPosition.translateVertically(-itemDetailView.frame.height)
            itemDetailView.position = endPosition
            
            let removeAllChildrenAction = SKAction.run { [weak self] in
                self?.itemDetailView.removeAllChildren()
                self?.itemArea.isHidden = false
            }
            
            itemDetailView.run(SKAction.sequence(
                [SKAction.move(to: initialPosition, duration: AnimationSettings.Backpack.itemDetailMoveRate),
                 SKAction.removeFromParent(),
                 removeAllChildrenAction]
                )
            )
            
            
        }
    }
    
    /// grab the sprite or sprite sheet from an ability
    private func getSprite(of ability: AnyAbility?, detailView: Bool = false) -> SKSpriteNode? {
        var sprite: SKSpriteNode?
        let size = detailView ? Style.Backpack.itemDetailSize : Style.Backpack.itemSize
        if let abilityFrames = ability?.spriteSheet?.animationFrames(), let first = abilityFrames.first  {
            sprite = SKSpriteNode(texture: first, color: .clear, size: size)
            sprite?.run(SKAction.repeatForever(SKAction.animate(with: abilityFrames, timePerFrame: AnimationSettings.Store.itemFrameRate)))
            sprite?.name = ability?.type.rawValue
            
        } else if let abilitySprite = ability?.sprite {
            sprite = abilitySprite
            sprite?.size = size
            sprite?.name = ability?.type.rawValue
        }
        
        // add on the 1...Nx to display that you own multiple copies
        if let number = ability?.count, number > 1 {
            let numberXLabel = ParagraphNode(text: "\(number)x", paragraphWidth: size.width, fontColor: .darkText)
            numberXLabel.zPosition = Precedence.menu.rawValue
            numberXLabel.position = CGPoint.position(numberXLabel.frame, inside: sprite?.frame ?? .zero, verticaliy: .bottom, anchor: .right)
            
            let backgroundColor = SKSpriteNode(color: .lightGray, size: numberXLabel.size)
            backgroundColor.position = .zero
            
            numberXLabel.addChildSafely(backgroundColor)
            sprite?.addChildSafely(numberXLabel)
        
        }
        
        return sprite

    }
    
    /// show the item detail view with item .... details
    private func updateShowDetailView() {

        // item area
        if let itemView = getSprite(of: viewModel.ability, detailView: true) {
            
            itemDetailView.removeAllChildren()
            
            itemView.position = .zero
            itemView.position = CGPoint.position(itemView.frame,
                                                 inside: itemDetailView.frame,
                                                 verticalAlign: .top,
                                                 horizontalAnchor: .left,
                                                 xOffset: Style.Padding.normal,
                                                 yOffset: Style.Padding.normal)
            itemDetailView.addChildSafely(itemView)
            
            if let ability = viewModel.ability {
                // place the label on the right of the item viem
                let descriptionLabel = ParagraphNode(text: ability.description, paragraphWidth: itemDetailView.frame.width - itemView.frame.width - Style.Padding.less*2, fontSize: UIFont.largeSize, fontColor: UIColor.storeBlack)
                descriptionLabel.position = CGPoint.alignVertically(descriptionLabel.frame, relativeTo: itemView.frame, horizontalAnchor: .right, verticalAlign: .top, verticalPadding: Style.Padding.less*2, horizontalPadding: Style.Padding.less * 2, translatedToBounds: true)
                itemDetailView.addChildSafely(descriptionLabel)
            }
            
            
            // add the cancel button
            cancelButton.position = CGPoint.position(cancelButton.frame, inside: itemDetailView.frame, verticaliy: .bottom, anchor: .right, padding: Style.Padding.most*2)
            itemDetailView.addChildSafely(cancelButton)
            
            
            // targeting board sprite
            targetBoard.position = CGPoint.alignHorizontally(targetBoard.frame, relativeTo: itemView.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.more*2, horizontalPadding: 0.0, translatedToBounds: true)
            itemDetailView.addChildSafely(targetBoard)
            
            // targeting message
            let fontColor: UIColor = viewModel.legallyTargeted ? .green : .red
            
            let toastWidth = Style.Backpack.Toast.width
            
            // targeting paragraph paragraph
            let toastMessageParagraph = ParagraphNode(text: viewModel.toastMessage, paragraphWidth: toastWidth, fontSize: UIFont.largeSize, fontColor: fontColor)
            toastMessageParagraph.position =
                CGPoint.alignVertically(toastMessageParagraph.frame, relativeTo: targetBoard.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
            
            // usage paragraph
            let usageMessageParagraph = ParagraphNode(text: viewModel.usageMessage, paragraphWidth: toastWidth, fontSize: UIFont.largeSize, fontColor: .lightText)
            usageMessageParagraph.position =
                CGPoint.alignHorizontally(usageMessageParagraph.frame, relativeTo: toastMessageParagraph.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.normal, horizontalPadding: 0.0, translatedToBounds: true)
            
            //targeting and uasage message
            itemDetailView.addOptionalChild(toastMessageParagraph)
            itemDetailView.addOptionalChild(usageMessageParagraph)
            
            // use button
            let button = Button(size: CGSize(width: Style.Backpack.ctaButton, height: 100.0), delegate: self, identifier: .backpackConfirm, precedence: .foreground, fontSize: UIFont.extraLargeSize, fontColor: UIColor.black, backgroundColor: .highlightGold)
            
            button.enabled(viewModel.legallyTargeted)
            button.position = CGPoint.alignHorizontally(button.frame, relativeTo: itemDetailView.frame, horizontalAnchor: .right, verticalAlign: .top, verticalPadding: 0.0, horizontalPadding: Style.Padding.more, translatedToBounds: false)
            button.zPosition = Precedence.menu.rawValue
            itemDetailView.addChildSafely(button)
                
            
            // add it to the main view
            itemDetailView.zPosition = Precedence.menu.rawValue
        }
    }
    
    /// Given an amount to scroll, this method updates the itemAreas position
    private func scrollItemArea(_ amount: CGFloat) {
        if itemArea.frame.width < playableRect.width { return }
        
        // an abritrary value, feel free to tinker with
        let damping: CGFloat = 0.15
        
        // our targetPosition
        let targetPositionX = itemArea.position.x + (amount * damping)
        
        // protect against moving too far left
        guard targetPositionX <= inventoryArea.frame.minX + itemArea.frame.width/2 else {
            
            //snap the area to the maximum value
            itemArea.position = CGPoint(x: inventoryArea.frame.minX + itemArea.frame.width/2, y: itemArea.position.y)
            return
        }
        
        // protect against moving too far right
        guard targetPositionX >= inventoryArea.frame.maxX - itemArea.frame.width/2
        else {
            
            //snap the are to the minimum value
            itemArea.position = CGPoint(x: inventoryArea.frame.maxX - itemArea.frame.width/2, y: itemArea.position.y)
            return
            
        }
        
        // finally set the position
        itemArea.position = CGPoint(x: targetPositionX, y: itemArea.position.y)
    }
    
    private func updateItemArea() {
        itemArea.removeFromParent()
        
        //recalculate the frame based on number of available abilities
        let newItemArea = SKSpriteNode(color: .clear, size: CGSize(width: CGFloat(viewModel.inventory.count) * Style.Backpack.itemSize.width, height: height/2))
        newItemArea.position = CGPoint.position(newItemArea.frame, inside: inventoryArea.frame, verticaliy: .center, anchor: .center)
        
        itemArea = newItemArea
        
        
        var sprites: [SKSpriteNode?] = []
        for ability in viewModel.inventory {
            let sprite = getSprite(of: ability)
            
            if let sprite = sprite {
                let rect = CGRect(x: -sprite.frame.width/2,
                                  y: -sprite.frame.height/2,
                                  width: sprite.frame.width,
                                  height: sprite.frame.height)
                let outline = SKShapeNode(rect: rect)
                outline.strokeColor = .storeBlack
                outline.position = .zero
                sprite.addOptionalChild(outline)
            }
            sprites.append(sprite)
        }
        
        let height = playableRect.height * Style.Backpack.heightCoefficient
        let rows = CGFloat(1)
        let columns = CGFloat(viewModel.inventory.count)
        let gridPoints = CGPoint.gridPositions(rows: rows,
                                               columns: columns,
                                               itemSize: Style.Backpack.itemSize,
                                               width: itemArea.frame.width,
                                               height: height,
                                               bottomLeft: CGPoint(x: -itemArea.frame.width/2,
                                                                   y: -itemArea.frame.height/2))
        
        
        itemArea.removeAllChildren()
        for index in 0..<sprites.count {
            assert(sprites.count <= gridPoints.count, "We hard coded \(rows*columns) items total, this will break if there are more than 10 items")
            sprites[index]?.position = gridPoints[index]
            itemArea.addChildSafely(sprites[index])
        }
        
        if sprites.isEmpty {
            emptyItemArea.isHidden = false
        }
        
        inventoryArea.addChildSafely(itemArea)
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
    
    private func updateToastMessage() {
        guard viewModel.inventory.count > 0 else { return }
        
        if viewModel.nameMessage?.isEmpty ?? false {
            toastMessageContainer?.run(SKAction.sequence([SKAction.move(by: CGVector(dx: 0.0, dy: -200), duration: 1.0), SKAction.removeFromParent()]))
            toastMessageContainer?.removeAllChildren()
            return
        } else {
            toastMessageContainer?.removeAllChildren()
            toastMessageContainer?.removeFromParent()
        }

        // Display the toast message

        let fontColor: UIColor = viewModel.legallyTargeted ? .green : .red

        let toastWidth = Style.Backpack.Toast.width
        let toastHeight = Style.Backpack.Toast.height

        //toast shape
        let path = CGPath(roundedRect: CGRect(x: -toastWidth/2, y: -toastHeight/2,
                                              width: toastWidth, height: toastHeight),
                          cornerWidth: Style.Backpack.Toast.cornerRadius,
                          cornerHeight: Style.Backpack.Toast.cornerRadius,
                          transform: nil)
        let toastContainer = SKShapeNode(path: path)
        toastContainer.color = .storeBlack

        //toast paragraph
        let toastMessageParagraph = ParagraphNode(text: viewModel.nameMessage ?? "", paragraphWidth: toastWidth, fontSize: UIFont.largeSize, fontColor: fontColor)
        toastMessageParagraph.position = CGPoint.position(this: toastMessageParagraph.frame, centeredVerticallyInTopHalfOf: toastContainer.frame)

        //toast container
        toastContainer.addOptionalChild(toastMessageParagraph)
        toastContainer.zPosition = Precedence.underground.rawValue
        toastContainer.position = CGPoint.alignHorizontally(toastContainer.frame, relativeTo: self.background.frame, horizontalAnchor: .left, verticalAlign: .top, verticalPadding: -toastContainer.frame.height/2, horizontalPadding: Style.Padding.more, translatedToBounds: true)

        self.addChildSafely(toastContainer)
        toastMessageContainer = toastContainer
    }
    
    private func updateCancelButton(with ability: AnyAbility?) {
        if let _ = ability {
            cancelButton.isHidden = false
        } else {
            cancelButton.isHidden = true
        }
    }

}

extension BackpackView {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        guard background.contains(position) else {            
            touchDelegate?.touchesMoved(touches, with: event)
            return
        }
        
        // we might not have moved far enough from our original position to consider this a swipe
        // however you may start to swipe and then end up back or close to our original position.
        // So, we consider a swipe a swipe for the entirety of the gesture (until they lift up their finger)
        guard abs(position.x - initialPosition.x) >= swipeThreshold
            || touchIsSwipe
            else {
            // we havent moved enough to consider this a swipe
            return
        }
        // calculate total movement from intial finger touch
        let distanceTravelOnXAxis = position.x - initialPosition.x
        scrollItemArea(distanceTravelOnXAxis)
        touchIsSwipe = true

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        
        guard !touchIsSwipe else {
            touchIsSwipe = false
            return
        }
        
        for node in self.nodes(at: position) {
            if node.name == targetingAreaName && viewModel.ability != nil && !background.contains(position) {
               let tileCoord = translatePoint(position)
               viewModel.didTarget(tileCoord)
            }
            else if let abilityType = node.name, viewModel.viewMode == .inventory  {
                for ability in viewModel.inventory {
                    if ability.type.rawValue == abilityType {
                        viewModel.didSelect(ability)
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        initialPosition = position
    }
    
}

extension BackpackView: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        if button.identifier == ButtonIdentifier.backpackConfirm {
            viewModel.didUse(viewModel.ability)
        } else  if button.identifier == ButtonIdentifier.backpackCancel {
            viewModel.didSelect(nil)
        }
    }
}
