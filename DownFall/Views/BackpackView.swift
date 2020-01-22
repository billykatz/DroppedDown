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
    
    let playableRect: CGRect
    var itemArea: SKSpriteNode?
    var descriptionArea: SKSpriteNode?
    var ctaButton: SKShapeNode?
    var abilities: [AnyAbility] = []
    var selectedAbility: AnyAbility? = nil {
        didSet {
            updateDescription(with: selectedAbility)
            updateCTAButton(with: selectedAbility)
        }
    }
    
    var height: CGFloat = 0.0
    
    init(playableRect: CGRect) {
        self.playableRect = playableRect
        //height and width set ups
        height = playableRect.height * Style.Backpack.heightCoefficient
        let backPackHeight: CGFloat = 280
        let backPackWidth = height * 2/3
        
        super.init(texture: nil, color: .clear, size: CGSize(width: playableRect.width, height: height))
        
        // setting our frame size
        self.size = CGSize(width: playableRect.width, height: height)
        self.position = CGPoint.positionThis(self.frame, inBottomOf: playableRect)
        
        // item and description areas
        itemArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width - backPackWidth, height: height/2))
        itemArea?.position = CGPoint.positionThis(itemArea?.frame, inBottomOf: self.frame, anchor: .left)
        
        descriptionArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width - backPackWidth, height: height/2))
        descriptionArea?.position = CGPoint.positionThis(descriptionArea?.frame, outsideOf: itemArea?.frame, verticality: .top)
        
        ctaButton = Button(size: CGSize(width: Style.Backpack.ctaButton, height: 125.0), delegate: self, identifier: .backpackUse, precedence: .foreground, fontSize: UIFont.extraLargeSize, fontColor: UIColor.black, backgroundColor: .highlightGold)
        ctaButton?.position = CGPoint.positionThis(ctaButton?.frame, outside: descriptionArea?.frame, anchor: .right, align: .top, padding: -Style.Padding.more)
        
        
        addOptionalChild(itemArea)
        addOptionalChild(descriptionArea)
        addOptionalChild(ctaButton)
        
        // backpack views
        let backpackContainer = SKSpriteNode(color: .clear, size: CGSize(width: backPackWidth, height: backPackHeight))
        
        let backpackSprite = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.backpackSprite), size: CGSize(width: 240, height: backPackHeight))
        
        let backpackButton = Button(size: backpackSprite.frame.size,
                                    delegate: self,
                                    identifier: .backpack,
                                    precedence: .foreground,
                                    fontSize: UIFont.largeSize,
                                    fontColor: .black,
                                    backgroundColor: .clear,
                                    showSelection: false)
        
        backpackContainer.addChild(backpackSprite)
        backpackContainer.addChild(backpackButton)
        
        backpackSprite.position = CGPoint.positionThis(backpackSprite.frame, inBottomOf: backpackContainer.frame, anchor: .right)
        
        backpackButton.position = backpackSprite.position
        
        addChild(backpackContainer)
        
        backpackContainer.position = CGPoint.positionThis(backpackContainer.frame, inBottomOf: self.frame, anchor: .right)
        
        // background view
        let background = SKSpriteNode(color: .foregroundBlue, size: CGSize(width: playableRect.width, height: height))
        background.position = CGPoint.positionThis(background.frame, inBottomOf: self.frame)
        addChild(background)
        
        self.isUserInteractionEnabled = true
    }
    
    func update(with playerData: EntityModel) {
        print("update player data \(playerData)")
        guard let itemArea = itemArea else { fatalError("we need item area") }
        
        // display these on screen
        // give them button and identifier
        // only display a few at a time
        
        
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
        let columns = CGFloat(4)
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
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BackpackView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        for node in self.nodes(at: position) {
            if let abilityType = node.name {
                for ability in self.abilities {
                    if ability.type.rawValue == abilityType {
                        selectedAbility = ability
                    }
                }
            }
        }
    }
}

extension BackpackView: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        if button.identifier == ButtonIdentifier.backpack {
            toggleItemArea()
            selectedAbility = nil
        } else if button.identifier == ButtonIdentifier.backpackUse {
            print("use selected ability \(selectedAbility)")
        }
    }
}
