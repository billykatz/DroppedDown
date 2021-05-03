//
//  TileDetailView.swift
//  DownFall
//
//  Created by Katz, Billy on 3/24/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

class TileDetailView: SKSpriteNode {
    
    struct Constants {
        static let maxHeight = CGFloat(450)
        static let maxWidth = CGFloat(200)
        static let heightCoefficient = CGFloat(0.33)
        static let widthCoefficient = CGFloat(0.9)
        static let tileSize = CGFloat(75.0)
        static let boardSize = CGFloat(6)
        static let borderName = "border"
        static let borderColor = UIColor(rgb: 0x92A3BE)
        static let overlayName = "overlay"
    }
    
    private let foreground: SKNode
    private let contentView: SKSpriteNode
    private let targetingArea: SKSpriteNode
    private let tileSize: CGFloat
    private let bottomLeft: CGPoint
    private let detailViewTemplate: SKSpriteNode
    private let alignedToHUDFrame: CGRect
    private let playableRect: CGRect
    
    private var tileType: TileType? {
        didSet {
            updateTileDetailView()
        }
    }
    
    
    private var tileAttacks: [TileCoord] = [] {
        didSet {
            updateTargetReticles()
        }
    }
    
    private var levelGoals: [GoalTracking]? {
        didSet {
            updateLevelGoals()
        }
    }
    
    init(foreground: SKNode, playableRect: CGRect, alignedTo: CGRect, levelSize: Int) {
        self.foreground = foreground
        contentView = SKSpriteNode(color: .clear, size: playableRect.size)
        contentView.position = .zero
        alignedToHUDFrame = alignedTo
        
        /// create the targeting view
        let floatLevelSize = CGFloat(levelSize)
        
        // compute the tile size
        tileSize = GameScope.boardSizeCoefficient * (playableRect.width / floatLevelSize)
        
        // center target area reticles
        let marginWidth = playableRect.width - CGFloat(tileSize * floatLevelSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * floatLevelSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        targetingArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: playableRect.height))
        targetingArea.position = contentView.frame.center
        targetingArea.zPosition = Precedence.menu.rawValue
        
        
        /// Detail view
        
        let maxWidth = self.contentView.frame.width * Constants.widthCoefficient
        let maxHeight = Constants.maxHeight// bottomLeft.y - playableRect.minY - tileSize/2 - Style.Padding.more
        let detailView = SKSpriteNode(color: .foregroundBlue, size: CGSize(width: maxWidth, height: maxHeight))
        
        detailView.position = CGPoint.position(detailView.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most*8)
        detailView.zPosition = Precedence.flying.rawValue
        self.detailViewTemplate = detailView
        
        
        self.playableRect = playableRect
        
        super.init(texture: nil, color: .clear, size: playableRect.size)

        /// Add nodes to the foreground
        self.foreground.addChild(self)
        self.addChild(contentView)
        contentView.addChild(targetingArea)
        
        // set out own z position
        self.zPosition = 100_000
        contentView.zPosition = 100_000
        
        
        // default interaction is false
        isUserInteractionEnabled = false
        
        Dispatch.shared.register { [weak self] input in
            switch input.type {
            case .tileDetail(let tileType, let attacks):
                self?.tileType = tileType
                self?.tileAttacks = attacks
                self?.isUserInteractionEnabled = true
                self?.addChildSafely(self?.contentView)
            case .levelGoalDetail(let updatedGoals):
                self?.levelGoals = updatedGoals
                self?.isUserInteractionEnabled = true
                self?.addChildSafely(self?.contentView)
            default:
                break
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func titleNode(tileType: TileType, nextTo: CGRect) -> ParagraphNode {
        let string = tileType.humanReadable
        let title = ParagraphNode(text: string, paragraphWidth: detailViewTemplate.frame.width - nextTo.width, fontSize: .fontLargeSize)
        title.position = CGPoint.alignVertically(title.frame, relativeTo: nextTo, horizontalAnchor: .right, verticalAlign: .top, horizontalPadding: Style.Padding.most, translatedToBounds: true)
        title.zPosition = Precedence.menu.rawValue
        return title
    }
    
    private func spriteNode(tileType: TileType) -> SKSpriteNode {
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: tileType.textureString()), size: Style.DetailView.spriteSize)
        sprite.position = CGPoint.position(sprite.frame, inside: detailViewTemplate.frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: Style.Padding.normal)
        sprite.zPosition = Precedence.menu.rawValue
        return sprite
    }
    
    private func animatedSprite(offer: StoreOffer) -> SKSpriteNode {
        let potionAnimationFrames = SpriteSheet(texture: SKTexture(imageNamed: offer.textureName),
                                                rows: 1,
                                                columns: offer.spriteSheetColumns!)
        
        let placeholderSprite = SKSpriteNode(color: .clear, size: CGSize(width: tileSize, height: tileSize))
        placeholderSprite.run(SKAction.repeatForever(SKAction.animate(with: potionAnimationFrames.animationFrames(), timePerFrame: 0.2)))

        placeholderSprite.position = CGPoint.position(placeholderSprite.frame, inside: detailViewTemplate.frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: Style.Padding.normal)
        placeholderSprite.zPosition = Precedence.menu.rawValue
        return placeholderSprite
    }
    
    private func attackDescription(tileType: TileType, nextTo: CGRect) -> ParagraphNode? {
        guard case let TileType.monster(data) = tileType else { return nil }
        let attackDesc = ParagraphNode(text: data.attack.humanReadable(), paragraphWidth: detailViewTemplate.frame.width - Style.DetailView.spriteSize.width, fontSize: .fontMediumSize)
        attackDesc.position = CGPoint.alignHorizontally(attackDesc.frame, relativeTo: nextTo, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        attackDesc.zPosition = Precedence.menu.rawValue
        return attackDesc
    }
    
    private func pillarDescription(tileType: TileType, nextTo: CGRect) -> ParagraphNode? {
        guard case TileType.pillar(let data) = tileType  else { return nil }
        let text =
        """
        \u{2022} \(data.health) health
        \u{2022} blocks attacks from monsters
        \u{2022} takes damage from mining rocks next to it
        \u{2022} collapses when it reaches 0 health
        """
        let pillarDesc = ParagraphNode(text: text, paragraphWidth: detailViewTemplate.frame.width - Style.DetailView.spriteSize.width, fontSize: .fontMediumSize)
        pillarDesc.position = CGPoint.alignHorizontally(pillarDesc.frame, relativeTo: nextTo, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        pillarDesc.zPosition = Precedence.menu.rawValue
        return pillarDesc
        
    }
    
    private func gemDescription(tileType: TileType, nextTo: CGRect) -> ParagraphNode? {
        guard case TileType.item = tileType  else { return nil }
        let text =
        """
        \u{2022} Valuable currency.
        \u{2022} Larger groups of rocks are more likely to drop gems.
        \u{2022} There are only a few gems to find on each level.
        """
        let gemDesc = ParagraphNode(text: text, paragraphWidth: detailViewTemplate.frame.width - Style.DetailView.spriteSize.width - Style.Padding.more, fontSize: .fontMediumSize)
        gemDesc.position = CGPoint.alignHorizontally(gemDesc.frame, relativeTo: nextTo, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        gemDesc.zPosition = Precedence.menu.rawValue
        return gemDesc
        
    }
    
    private func playerDescription(tileType: TileType, nextTo: CGRect) -> ParagraphNode? {
        guard case TileType.player(let data) = tileType  else { return nil }
        let text =
        """
        \u{2022} Dodge: \(data.dodge)
        \u{2022} Luck:  \(data.luck)
        """
        let playerDesc = ParagraphNode(text: text, paragraphWidth: detailViewTemplate.frame.width - Style.DetailView.spriteSize.width - Style.Padding.more, fontSize: .fontMediumSize)
        playerDesc.position = CGPoint.alignHorizontally(playerDesc.frame, relativeTo: nextTo, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        playerDesc.zPosition = Precedence.menu.rawValue
        return playerDesc
        
    }

    private func offerDescription(tileType: TileType, nextTo: CGRect) -> ParagraphNode? {
        guard case TileType.offer(let offer) = tileType  else { return nil }
        let text: String
        if offer.effect.stat == .oneTimeUse {
            text = "Targets chosen randomly. Effects applied immediately."
        } else if offer.effect.kind == .rune {
            text = "Collect to add to your Pickaxe."
        } else {
            text = "Effects applied immediately."
        }
    
        let offerDesc = ParagraphNode(text: text, paragraphWidth: detailViewTemplate.frame.width - Style.DetailView.spriteSize.width - Style.Padding.more, fontSize: .fontMediumSize)
        offerDesc.position = CGPoint.alignHorizontally(offerDesc.frame, relativeTo: nextTo, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        offerDesc.zPosition = Precedence.menu.rawValue
        return offerDesc
        
    }
    
    private func exitDescription(tileType: TileType, nextTo: CGRect) -> ParagraphNode? {
        guard case TileType.exit(let blocked) = tileType  else { return nil }
        let text: String
        if blocked {
            text = "Blocked until all level goals are completed."
        } else {
            text = "Unblocked."
        }
    
        let exitDescription = ParagraphNode(text: text, paragraphWidth: detailViewTemplate.frame.width - Style.DetailView.spriteSize.width - Style.Padding.more, fontSize: .fontMediumSize)
        exitDescription.position = CGPoint.alignHorizontally(exitDescription.frame, relativeTo: nextTo, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.more, translatedToBounds: true)
        exitDescription.zPosition = Precedence.menu.rawValue
        return exitDescription
        
    }



    
    func updateTileDetailView() {
        guard let tileType = tileType else {
            detailViewTemplate.removeAllChildren()
            detailViewTemplate.removeFromParent()
            for child in contentView.children {
                if child.name == Constants.borderName || child.name == Constants.overlayName {
                    child.removeFromParent()
                }
            }
            return
        }
        
        /// add the sprite image
        let sprite: SKSpriteNode
        if case TileType.offer(let offer) = tileType, offer.hasSpriteSheet {
            sprite = animatedSprite(offer: offer)
        } else {
            sprite = spriteNode(tileType: tileType)
        }
        detailViewTemplate.addChild(sprite)
        
        /// add the title node
        let title = titleNode(tileType: tileType, nextTo: sprite.frame)
        detailViewTemplate.addChild(title)
        
        /// add the attack description
        if let attackDesc = attackDescription(tileType: tileType, nextTo: title.frame) {
            detailViewTemplate.addChild(attackDesc)
        } else if let pillarDesc = pillarDescription(tileType: tileType, nextTo: title.frame) {
            detailViewTemplate.addChild(pillarDesc)
        } else if let gemDesc = gemDescription(tileType: tileType, nextTo: title.frame) {
            detailViewTemplate.addChild(gemDesc)
        } else if let playerDescription = playerDescription(tileType: tileType, nextTo: title.frame) {
            detailViewTemplate.addChild(playerDescription)
        } else if let offerDescription = offerDescription(tileType: tileType, nextTo: title.frame) {
            detailViewTemplate.addChild(offerDescription)
        } else if let exitDescription = exitDescription(tileType: tileType, nextTo: title.frame) {
            detailViewTemplate.addChild(exitDescription)
        }
        
        detailViewTemplate.position = CGPoint.position(this: detailViewTemplate.frame, centeredInBottomOf: self.contentView.frame, verticalPadding: 150.0)

        /// Add it to the view
        contentView.addChild(detailViewTemplate)

        // add the border
        addBorder(toView: contentView)
        
        // add the background overlay
        addBackgroundOverlay()
    }
    
    func updateLevelGoals() {
        guard let updatedGoals = levelGoals else {
            detailViewTemplate.removeAllChildren()
            detailViewTemplate.removeFromParent()
            return
        }
        for child in contentView.children {
            if child.name == Constants.borderName || child.name == Constants.overlayName {
                child.removeFromParent()
            }
        }

        
        let subTitleNode = ParagraphNode(text: "Level Goals", paragraphWidth: detailViewTemplate.frame.width, fontSize: .fontExtraLargeSize)
        
        subTitleNode.position = CGPoint.position(subTitleNode.frame, inside: detailViewTemplate.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
        
        detailViewTemplate.addChildSafely(subTitleNode)
        
        let textHeight = subTitleNode.frame.height + Style.Padding.more
        
        for (count, goal) in updatedGoals.enumerated() {
            let circleNode = SKShapeNode(circleOfRadius: Style.LevelGoalKey.keyCircleRadius)
            circleNode.color = goal.fillBarColor.1
            
            circleNode.position = CGPoint.position(circleNode.frame,
                                                   inside: detailViewTemplate.frame,
                                                   verticalAlign: .top,
                                                   horizontalAnchor: .left,
                                                   xOffset: Style.Padding.most*2,
                                                   yOffset: (CGFloat(count) * Style.LevelGoalKey.keyCircleRadius * 2) + (CGFloat(count) * 15) + textHeight + Style.Padding.more*3)

            detailViewTemplate.addChildSafely(circleNode)
            
            
            // create the goal description
            let descriptionLabel = ParagraphNode(text: "\(goal.description())", paragraphWidth: detailViewTemplate.frame.maxX - circleNode.frame.maxX, fontSize: .fontLargeSize)
            
            descriptionLabel.position = CGPoint.alignVertically(descriptionLabel.frame, relativeTo: circleNode.frame, horizontalAnchor: .right, verticalAlign: .center, verticalPadding: Style.Padding.less, horizontalPadding: 100.0,  translatedToBounds: true)
            
            detailViewTemplate.addChildSafely(descriptionLabel)
    
            
            // Progress label  
            let progressLabel = ParagraphNode(text: goal.progressDescription, paragraphWidth: detailViewTemplate.frame.maxX - circleNode.frame.maxX, fontSize: .fontLargeSize)
            let x = CGPoint.position(progressLabel.frame, inside: detailViewTemplate.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: Style.Padding.most).x
            let y = CGPoint.alignVertically(progressLabel.frame, relativeTo: descriptionLabel.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true).y
            progressLabel.position = CGPoint(x: x, y: y)
                
            
            detailViewTemplate.addChildSafely(progressLabel)
        
        }
        
        detailViewTemplate.position = CGPoint.position(detailViewTemplate.frame, inside: self.contentView.frame, verticalAlign: .center, horizontalAnchor: .center)
        contentView.addChildSafely(detailViewTemplate)
        
        // add tap anywhere to continue
        let tapHelpText = "[Tap anywhere to continue]"
        let tapHelpNode = ParagraphNode(text: tapHelpText, paragraphWidth: detailViewTemplate.frame.width, fontSize: .fontMediumSize)
        tapHelpNode.position = CGPoint.position(tapHelpNode.frame, inside: detailViewTemplate.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: 20, translatedToBounds: true)
        detailViewTemplate.addChildSafely(tapHelpNode)
        
        // add the border
        addBorder(toView: detailViewTemplate)
        
        
        // add the background overlay
        addBackgroundOverlay()
    }
    
    
    func addBorder(toView: SKSpriteNode) {
        // add the border
        let border = SKShapeNode(rect: detailViewTemplate.frame)
        border.lineWidth = 20.0
        border.zPosition = self.zPosition + 100
        border.position = .zero
        border.name = Constants.borderName
        border.strokeColor = Constants.borderColor
        toView.addChild(border)
    }
    
    func addBackgroundOverlay() {
        // set up the background
        let overlay = SKShapeNode(rect: playableRect)
        overlay.color = UIColor.white
        overlay.alpha = 0.25
        overlay.zPosition = -1
        overlay.position = .zero
        overlay.name = Constants.overlayName
        contentView.addChild(overlay)

    }
    
    private func updateTargetReticles() {
        guard !tileAttacks.isEmpty else {
            targetingArea.removeAllChildren()
            return
        }
        
        for target in tileAttacks {
            let position = translateCoord(target)
            let reticle = SKSpriteNode(texture: SKTexture(imageNamed: "redReticle"),
                                       size: CGSize(width: tileSize, height: tileSize))
            reticle.position = position
            reticle.zPosition = Precedence.menu.rawValue
            targetingArea.addChildSafely(reticle)
        }
    }
    
    
    
    private func translateCoord(_ coord: TileCoord) -> CGPoint {
        
        //tricky, but the x coordinate increases as the column in the TileCoord increase. The same is true for the Y coordinate and the row of the TileCoord.
        let x = CGFloat(coord.column) * tileSize + bottomLeft.x
        let y = CGFloat(coord.row) * tileSize + bottomLeft.y
        
        return CGPoint(x: x, y: y)
    }
    
}

extension TileDetailView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            // then dismiss the view
            tileType = nil
            tileAttacks = []
            levelGoals = nil
            InputQueue.append(Input(.play))
            isUserInteractionEnabled = false
            contentView.removeFromParent()
        }
    }
}
