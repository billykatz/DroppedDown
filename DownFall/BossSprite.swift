//
//  BossSprite.swift
//  DownFall
//
//  Created by Billy on 12/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit
import UIKit

class BossSprite: SKSpriteNode {
    
    struct Constants {
        static let bossSpriteName  = "boss-spider"
        static let bossLeftLeg1Name = "boss-left-leg-1"
        static let bossLeftLeg2Name = "boss-left-leg-2"
        static let bossLeftLeg3Name = "boss-left-leg-3"
        static let bossLeftLeg4Name = "boss-left-leg-4"
        static let artworkDimensions = CGSize(width: 280, height: 112)
        static let leftLeft1AnchorPoint = CGPoint(x: 75, y: 49)
        static let leftLeft2AnchorPoint = CGPoint(x: 81, y: 41)
        static let leftLeft3AnchorPoint = CGPoint(x: 88, y: 5)
        static let leftLeft4AnchorPoint = CGPoint(x: 74, y: 5)
    }
    
    let playableRect: CGRect
    let spiderRatio: CGFloat = 35.0/14.0
    lazy var spiderWidth: CGFloat = {
        playableRect.width*0.9
    }()
    
    lazy var spiderHeight: CGFloat = {
        spiderWidth / spiderRatio
    }()
    
    lazy var leftLeg1: SKSpriteNode = {
        let spiderLegTexture = SKTexture(imageNamed: Constants.bossLeftLeg1Name)
        let sprite = SKSpriteNode(texture: spiderLegTexture, size: scaleBodyPart(originalSize: spiderLegTexture.size()))
        let anchorPoint = Constants.leftLeft1AnchorPoint
        let originalSize = spiderLegTexture.size()
        sprite.anchorPoint = convertPoint(from: anchorPoint, in: originalSize)
        sprite.zPosition = 900_000
        return sprite
    }()
    
    lazy var leftLeg2: SKSpriteNode = {
        let spiderLegTexture = SKTexture(imageNamed: Constants.bossLeftLeg2Name)
        let sprite = SKSpriteNode(texture: spiderLegTexture, size: scaleBodyPart(originalSize: spiderLegTexture.size()))
        let anchorPoint = Constants.leftLeft2AnchorPoint
        let originalSize = spiderLegTexture.size()
        sprite.anchorPoint = convertPoint(from: anchorPoint, in: originalSize)
        sprite.zPosition = 700_000
        return sprite
    }()
    
    lazy var leftLeg3: SKSpriteNode = {
        let spiderLegTexture = SKTexture(imageNamed: Constants.bossLeftLeg3Name)
        let sprite = SKSpriteNode(texture: spiderLegTexture, size: scaleBodyPart(originalSize: spiderLegTexture.size()))
        let anchorPoint = Constants.leftLeft3AnchorPoint
        let originalSize = spiderLegTexture.size()
        sprite.anchorPoint = convertPoint(from: anchorPoint, in: originalSize)
        sprite.zPosition = 500_000
        return sprite
    }()
    
    lazy var leftLeg4: SKSpriteNode = {
        let spiderLegTexture = SKTexture(imageNamed: Constants.bossLeftLeg4Name)
        let sprite = SKSpriteNode(texture: spiderLegTexture, size: scaleBodyPart(originalSize: spiderLegTexture.size()))
        let anchorPoint = Constants.leftLeft4AnchorPoint
        let originalSize = spiderLegTexture.size()
        sprite.anchorPoint = convertPoint(from: anchorPoint, in: originalSize)
        sprite.zPosition = 300_000
        return sprite
    }()
    
    lazy var leftLegs: [SKSpriteNode] = {
        [leftLeg1, leftLeg2, leftLeg3, leftLeg4]
    }()
    
    init(playableRect: CGRect) {
        self.playableRect = playableRect
        super.init(texture: nil, color: .clear, size: CGSize(width: 250, height: 250))
        
        let bossSpriteSize = CGSize(width: spiderWidth, height: spiderHeight)
        let spider = SKSpriteNode(texture: SKTexture(imageNamed: Constants.bossSpriteName), color: .clear, size: bossSpriteSize)
        spider.zPosition = 1000000
        
        
        leftLeg1.position = CGPoint.position(leftLeg1.frame, inside: spider.frame, verticalAnchor: .center, yOffset: -20, horizontalAnchor: .center, xOffset: -60)
        leftLeg2.position = CGPoint.position(leftLeg2.frame, inside: spider.frame, verticalAnchor: .center, yOffset: 0, horizontalAnchor: .center, xOffset: -75)
        leftLeg3.position = CGPoint.position(leftLeg3.frame, inside: spider.frame, verticalAnchor: .center, yOffset: 10, horizontalAnchor: .center, xOffset: -60)
        leftLeg4.position = CGPoint.position(leftLeg4.frame, inside: spider.frame, verticalAnchor: .center, yOffset: 40, horizontalAnchor: .center, xOffset: -60)
        
        self.addChild(spider)
        self.addChild(leftLeg1)
        self.addChild(leftLeg2)
        self.addChild(leftLeg3)
        self.addChild(leftLeg4)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        self.playableRect = .zero
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance methods
    
    // This is use for anchor points. That is why the return value is a CGPoint with x and y vaclues between 0 and 1
    func convertPoint(from oldPoint: CGPoint, in oldSize: CGSize) -> CGPoint {
        let widthRatio = oldPoint.x / oldSize.width
        let heightRatio = oldPoint.y / oldSize.height
        
        return CGPoint(x: widthRatio, y: heightRatio)
    }
    
    func scaleBodyPart(originalSize: CGSize) -> CGSize {
        let widthRatio = originalSize.width / Constants.artworkDimensions.width
        let heightRatio = originalSize.height / Constants.artworkDimensions.height
        
        let actualWidth = widthRatio * spiderWidth
        let actualHeight = heightRatio * spiderHeight
        
        return CGSize(width: actualWidth, height: actualHeight)
    }
    
}
