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
    
    let viewModel: TargetingViewModel
    
    weak var touchDelegate: Renderer?
    
    
    private var tileSize: CGFloat
    private var boardSize: CGFloat
    
    private var toastMessageContainer: SKShapeNode?
    private let playableRect: CGRect
    private var background: SKSpriteNode
    private var targetingArea: SKSpriteNode
    private var viewContainer: SKSpriteNode
    
    private var inventoryArea: SKSpriteNode
    
    private var itemArea: SKSpriteNode?
    private var descriptionArea: SKSpriteNode?
    private var ctaButton: Button?
    private var cancelButton: Button?
    private var nextItemsButton: Button?
    private var abilities: [AnyAbility] = []
    
    let targetingAreaName = "targetingArea"
    
    var selectedAbility: AnyAbility? = nil {
        didSet {
            viewModel.ability = selectedAbility
            updateDescription(with: selectedAbility)
            updateCTAButton(with: selectedAbility)
        }
    }
    
    var height: CGFloat = 0.0
    
    init(playableRect: CGRect, viewModel: TargetingViewModel, levelSize: Int) {
        self.playableRect = playableRect
        self.boardSize = CGFloat(levelSize)
        //height and width set ups
        height = playableRect.height * Style.Backpack.heightCoefficient
        
        // get the view model
        self.viewModel = viewModel
        
        //get the tile size
        self.tileSize = 0.9 * (playableRect.width / CGFloat(levelSize))
        
        // view container
        self.viewContainer = SKSpriteNode(texture: nil, color: .clear, size: playableRect.size)
        self.viewContainer.zPosition = Precedence.foreground.rawValue
        
        // background view
        self.background = SKSpriteNode(color: .foregroundBlue, size: CGSize(width: playableRect.width, height: height))//setting the background position
        self.background.position = CGPoint.positionThis(background.frame, inBottomOf: self.viewContainer.frame)
        
        //targeting area
        self.targetingArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: playableRect.height))
        self.targetingArea.position = self.viewContainer.frame.center
        self.targetingArea.name = self.targetingAreaName
        
        //inventory area
        self.inventoryArea = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: playableRect.width, height: height))
        self.inventoryArea.position = CGPoint.positionThis(self.inventoryArea.frame, inBottomOf: self.viewContainer.frame)

        // center target area reticles
        let marginWidth = playableRect.width - CGFloat(tileSize * boardSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * boardSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        self.bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        super.init(texture: nil, color: .clear, size: CGSize(width: playableRect.width, height: height))
        // "bind" to to the view model
        self.viewModel.updateCallback = self.updated
        
        // setting our frame size
//        self.size = CGSize(width: playableRect.width, height: playableRect.height)
        
        // item and description areas
        itemArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width * 3 / 4, height: height/2))
        itemArea?.position = CGPoint.positionThis(itemArea?.frame, inBottomOf: self.inventoryArea.frame, anchor: .left)
        
        descriptionArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width * 3 / 4, height: height/2))
        descriptionArea?.position = CGPoint.positionThis(descriptionArea?.frame, outsideOf: itemArea?.frame, verticality: .top, spacing: -20)
        
        //cta button
        ctaButton = Button(size: CGSize(width: Style.Backpack.ctaButton, height: 100.0), delegate: self, identifier: .backpackUse, precedence: .foreground, fontSize: UIFont.extraLargeSize, fontColor: UIColor.black, backgroundColor: .highlightGold)
        ctaButton?.position = CGPoint.positionThis(ctaButton?.frame, outside: descriptionArea?.frame, anchor: .right, align: .top, padding: -Style.Padding.more)
        
        
        //cancel button
        self.cancelButton = Button(size: CGSize(width: Style.Backpack.ctaButton, height: 100.0), delegate: self, identifier: .backpackCancel, precedence: .foreground, fontSize: UIFont.extraLargeSize, fontColor: UIColor.red, backgroundColor: UIColor.eggshellWhite)
        self.cancelButton?.position = CGPoint.positionThis(self.cancelButton?.frame, outsideOf: ctaButton?.frame, verticality: .bottom, spacing: Style.Padding.more)
        
        //next button
        self.nextItemsButton = Button(size: CGSize(width: Style.Backpack.ctaButton, height: 100.0), delegate: self, identifier: .backpackCancel, precedence: .foreground, fontSize: UIFont.extraLargeSize, fontColor: UIColor.black, backgroundColor: UIColor.menuPurple)
        self.nextItemsButton?.position = CGPoint.positionThis(self.nextItemsButton?.frame, outsideOf: cancelButton?.frame, verticality: .bottom, spacing: Style.Padding.more)
        
        
        inventoryArea.addOptionalChild(itemArea)
        inventoryArea.addOptionalChild(descriptionArea)
        inventoryArea.addOptionalChild(ctaButton)
        inventoryArea.addOptionalChild(cancelButton)
        inventoryArea.addOptionalChild(nextItemsButton)
        
        updateCTAButton(with: nil)
        
//        background.isUserInteractionEnabled = true
//        inventoryArea.isUserInteractionEnabled = true
//        targetingArea.isUserInteractionEnabled = true
        
        viewContainer.addChild(self.background)
//        viewContainer.addChild(self.targetingArea)
        viewContainer.addChild(self.inventoryArea)
        
        self.addChild(viewContainer)
    
        self.isUserInteractionEnabled = true
    }
    
    
    func updated() {
        updateToastMessage()
        updateReticles()
        updateDescription(with: viewModel.ability)
        updateCTAButton(with: viewModel.ability)
        updateTargetArea()
    }
    
    
    func updateTargetArea() {
        if viewModel.ability == nil {
            targetingArea.removeFromParent()
        } else {
            targetingArea.removeFromParent()
            addChild(targetingArea)
        }
    }
    
    func updateReticles() {
        targetingArea.removeAllChildren()
        
        for target in viewModel.currentTargets {
            let position = translateCoord(target.coord)
            let identifier: String = target.isLegal ? Identifiers.greenReticleSprite : Identifiers.redReticleSprite
            let reticle = SKSpriteNode(texture: SKTexture(imageNamed: identifier), size: CGSize(width: tileSize, height: tileSize))
            reticle.position = position
            reticle.zPosition = Precedence.menu.rawValue
            targetingArea.addChild(reticle)
        }
    }
    
    private var bottomLeft: CGPoint
    
    func translateCoord(_ coord: TileCoord) -> CGPoint {
        
        //tricky, but the row (x) corresponds to the y axis. and the col (y) corresponds to the x-axis.
        let x = CGFloat(coord.y) * tileSize + bottomLeft.x
        let y = CGFloat(coord.x) * tileSize + bottomLeft.y
        
        return CGPoint(x: x, y: y)
    }
    
    func translatePoint(_ point: CGPoint) -> TileCoord {
        var x =
            Int(
                round(
                    (point.x - bottomLeft.x) / tileSize
                )
            )
        
        var y =
            Int(
                round(
                    (point.y - bottomLeft.y) / tileSize
                )
            )
        
        y = max(0, y)
        y = min(Int(boardSize-1), y)
        
        x = max(0, x)
        x = min(Int(boardSize-1), x)
        
        return TileCoord(y, x)
    }
    
    func updateToastMessage() {
        
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
        
        let toastWidth = CGFloat(600)
        
        //toast shape
        let path = CGPath(roundedRect: CGRect(x: -toastWidth/2, y: -100, width: toastWidth, height: 200), cornerWidth: 50.0, cornerHeight: 50.0, transform: nil)
        let toastContainer = SKShapeNode(path: path)
        toastContainer.color = .storeBlack
        
        //toast paragraph
        let toastMessageParagraph = ParagraphNode(text: viewModel.toastMessage, paragraphWidth: toastWidth, fontSize: UIFont.largeSize, fontColor: fontColor)
        toastMessageParagraph.position = CGPoint.positionThis(toastMessageParagraph.frame, inTopOfHalf: toastContainer.frame)
        
        //toast container
        toastContainer.addOptionalChild(toastMessageParagraph)
        toastContainer.zPosition = Precedence.underground.rawValue
        toastContainer.position = CGPoint.positionThis(toastContainer.frame, outsideOf: self.background.frame, verticality: .top, spacing: -toastContainer.frame.height/2)
        
        self.addChild(toastContainer)
        toastMessageContainer = toastContainer
    }
    
    func update(with playerData: EntityModel) {
        print("update player data \(playerData)")
        guard let itemArea = itemArea else { fatalError("we need item area") }
        
        // display these on screen
        // give them button and identifier
        // only display a few at a time
        updated()
        itemArea.removeAllChildren()
        
        self.abilities = playerData.abilities
        
        var sprites: [SKSpriteNode?] = []
        for ability in playerData.abilities {
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
        
        for index in 0..<sprites.count {
            assert(sprites.count <= gridPoints.count, "We hard coded \(rows*columns) items total, this will break if there are more than 10 items")
            sprites[index]?.position = gridPoints[index]
            itemArea.addOptionalChild(sprites[index])
        }
    }
    
    func toggleItemArea() {
        if itemArea?.position.x ?? 0.0 < playableRect.origin.x {
            // items are hidden
            let position = CGPoint.positionThis(itemArea?.frame, inBottomOf: self.frame, padding: Style.Padding.most, anchor: .left)
            let moveAction = SKAction.move(to: position,  duration: 0.25)
            moveAction.timingMode = .easeIn
            
            itemArea?.run(moveAction)
        } else {
            // items are showing
            let position = CGPoint.positionThis(itemArea?.frame, outside: self.frame, anchor: .left, padding: Style.Padding.most)
            let moveAction = SKAction.move(to: position, duration: 0.25)
            moveAction.timingMode = .easeOut
            
            itemArea?.run(moveAction)
        }
    }
    
    func updateDescription(with ability: AnyAbility?) {
        descriptionArea?.removeAllChildren()
        
        if let ability = ability {
            let descriptionLabel = ParagraphNode(text: ability.description, paragraphWidth: descriptionArea?.frame.width ?? 0, fontSize: UIFont.largeSize, fontColor: UIColor.storeBlack)
            descriptionArea?.addChild(descriptionLabel)
        }
    }
    
    func updateCTAButton(with ability: AnyAbility?) {
        if let _ = ability {
            if viewModel.legallyTargeted {
                ctaButton?.color = .highlightGold
                ctaButton?.addShadow()
                ctaButton?.isDisabled = false
            } else {
                ctaButton?.color = .gray
                ctaButton?.removeShadow()
                ctaButton?.isDisabled = true
            }
            
            
            ctaButton?.isHidden = false
            cancelButton?.isHidden = false
        } else {
            ctaButton?.isHidden = true
            cancelButton?.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                        selectedAbility = ability
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
        if button.identifier == ButtonIdentifier.backpack {
            toggleItemArea()
            selectedAbility = nil
        } else if button.identifier == ButtonIdentifier.backpackUse {
            viewModel.didUse()
        } else  if button.identifier == ButtonIdentifier.backpackCancel {
            selectedAbility = nil
        }
    }
}
