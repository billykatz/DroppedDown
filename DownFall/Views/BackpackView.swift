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
    
    // view model
    private let viewModel: TargetingViewModel
    
    // touch delegate
    weak var touchDelegate: Renderer?
    
    // constants
    private let targetingAreaName = "targetingArea"
    
    // variables
    private var height: CGFloat = 0.0
    private var abilities: [AnyAbility] = []
    
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
    private var descriptionArea: SKSpriteNode
    private var toastMessageContainer: SKShapeNode?
    
    // buttons
    private lazy var ctaButton: Button = {
        let button = Button(size: CGSize(width: Style.Backpack.ctaButton, height: 100.0), delegate: self, identifier: .backpackUse, precedence: .foreground, fontSize: UIFont.extraLargeSize, fontColor: UIColor.black, backgroundColor: .highlightGold)
        button.position = CGPoint.positionThis(button.frame, outside: descriptionArea.frame, anchor: .right, align: .top, padding: -Style.Padding.more)
        return button
    }()
    
    private lazy var cancelButton: Button = {
        let button = Button(size: CGSize(width: Style.Backpack.ctaButton, height: 100.0), delegate: self, identifier: .backpackCancel, precedence: .foreground, fontSize: UIFont.extraLargeSize, fontColor: UIColor.red, backgroundColor: UIColor.eggshellWhite)
        button.position = CGPoint.positionThis(button.frame, outsideOf: ctaButton.frame, verticality: .bottom, spacing: Style.Padding.more)
        return button
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
        self.background.position = CGPoint.positionThis(background.frame, inBottomOf: viewContainer.frame)
        
        //targeting area
        self.targetingArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: playableRect.height))
        self.targetingArea.position = self.viewContainer.frame.center
        self.targetingArea.name = self.targetingAreaName
        
        //inventory area
        self.inventoryArea = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: playableRect.width, height: height))
        self.inventoryArea.position = CGPoint.positionThis(inventoryArea.frame, inBottomOf: viewContainer.frame)

        // center target area reticles
        let marginWidth = playableRect.width - CGFloat(tileSize * boardSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * boardSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        self.bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        // item  areas
        itemArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width * 3 / 4, height: height/2))
        itemArea.position = CGPoint.positionThis(itemArea.frame, inBottomOf: inventoryArea.frame, anchor: .left)
        
        
        // description area
        descriptionArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width * 3 / 4, height: height/2))
        descriptionArea.position = CGPoint.positionThis(descriptionArea.frame, outsideOf: itemArea.frame, verticality: .top, spacing: -20)

        // init ourselves
        super.init(texture: nil, color: .clear, size: CGSize(width: playableRect.width, height: height))
        // "bind" to to the view model
        self.viewModel.updateCallback = { [weak self] in self?.updated() }
        
        // add sprites to the inventory area
        inventoryArea.addChild(itemArea)
        inventoryArea.addChild(descriptionArea)
        inventoryArea.addChild(ctaButton)
        inventoryArea.addChild(cancelButton)
        
        
        viewContainer.addChild(self.background)
        viewContainer.addChild(self.inventoryArea)
        
        self.addChild(viewContainer)
    
        self.isUserInteractionEnabled = true
        
        updated()
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
        updateDescription(with: viewModel.ability)
        updateCTAButton(with: viewModel.ability)
        updateTargetArea()
        updateItemArea()
    }
    
    /**
     Meant to be called from the Renderer to inject the new player data.
     */
    
    func update(with playerData: EntityModel) {
        self.abilities = playerData.abilities
        
                
        
        // update when positions have been updated
        updated()
    }

    
    //MARK: - private functions
    private func updateItemArea() {
        var sprites: [SKSpriteNode?] = []
        for ability in self.abilities {
            var sprite: SKSpriteNode?
            if let abilityFrames = ability.spriteSheet?.animationFrames(), let first = abilityFrames.first  {
                sprite = SKSpriteNode(texture: first, color: .clear, size: Style.Backpack.itemSize)
                sprite?.run(SKAction.repeatForever(SKAction.animate(with: abilityFrames, timePerFrame: AnimationSettings.Store.itemFrameRate)))
                sprite?.name = ability.type.rawValue
                
            } else if let abilitySprite = ability.sprite {
                sprite = abilitySprite
                sprite?.size = Style.Backpack.itemSize
                sprite?.name = ability.type.rawValue
            }
            sprites.append(sprite)
        }
        
        let height = playableRect.height * Style.Backpack.heightCoefficient
        let rows = CGFloat(2)
        let columns = CGFloat(6)
        let gridPoints = CGPoint.gridPositions(rows: rows,
                                               columns: columns,
                                               itemSize: Style.Backpack.itemSize,
                                               width: playableRect.width - height,
                                               height: height,
                                               bottomLeft: CGPoint(x: -itemArea.frame.width/2,
                                                                   y: -itemArea.frame.height/2))
        
        
        itemArea.removeAllChildren()
        for index in 0..<sprites.count {
            assert(sprites.count <= gridPoints.count, "We hard coded \(rows*columns) items total, this will break if there are more than 10 items")
            sprites[index]?.position = gridPoints[index]
            itemArea.addChildSafely(sprites[index])
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
        
        //tricky, but the row (x) corresponds to the y axis. and the col (y) corresponds to the x-axis.
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
        
        if viewModel.toastMessage.isEmpty {
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
        let toastMessageParagraph = ParagraphNode(text: viewModel.toastMessage, paragraphWidth: toastWidth, fontSize: UIFont.largeSize, fontColor: fontColor)
        toastMessageParagraph.position = CGPoint.position(this: toastMessageParagraph.frame, centeredVerticallyInTopHalfOf: toastContainer.frame)
        
        //toast container
        toastContainer.addOptionalChild(toastMessageParagraph)
        toastContainer.zPosition = Precedence.underground.rawValue
        toastContainer.position = CGPoint.positionThis(toastContainer.frame, outsideOf: self.background.frame, verticality: .top, spacing: -toastContainer.frame.height/2)
        
        self.addChildSafely(toastContainer)
        toastMessageContainer = toastContainer
    }
    
    private func updateDescription(with ability: AnyAbility?) {
        descriptionArea.removeAllChildren()
        
        if let ability = ability {
            let descriptionLabel = ParagraphNode(text: ability.description, paragraphWidth: descriptionArea.frame.width, fontSize: UIFont.largeSize, fontColor: UIColor.storeBlack)
            descriptionArea.addChildSafely(descriptionLabel)
        }
    }
    
    private func updateCTAButton(with ability: AnyAbility?) {
        if let _ = ability {
            if viewModel.legallyTargeted {
                ctaButton.color = .highlightGold
                ctaButton.addShadow()
                ctaButton.isDisabled = false
            } else {
                ctaButton.color = .gray
                ctaButton.removeShadow()
                ctaButton.isDisabled = true
            }
            
            
            ctaButton.isHidden = false
            cancelButton.isHidden = false
        } else {
            ctaButton.isHidden = true
            cancelButton.isHidden = true
        }
    }
}

extension BackpackView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        for node in self.nodes(at: position) {
            if node.name == targetingAreaName && viewModel.ability != nil && !background.contains(position) {
               let tileCoord = translatePoint(position)
               viewModel.didTarget(tileCoord)
            }

            else if let abilityType = node.name {
                for ability in self.abilities {
                    if ability.type.rawValue == abilityType {
                        viewModel.didSelect(ability)
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesBegan(touches, with: event)
    }
}

extension BackpackView: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        if button.identifier == ButtonIdentifier.backpackUse {
            viewModel.didUse(viewModel.ability)
        } else  if button.identifier == ButtonIdentifier.backpackCancel {
            viewModel.didSelect(nil)
        }
    }
}
