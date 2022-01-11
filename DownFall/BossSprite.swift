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
        
        static let bossRightLeg1Name = "boss-right-leg-1"
        static let bossRightLeg2Name = "boss-right-leg-2"
        static let bossRightLeg3Name = "boss-right-leg-3"
        static let bossRightLeg4Name = "boss-right-leg-4"
        
        static let bossToothName = "boss-spider-tooth"
        static let bossSalivaName = "boss-spider-tooth-saliva"
        
        static let bossSparkleEffect = "boss-spider-sparkler-effect"
        static let bossEyelids = "boss-spider-eyelids"
        static let bossEye = "boss-spider-eyes"
        static let bossHeadCrystals = "boss-spider-head-crystals"
        
        static let bossBodyName = "boss-body"
        
        static let dynamiteTrain = "boss-dynamite-train"
        
        static let artworkDimensions = CGSize(width: 280, height: 112)
        static let leftLeft1AnchorPoint = CGPoint(x: 75, y: 49)
        static let leftLeft2AnchorPoint = CGPoint(x: 81, y: 41)
        static let leftLeft3AnchorPoint = CGPoint(x: 88, y: 5)
        static let leftLeft4AnchorPoint = CGPoint(x: 74, y: 5)
        
        static let rightLeg1AnchorPoint = CGPoint(x: 4, y: 47)
        static let rightLeg2AnchorPoint = CGPoint(x: 5, y: 24)
        static let rightLeg3AnchorPoint = CGPoint(x: 5, y: 6)
        static let rightLeg4AnchorPoint = CGPoint(x: 4, y: 8)
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
    
    lazy var rightLeg1: SKSpriteNode = {
        let spiderLegTexture = SKTexture(imageNamed: Constants.bossRightLeg1Name)
        let sprite = SKSpriteNode(texture: spiderLegTexture, size: scaleBodyPart(originalSize: spiderLegTexture.size()))
        let anchorPoint = Constants.rightLeg1AnchorPoint
        let originalSize = spiderLegTexture.size()
        sprite.anchorPoint = convertPoint(from: anchorPoint, in: originalSize)
        sprite.zPosition = 900_000
        return sprite
    }()
    
    lazy var rightLeg2: SKSpriteNode = {
        let spiderLegTexture = SKTexture(imageNamed: Constants.bossRightLeg2Name)
        let sprite = SKSpriteNode(texture: spiderLegTexture, size: scaleBodyPart(originalSize: spiderLegTexture.size()))
        let anchorPoint = Constants.rightLeg2AnchorPoint
        let originalSize = spiderLegTexture.size()
        sprite.anchorPoint = convertPoint(from: anchorPoint, in: originalSize)
        sprite.zPosition = 700_000
        return sprite
    }()
    
    lazy var rightLeg3: SKSpriteNode = {
        let spiderLegTexture = SKTexture(imageNamed: Constants.bossRightLeg3Name)
        let sprite = SKSpriteNode(texture: spiderLegTexture, size: scaleBodyPart(originalSize: spiderLegTexture.size()))
        let anchorPoint = Constants.rightLeg3AnchorPoint
        let originalSize = spiderLegTexture.size()
        sprite.anchorPoint = convertPoint(from: anchorPoint, in: originalSize)
        sprite.zPosition = 500_000
        return sprite
    }()
    
    lazy var rightLeg4: SKSpriteNode = {
        let spiderLegTexture = SKTexture(imageNamed: Constants.bossRightLeg4Name)
        let sprite = SKSpriteNode(texture: spiderLegTexture, size: scaleBodyPart(originalSize: spiderLegTexture.size()))
        let anchorPoint = Constants.rightLeg4AnchorPoint
        let originalSize = spiderLegTexture.size()
        sprite.anchorPoint = convertPoint(from: anchorPoint, in: originalSize)
        sprite.zPosition = 300_000
        return sprite
    }()
    
    lazy var spiderBody: SKSpriteNode = {
        let spiderBodyTexture = SKTexture(imageNamed: Constants.bossBodyName)
        let sprite = SKSpriteNode(texture: spiderBodyTexture, size: scaleBodyPart(originalSize: spiderBodyTexture.size()))
        sprite.zPosition = 200_000
        return sprite
    }()
    
    lazy var leftLegs: [SKSpriteNode] = {
        [leftLeg1, leftLeg2, leftLeg3, leftLeg4]
    }()
    
    lazy var rightLegs: [SKSpriteNode] = {
        [rightLeg1, rightLeg2, rightLeg3, rightLeg4]
    }()
    
    lazy var walkingPairsA: [SKSpriteNode] = {
        [leftLeg1, rightLeg2, leftLeg3, rightLeg4]
    }()
    
    lazy var walkingPairsB: [SKSpriteNode] = {
        [rightLeg1, leftLeg2, rightLeg3, rightLeg4]
    }()
    
    lazy var spiderHead: SKSpriteNode = {
        let bossSpriteSize = CGSize(width: spiderWidth, height: spiderHeight)
        let spider = SKSpriteNode(texture: SKTexture(imageNamed: Constants.bossSpriteName), color: .clear, size: bossSpriteSize)
        spider.zPosition = 1_000_000
        return spider
    }()
    
    lazy var spiderTooth: SKSpriteNode = {
        let toothTexture = SKTexture(imageNamed: Constants.bossToothName)
        let sprite = SKSpriteNode(texture: toothTexture, size: scaleBodyPart(originalSize: toothTexture.size()))
        sprite.zPosition = 1_200_000
        return sprite
    }()
    
    lazy var spiderToothSaliva: SKSpriteNode = {
        let toothTexture = SKTexture(imageNamed: Constants.bossSalivaName)
        let sprite = SKSpriteNode(texture: toothTexture, size: scaleBodyPart(originalSize: toothTexture.size()))
        sprite.zPosition = 1_300_000
        return sprite
    }()

    
    lazy var spiderSparkle: SKSpriteNode = {
        let toothTexture = SKTexture(imageNamed: Constants.bossSparkleEffect)
        let sprite = SKSpriteNode(texture: toothTexture, size: scaleBodyPart(originalSize: toothTexture.size()))
        sprite.zPosition = 1_500_000
        return sprite
    }()
    
    lazy var spiderEyelids: SKSpriteNode = {
        let toothTexture = SKTexture(imageNamed: Constants.bossEyelids)
        let sprite = SKSpriteNode(texture: toothTexture, size: scaleBodyPart(originalSize: toothTexture.size()))
        sprite.zPosition = 1_200_000
        return sprite
    }()
    
    lazy var spiderEyes: SKSpriteNode = {
        let toothTexture = SKTexture(imageNamed: Constants.bossEye)
        let sprite = SKSpriteNode(texture: toothTexture, size: scaleBodyPart(originalSize: toothTexture.size()))
        sprite.zPosition = 1_100_000
        return sprite
    }()
    
    lazy var spiderEyebrowCrystals: SKSpriteNode = {
        let toothTexture = SKTexture(imageNamed: Constants.bossHeadCrystals)
        let sprite = SKSpriteNode(texture: toothTexture, size: scaleBodyPart(originalSize: toothTexture.size()))
        sprite.zPosition = 1_200_000
        return sprite
    }()
    
    lazy var originalSpiderTrainPosition: CGPoint = {
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: Constants.dynamiteTrain), size: CGSize(width: 400, height: 200))
        let initialPosition = CGPoint.alignVertically(sprite.frame, relativeTo: self.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: -25.0, horizontalPadding: 100.0, translatedToBounds: true)
        return initialPosition
    }()
    
    lazy var spiderDynamiteTrain: SKSpriteNode = {
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: Constants.dynamiteTrain), size: CGSize(width: 400, height: 200))
        let initialPosition = originalSpiderTrainPosition
        sprite.position = initialPosition
        sprite.zPosition = 2_200_000
        return sprite
    }()
    
    lazy var spiderPoisonBeam: SKSpriteNode = {
        let spiderPoisonBeamTexture = SKTexture(imageNamed: "poison-beam-sprite")
        let sprite = SKSpriteNode(texture: spiderPoisonBeamTexture, size: scaleBodyPart(originalSize: spiderPoisonBeamTexture.size()))
        let initialPosition = CGPoint.alignHorizontally(sprite.frame, relativeTo: spiderHead.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: -100.0, horizontalPadding: 0.0, translatedToBounds: true)
        
        sprite.yScale = -1
        sprite.position = initialPosition
        sprite.zPosition = 2_200_000
        sprite.alpha = 0.0
        return sprite
    }()
    
    init(playableRect: CGRect) {
        self.playableRect = playableRect
        super.init(texture: nil, color: .clear, size: CGSize(width: playableRect.width*0.9, height: playableRect.width*0.9/spiderRatio))
        
        leftLeg1.position = CGPoint.position(leftLeg1.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: -35, horizontalAnchor: .center, xOffset: -100, translatedToBounds: true)
        leftLeg2.position = CGPoint.position(leftLeg2.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 0, horizontalAnchor: .center, xOffset: -120, translatedToBounds: true)
        leftLeg3.position = CGPoint.position(leftLeg3.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 20, horizontalAnchor: .center, xOffset: -100, translatedToBounds: true)
        leftLeg4.position = CGPoint.position(leftLeg4.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 60, horizontalAnchor: .center, xOffset: -100, translatedToBounds: true)
        
        rightLeg1.position = CGPoint.position(rightLeg1.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: -30, horizontalAnchor: .center, xOffset: 110, translatedToBounds: true)
        rightLeg2.position = CGPoint.position(rightLeg2.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 8, horizontalAnchor: .center, xOffset: 120, translatedToBounds: true)
        rightLeg3.position = CGPoint.position(rightLeg3.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 30, horizontalAnchor: .center, xOffset: 120, translatedToBounds: true)
        rightLeg4.position = CGPoint.position(rightLeg4.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 55, horizontalAnchor: .center, xOffset: 110, translatedToBounds: true)
        
        spiderBody.position = CGPoint.position(spiderBody.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 0, horizontalAnchor: .center, translatedToBounds: true)
        
        spiderTooth.position = CGPoint.position(spiderTooth.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 0, horizontalAnchor: .center, xOffset: 0, translatedToBounds: true)
        
        spiderSparkle.position = CGPoint.position(spiderSparkle.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 0, horizontalAnchor: .center, translatedToBounds: true)
        
        spiderEyelids.position = CGPoint.position(spiderEyelids.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 0, horizontalAnchor: .center, xOffset: 0, translatedToBounds: true)
        spiderEyes.position = CGPoint.position(spiderEyes.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 0, horizontalAnchor: .center, xOffset: 0, translatedToBounds: true)
        spiderEyebrowCrystals.position = CGPoint.position(spiderEyebrowCrystals.frame, inside: spiderHead.frame, verticalAnchor: .center, yOffset: 0, horizontalAnchor: .center, xOffset: 0, translatedToBounds: true)
        
        self.addChild(spiderHead)
        self.addChild(leftLeg1)
        self.addChild(leftLeg2)
        self.addChild(leftLeg3)
        self.addChild(leftLeg4)
        
        self.addChild(rightLeg1)
        self.addChild(rightLeg2)
        self.addChild(rightLeg3)
        self.addChild(rightLeg4)
        
        self.addChild(spiderBody)
        self.addChild(spiderSparkle)
        
        self.addChild(spiderDynamiteTrain)
        
        spiderHead.addChild(spiderTooth)
        spiderHead.addChild(spiderEyelids)
        spiderHead.addChild(spiderEyes)
        spiderHead.addChild(spiderEyebrowCrystals)
        spiderHead.addChild(spiderPoisonBeam)
        
        buildOriginalPositions()
    }
    
    struct OriginalPositions {
        let position: CGPoint
        let zPosition: CGFloat
        let rotation: CGFloat
    }
    var originalPositions: [(SKSpriteNode, OriginalPositions)] = []
    
    func buildOriginalPositions() {
        originalPositions = self.children.compactMap( { $0 as? SKSpriteNode }).map { child in return (child, OriginalPositions(position: child.position, zPosition: child.zPosition, rotation: child.zRotation)) }
        
        let bossHeadChildren = spiderHead.children.compactMap( { $0 as? SKSpriteNode }).map { child in return (child, OriginalPositions(position: child.position, zPosition: child.zPosition, rotation: child.zRotation)) }
        
        originalPositions.append(contentsOf: bossHeadChildren)

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
